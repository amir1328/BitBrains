import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/bloc/group_chat_bloc.dart';
import '../../logic/bloc/group_chat_event.dart';
import '../../logic/bloc/group_chat_state.dart';
import '../../../auth/logic/bloc/auth_bloc.dart';
import '../../../auth/logic/bloc/auth_state.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class GroupChatScreen extends StatefulWidget {
  final String roomId;
  const GroupChatScreen({super.key, required this.roomId});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentUserId = 0;

  // Formats the header (e.g. "Today", "Yesterday", "Feb 23, 2026")
  String _getDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Today';
    } else if (targetDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  // Formats the inline time (e.g. "14:24" or "2:24 PM")
  String _getTimeString(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  // Palette for other users' names
  static final List<Color> _senderColors = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFF22C55E),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
  ];

  Color _colorForSender(int senderId) {
    return _senderColors[senderId % _senderColors.length];
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user['id'];
      context.read<GroupChatBloc>().add(
        ConnectGroupChat(roomId: widget.roomId, userId: _currentUserId),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: BlocConsumer<GroupChatBloc, GroupChatState>(
                  listener: (context, state) {
                    if (state is GroupChatConnected) {
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _scrollToBottom(),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is GroupChatInitial) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    } else if (state is GroupChatConnected) {
                      if (state.messages.isEmpty) {
                        return _buildEmptyState();
                      }
                      return ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final msg = state.messages[index];
                          final isMe = msg['sender_id'] == _currentUserId;

                          // Parse current message date
                          DateTime? currentMsgDate;
                          if (msg['timestamp'] != null) {
                            currentMsgDate = DateTime.tryParse(
                              msg['timestamp'],
                            )?.toLocal();
                          }

                          // Parse previous message date to check if we need a new date header
                          DateTime? prevMsgDate;
                          bool showDateHeader = false;
                          if (index == 0) {
                            showDateHeader =
                                true; // Always show header for first msg
                          } else {
                            final prevMsg = state.messages[index - 1];
                            if (prevMsg['timestamp'] != null) {
                              prevMsgDate = DateTime.tryParse(
                                prevMsg['timestamp'],
                              )?.toLocal();
                              if (currentMsgDate != null &&
                                  prevMsgDate != null) {
                                if (currentMsgDate.year != prevMsgDate.year ||
                                    currentMsgDate.month != prevMsgDate.month ||
                                    currentMsgDate.day != prevMsgDate.day) {
                                  showDateHeader = true;
                                }
                              }
                            }
                          }

                          // Check if previous message was from the same sender to group them
                          bool isConsecutive = false;
                          if (index > 0 && !showDateHeader) {
                            final prevMsg = state.messages[index - 1];
                            if (prevMsg['sender_id'] == msg['sender_id']) {
                              isConsecutive = true;
                            }
                          }

                          return Column(
                            crossAxisAlignment:
                                StretchMode.zoomBackground.index == 0
                                ? CrossAxisAlignment.center
                                : CrossAxisAlignment.stretch,
                            children: [
                              if (showDateHeader && currentMsgDate != null)
                                _buildDateHeader(currentMsgDate),
                              _buildBubble(
                                msg,
                                isMe,
                                isConsecutive,
                                currentMsgDate,
                                context,
                              ),
                            ],
                          );
                        },
                      );
                    } else if (state is GroupChatError) {
                      return Center(
                        child: Text(
                          'Error: ${state.message}',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ),
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF263151), width: 1),
          ),
          child: Text(
            _getDateHeader(date),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 24, 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF263151), width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(11),
                border: Border.fromBorderSide(
                  BorderSide(color: Color(0xFF263151)),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accent, AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(Icons.groups_rounded, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.roomId == 'general' ? 'General' : widget.roomId,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Department Group Chat',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFF263151)),
            ),
            child: Icon(
              Icons.forum_outlined,
              size: 36,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Be the first to say something!',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(
    Map<String, dynamic> message,
    bool isMe,
    bool isConsecutive,
    DateTime? msgDate,
    BuildContext context,
  ) {
    final senderColor = isMe
        ? AppColors.primary
        : _colorForSender(message['sender_id'] ?? 0);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(top: isConsecutive ? 2 : 12, bottom: 2),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
          minWidth: 80, // Minimum width to fit timestamp beautifully
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMe && !isConsecutive)
              Padding(
                padding: EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  message['sender_name'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: senderColor,
                  ),
                ),
              ),
            Container(
              padding: EdgeInsets.fromLTRB(14, 10, 14, 8),
              decoration: BoxDecoration(
                gradient: isMe
                    ? LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      )
                    : null,
                color: isMe
                    ? null
                    : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  // Sharper corner on the bottom side facing the avatar if it's the last in a group
                  // For simplicity in this upgrade, we just square off the "tail" side if not consecutive
                  bottomLeft: Radius.circular(
                    isMe ? 16 : (isConsecutive ? 16 : 4),
                  ),
                  bottomRight: Radius.circular(
                    isMe ? (isConsecutive ? 16 : 4) : 16,
                  ),
                ),
                border: isMe
                    ? null
                    : Border.all(color: Color(0xFF263151), width: 1),
                boxShadow: isMe
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  Text(
                    message['content'] ?? '',
                    style: TextStyle(
                      color: isMe
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                      fontSize: 14.5,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(width: 8), // Spacing between text and timestamp
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1.0, top: 4.0),
                    child: Text(
                      msgDate != null ? _getTimeString(msgDate) : '',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isMe
                            ? Colors.white.withOpacity(0.7)
                            : Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF263151), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Message the group...',
                filled: true,
                fillColor: Theme.of(context).colorScheme.primaryContainer,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Color(0xFF263151)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Color(0xFF263151)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(Icons.send_rounded, color: Colors.white, size: 19),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      context.read<GroupChatBloc>().add(SendGroupMessage(text));
      _messageController.clear();
    }
  }
}
