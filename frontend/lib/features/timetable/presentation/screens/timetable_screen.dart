import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/bloc/timetable_bloc.dart';
import '../../logic/bloc/timetable_event.dart';
import '../../logic/bloc/timetable_state.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/auth/logic/bloc/auth_bloc.dart';
import '../../../../features/auth/logic/bloc/auth_state.dart';
import '../widgets/timetable_entry_form.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  int _semester = 5;
  String _courseName = 'AI&DS';
  bool _isStaffOrHod = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _days.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final user = authState.user;
        final role = user['role'] as String? ?? 'student';
        final year = user['year'] as int? ?? 3;

        setState(() {
          _isStaffOrHod = role == 'staff' || role == 'hod';
          _semester = year * 2 - 1;
          _courseName = user['department'] as String? ?? 'AI&DS';
        });
      }

      context.read<TimetableBloc>().add(
        LoadTimetable(semester: _semester, courseName: _courseName),
      );
    });
  }

  void _showEntryForm([dynamic entry]) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TimetableEntryForm(
        entry: entry,
        semester: _semester,
        courseName: _courseName,
        dayOfWeek: _days[_tabController.index],
      ),
    );

    if (result != null && mounted) {
      if (entry == null) {
        context.read<TimetableBloc>().add(AddTimetableEntry(result));
      } else {
        context.read<TimetableBloc>().add(
          UpdateTimetableEntry(
            id: entry.id,
            entry: result,
            semester: _semester,
            courseName: _courseName,
          ),
        );
      }
    }
  }

  void _confirmDelete(dynamic entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: const Text('Are you sure you want to delete this class?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TimetableBloc>().add(
                DeleteTimetableEntry(
                  id: entry.id,
                  semester: _semester,
                  courseName: _courseName,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _timeColor(String? startTime) {
    if (startTime == null) return AppColors.primary;
    final hour = int.tryParse(startTime.split(':')[0]) ?? 12;
    if (hour < 12) return AppColors.timeMorning;
    if (hour < 17) return AppColors.timeAfternoon;
    return AppColors.timeEvening;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _isStaffOrHod
          ? FloatingActionButton(
              onPressed: () => _showEntryForm(),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [AppColors.primary, AppColors.accentLight],
                          ).createShader(bounds),
                          child: Text(
                            'Timetable',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Sem $_semester — $_courseName',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.fromBorderSide(
                          BorderSide(color: Color(0xFF263151)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.today_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6),
                          Text(
                            _days[_tabController.index],
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tab bar
              SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                padding: EdgeInsets.symmetric(horizontal: 16),
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.symmetric(vertical: 4),
                dividerColor: Colors.transparent,
                // ✅ Fix: active tab text white (visible on gradient), inactive muted
                labelColor: Colors.white,
                unselectedLabelColor: Theme.of(
                  context,
                ).textTheme.bodySmall?.color,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                tabs: _days
                    .map(
                      (d) => Tab(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text(d.substring(0, 3).toUpperCase()),
                        ),
                      ),
                    )
                    .toList(),
              ),

              // Content
              Expanded(
                child: BlocConsumer<TimetableBloc, TimetableState>(
                  listener: (context, state) {
                    if (state is TimetableError) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.message)));
                    }
                  },
                  builder: (context, state) {
                    if (state is TimetableLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    } else if (state is TimetableLoaded) {
                      return TabBarView(
                        controller: _tabController,
                        children: _days.map((day) {
                          final dayEntries =
                              state.entries
                                  .where((e) => e.dayOfWeek == day)
                                  .toList()
                                ..sort(
                                  (a, b) => a.startTime.compareTo(b.startTime),
                                );
                          if (dayEntries.isEmpty) {
                            return _buildEmptyDay();
                          }
                          return ListView.builder(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 80),
                            itemCount: dayEntries.length,
                            itemBuilder: (context, i) => _ClassCard(
                              entry: dayEntries[i],
                              accentColor: _timeColor(dayEntries[i].startTime),
                              isStaffOrHod: _isStaffOrHod,
                              onEdit: () => _showEntryForm(dayEntries[i]),
                              onDelete: () => _confirmDelete(dayEntries[i]),
                            ),
                          );
                        }).toList(),
                      );
                    }
                    return Center(
                      child: Text(
                        'Loading timetable...',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyDay() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFF263151)),
            ),
            child: Icon(
              Icons.coffee_rounded,
              size: 32,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          SizedBox(height: 14),
          Text(
            'No classes today',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Enjoy your free time!',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final dynamic entry;
  final Color accentColor;
  final bool isStaffOrHod;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ClassCard({
    required this.entry,
    required this.accentColor,
    required this.isStaffOrHod,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.fromBorderSide(
          BorderSide(color: Color(0xFF263151), width: 1),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Colored left border
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Time block
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                entry.startTime,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
                                ),
                              ),
                              Text(
                                '|',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                entry.endTime,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 14),
                    // Subject info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            entry.subject,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 13,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  entry.teacherName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.room_outlined,
                                size: 13,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Room ${entry.roomNo}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isStaffOrHod) ...[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: onEdit,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                          const SizedBox(height: 12),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                            ),
                            onPressed: onDelete,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            color: Colors.redAccent,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
