import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../logic/bloc/material_bloc.dart';
import '../../logic/bloc/material_bloc_definitions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';

// Feature screens hosted in the bottom nav / rail
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../timetable/presentation/screens/timetable_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../alumni/presentation/screens/alumni_list_screen.dart';

// ─── Navigation destinations ──────────────────────────────────────────────────

class _NavDest {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavDest(this.icon, this.activeIcon, this.label);
}

const _destinations = [
  _NavDest(Icons.auto_stories_outlined, Icons.auto_stories, 'Materials'),
  _NavDest(Icons.calendar_month_outlined, Icons.calendar_month, 'Timetable'),
  _NavDest(Icons.psychology_outlined, Icons.psychology, 'AI Chat'),
  _NavDest(Icons.people_outline_rounded, Icons.people_rounded, 'Alumni'),
  _NavDest(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
];

// ─── Home Shell ───────────────────────────────────────────────────────────────

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MaterialListScreen(),
    const TimetableScreen(),
    const ChatScreen(),
    const AlumniListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return context.isDesktop ? _buildDesktopShell() : _buildMobileShell();
  }

  // ── Desktop: NavigationRail + content side by side ─────────────────────────

  Widget _buildDesktopShell() {
    return Scaffold(
      body: GradientBackground(
        child: Row(
          children: [
            _buildNavigationRail(),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: Color(0xFF263151),
            ),
            Expanded(
              child: IndexedStack(index: _currentIndex, children: _screens),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationRail() {
    return NavigationRail(
      backgroundColor: AppColors.darkSurface,
      selectedIndex: _currentIndex,
      onDestinationSelected: (i) => setState(() => _currentIndex = i),
      extended: context.screenWidth >= 1100,
      minWidth: 72,
      minExtendedWidth: 200,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const BitBrainsLogo(size: 44),
            if (context.screenWidth >= 1100) ...[
              const SizedBox(height: 10),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.primary, AppColors.accentLight],
                ).createShader(bounds),
                child: const Text(
                  'BitBrains',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      indicatorColor: AppColors.primary.withValues(alpha: 0.15),
      selectedIconTheme: const IconThemeData(
        color: AppColors.primary,
        size: 22,
      ),
      unselectedIconTheme: const IconThemeData(
        color: AppColors.textMuted,
        size: 22,
      ),
      selectedLabelTextStyle: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      unselectedLabelTextStyle: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 13,
      ),
      destinations: _destinations
          .map(
            (d) => NavigationRailDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.activeIcon),
              label: Text(d.label),
            ),
          )
          .toList(),
    );
  }

  // ── Mobile: BottomNavigationBar ────────────────────────────────────────────

  Widget _buildMobileShell() {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: const Border(
            top: BorderSide(color: Color(0xFF263151), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: _destinations
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
  const MaterialListScreen({super.key});

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
    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: BlocBuilder<MaterialBloc, StudyMaterialState>(
                builder: (context, state) {
                  if (state is MaterialLoading) {
                    return const Center(
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
    );
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
                shaderCallback: (bounds) => const LinearGradient(
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
              const SizedBox(height: 2),
              Text(
                'AI & DS Department Materials',
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
              const SizedBox(width: 8),
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
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: const Border.fromBorderSide(
              BorderSide(color: Color(0xFF263151)),
            ),
          ),
          child: Icon(icon, size: 20, color: AppColors.textSecondary),
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
      return ListView.builder(
        padding: padding,
        itemCount: materials.length,
        itemBuilder: (context, index) =>
            _MaterialCard(material: materials[index]),
      );
    }

    // Grid for tablet+
    return GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.6,
      ),
      itemCount: materials.length,
      itemBuilder: (context, index) =>
          _MaterialCard(material: materials[index]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF263151)),
            ),
            child: const Icon(
              Icons.auto_stories_outlined,
              size: 40,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No materials yet',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Upload the first study material',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'Error: $message',
              style: const TextStyle(color: AppColors.textSecondary),
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
  const _MaterialCard({required this.material});

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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0xFF263151), width: 1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 6,
            children: [
              _chip(material['course_name'] ?? 'Unknown'),
              _chip('Sem ${material['semester'] ?? '?'}'),
              if (type != null) _chip(type.toUpperCase(), color: iconColor),
            ],
          ),
        ),
        trailing: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.download_rounded,
            color: AppColors.primary,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (color ?? AppColors.textMuted).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color ?? AppColors.textMuted,
        ),
      ),
    );
  }
}
