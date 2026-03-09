import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../logic/bloc/material_bloc.dart';
import '../../logic/bloc/material_bloc_definitions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../features/auth/logic/bloc/auth_bloc.dart';
import '../../../../features/auth/logic/bloc/auth_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'upload_material_sheet.dart';

// Feature screens hosted in the bottom nav / rail
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../timetable/presentation/screens/timetable_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../alumni/presentation/screens/alumni_list_screen.dart';

// ─── Role definitions ─────────────────────────────────────────────────────────

enum UserRole { student, staff, hod, alumni, unknown }

UserRole _parseRole(String? raw) {
  switch (raw?.toLowerCase()) {
    case 'student':
      return UserRole.student;
    case 'staff':
      return UserRole.staff;
    case 'hod':
      return UserRole.hod;
    case 'alumni':
      return UserRole.alumni;
    default:
      return UserRole.unknown;
  }
}

class _NavDest {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  _NavDest(this.icon, this.activeIcon, this.label);
}

// ─── Per-role navigation config ───────────────────────────────────────────────

List<_NavDest> _destsFor(UserRole role) {
  switch (role) {
    case UserRole.staff:
    case UserRole.hod:
      return [
        _NavDest(Icons.auto_stories_outlined, Icons.auto_stories, 'Materials'),
        _NavDest(
          Icons.calendar_month_outlined,
          Icons.calendar_month,
          'Timetable',
        ),
        _NavDest(Icons.psychology_outlined, Icons.psychology, 'AI Chat'),
        _NavDest(Icons.people_outline_rounded, Icons.people_rounded, 'Alumni'),
        _NavDest(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
      ];
    case UserRole.alumni:
      return [
        _NavDest(Icons.people_outline_rounded, Icons.people_rounded, 'Alumni'),
        _NavDest(Icons.psychology_outlined, Icons.psychology, 'AI Chat'),
        _NavDest(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
      ];
    default: // STUDENT + unknown
      return [
        _NavDest(Icons.auto_stories_outlined, Icons.auto_stories, 'Materials'),
        _NavDest(
          Icons.calendar_month_outlined,
          Icons.calendar_month,
          'Timetable',
        ),
        _NavDest(Icons.psychology_outlined, Icons.psychology, 'AI Chat'),
        _NavDest(Icons.people_outline_rounded, Icons.people_rounded, 'Alumni'),
        _NavDest(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
      ];
  }
}

List<Widget> _screensFor(UserRole role, Map<String, dynamic> user) {
  final isStaff = role == UserRole.staff || role == UserRole.hod;
  final isAlumni = role == UserRole.alumni;
  switch (role) {
    case UserRole.alumni:
      return [
        AlumniListScreen(canEdit: isAlumni),
        ChatScreen(),
        ProfileScreen(),
      ];
    default: // student / staff / hod
      return [
        MaterialListScreen(canUpload: isStaff, user: user),
        TimetableScreen(),
        ChatScreen(),
        AlumniListScreen(canEdit: isAlumni),
        ProfileScreen(),
      ];
  }
}

// ─── Home Shell ───────────────────────────────────────────────────────────────

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated
        ? authState.user
        : <String, dynamic>{};
    final role = _parseRole(user['role'] as String?);
    final dests = _destsFor(role);
    final screens = _screensFor(role, user);

    // Reset index if role changes (e.g. after re-login)
    final safeIndex = _currentIndex.clamp(0, screens.length - 1);

    return context.isDesktop
        ? _buildDesktopShell(dests, screens, safeIndex, user, role)
        : _buildMobileShell(dests, screens, safeIndex, user, role);
  }

  // ── Role Banner ─────────────────────────────────────────────────────────────

  Widget _roleBadge(UserRole role) {
    final (label, color, icon) = switch (role) {
      UserRole.staff => ('Faculty', AppColors.accent, Icons.badge_rounded),
      UserRole.hod => (
        'HOD',
        AppColors.primary,
        Icons.supervisor_account_rounded,
      ),
      UserRole.alumni => ('Alumni', AppColors.timeMorning, Icons.work_rounded),
      _ => ('Student', AppColors.timeAfternoon, Icons.school_rounded),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Desktop: NavigationRail ─────────────────────────────────────────────────

  Widget _buildDesktopShell(
    List<_NavDest> dests,
    List<Widget> screens,
    int safeIndex,
    Map<String, dynamic> user,
    UserRole role,
  ) {
    return Scaffold(
      body: GradientBackground(
        child: Row(
          children: [
            NavigationRail(
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedIndex: safeIndex,
              onDestinationSelected: (i) => setState(() => _currentIndex = i),
              extended: context.screenWidth >= 1100,
              minWidth: 72,
              minExtendedWidth: 200,
              leading: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    BitBrainsLogo(size: 44),
                    if (context.screenWidth >= 1100) ...[
                      SizedBox(height: 8),
                      ShaderMask(
                        shaderCallback: (b) => LinearGradient(
                          colors: [AppColors.primary, AppColors.accentLight],
                        ).createShader(b),
                        child: Text(
                          'BitBrains',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      _roleBadge(role),
                    ],
                  ],
                ),
              ),
              indicatorColor: AppColors.primary.withValues(alpha: 0.15),
              selectedIconTheme: IconThemeData(
                color: AppColors.primary,
                size: 22,
              ),
              unselectedIconTheme: IconThemeData(
                color: Theme.of(context).textTheme.bodySmall?.color,
                size: 22,
              ),
              selectedLabelTextStyle: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 13,
              ),
              destinations: dests
                  .map(
                    (d) => NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.activeIcon),
                      label: Text(d.label),
                    ),
                  )
                  .toList(),
            ),
            VerticalDivider(width: 1, thickness: 1, color: Color(0xFF263151)),
            Expanded(
              child: IndexedStack(index: safeIndex, children: screens),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mobile: BottomNavigationBar ────────────────────────────────────────────

  Widget _buildMobileShell(
    List<_NavDest> dests,
    List<Widget> screens,
    int safeIndex,
    Map<String, dynamic> user,
    UserRole role,
  ) {
    return Scaffold(
      body: IndexedStack(index: safeIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF263151), width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: safeIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: dests
              .map(
                (d) => BottomNavigationBarItem(
                  icon: Icon(d.icon),
                  activeIcon: Icon(d.activeIcon),
                  label: d.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// ─── Materials Screen ─────────────────────────────────────────────────────────

class MaterialListScreen extends StatefulWidget {
  final bool canUpload;
  final Map<String, dynamic> user;

  const MaterialListScreen({
    super.key,
    this.canUpload = false,
    this.user = const {},
  });

  @override
  State<MaterialListScreen> createState() => _MaterialListScreenState();
}

class _MaterialListScreenState extends State<MaterialListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MaterialBloc>().add(MaterialsLearned());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: widget.canUpload ? _buildFab() : null,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: BlocBuilder<MaterialBloc, StudyMaterialState>(
                  builder: (context, state) {
                    if (state is MaterialLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    } else if (state is MaterialError) {
                      return _buildErrorState(state.message);
                    } else if (state is MaterialLoaded) {
                      if (state.materials.isEmpty) return _buildEmptyState();
                      return _buildMaterialsList(context, state.materials);
                    }
                    return _buildEmptyState();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Premium gradient FAB for staff / HOD
  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: _onUpload,
      backgroundColor: Colors.transparent,
      elevation: 0,
      extendedPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      label: Container(
        height: 52,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.upload_file_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Upload Material',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onUpload() {
    showUploadMaterialSheet(context);
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.horizontalPadding,
        20,
        context.horizontalPadding,
        8,
      ),
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
                  'Study Hub',
                  style: TextStyle(
                    fontSize: context.isDesktop ? 32 : 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(height: 2),
              Text(
                widget.canUpload
                    ? 'Manage & upload study materials'
                    : 'AI & DS Department Materials',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          Row(
            children: [
              _headerAction(
                Icons.groups_rounded,
                () => context.push('/group-chat/general'),
                tooltip: 'Group Chat',
              ),
              SizedBox(width: 8),
              _headerAction(
                Icons.emoji_events_outlined,
                () => context.push('/achievements'),
                tooltip: 'Achievements',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerAction(IconData icon, VoidCallback onTap, {String? tooltip}) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.fromBorderSide(BorderSide(color: Color(0xFF263151))),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialsList(
    BuildContext context,
    List<Map<String, dynamic>> materials,
  ) {
    final crossAxisCount = context.isDesktop
        ? 3
        : context.isTablet
        ? 2
        : 1;
    final padding = EdgeInsets.fromLTRB(
      context.horizontalPadding,
      8,
      context.horizontalPadding,
      100,
    );

    if (crossAxisCount == 1) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<MaterialBloc>().add(MaterialsLearned());
        },
        color: AppColors.accent,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: ListView.builder(
          padding: padding,
          itemCount: materials.length,
          itemBuilder: (context, index) =>
              _MaterialCard(material: materials[index], user: widget.user),
        ),
      );
    }

    // Grid for tablet+
    return RefreshIndicator(
      onRefresh: () async {
        context.read<MaterialBloc>().add(MaterialsLearned());
      },
      color: AppColors.accent,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: GridView.builder(
        padding: padding,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.6,
        ),
        itemCount: materials.length,
        itemBuilder: (context, index) =>
            _MaterialCard(material: materials[index], user: widget.user),
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
              Icons.auto_stories_outlined,
              size: 40,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'No materials yet',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Upload the first study material',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 40,
            ),
            SizedBox(height: 12),
            Text(
              'Error: $message',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Material Card ────────────────────────────────────────────────────────────

class _MaterialCard extends StatelessWidget {
  final Map<String, dynamic> material;
  final Map<String, dynamic> user;
  const _MaterialCard({required this.material, required this.user});

  IconData _iconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _colorForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'pdf':
        return Colors.redAccent;
      case 'ppt':
      case 'pptx':
        return Colors.orangeAccent;
      case 'doc':
      case 'docx':
        return Colors.blueAccent;
      default:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = material['file_type']?.toString();
    final iconColor = _colorForType(type);

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.fromBorderSide(
          BorderSide(color: Color(0xFF263151), width: 1),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_iconForType(type), color: iconColor, size: 22),
        ),
        title: Text(
          material['title'] ?? 'Untitled',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 6,
            children: [
              _chip(material['course_name'] ?? 'Unknown', context),
              _chip('Sem ${material['semester'] ?? '?'}', context),
              if (type != null)
                _chip(type.toUpperCase(), context, color: iconColor),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () async {
                final bloc = context.read<MaterialBloc>();
                final baseUrl =
                    bloc.remoteDataSource.apiClient.dio.options.baseUrl;
                final materialId = material['id'];
                final url = Uri.parse(
                  '$baseUrl/materials/$materialId/download',
                );
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not open file')),
                  );
                }
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.download_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ),
            if (user['role'] == 'staff' || user['role'] == 'hod') ...[
              SizedBox(width: 8),
              PopupMenuButton(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (val) {
                  if (val == 'delete') {
                    _showDeleteConfirmDialog(context);
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Delete Material'),
        content: Text(
          'Are you sure you want to permanently delete this material?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MaterialBloc>().add(DeleteMaterial(material['id']));
            },
            child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, BuildContext context, {Color? color}) {
    final textColor =
        color ?? Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
