import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/auth/logic/bloc/auth_bloc.dart';
import '../../../../features/auth/logic/bloc/auth_event.dart';
import '../../logic/bloc/profile_bloc.dart';
import '../../logic/bloc/profile_event.dart';
import '../../logic/bloc/profile_state.dart';
import 'add_user_sheet.dart';
import '../widgets/change_password_sheet.dart';

// ─── Role helpers ─────────────────────────────────────────────────────────────

String _roleLabel(String? raw) {
  switch (raw?.toLowerCase()) {
    case 'staff':
      return 'Faculty';
    case 'hod':
      return 'HOD';
    case 'alumni':
      return 'Alumni';
    default:
      return 'Student';
  }
}

Color _roleColor(String? raw) {
  switch (raw?.toLowerCase()) {
    case 'staff':
      return AppColors.accent;
    case 'hod':
      return AppColors.primary;
    case 'alumni':
      return AppColors.timeMorning;
    default:
      return AppColors.timeAfternoon;
  }
}

IconData _roleIcon(String? raw) {
  switch (raw?.toLowerCase()) {
    case 'staff':
      return Icons.badge_rounded;
    case 'hod':
      return Icons.supervisor_account_rounded;
    case 'alumni':
      return Icons.work_rounded;
    default:
      return Icons.school_rounded;
  }
}

// ─── Profile Screen ───────────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _yearController = TextEditingController();
  final _companyCtrl = TextEditingController(); // alumni
  final _gradYearCtrl = TextEditingController(); // alumni

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfile());
  }

  @override
  void dispose() {
    _bioController.dispose();
    _phoneController.dispose();
    _yearController.dispose();
    _companyCtrl.dispose();
    _gradYearCtrl.dispose();
    super.dispose();
  }

  void _populateControllers(Map<dynamic, dynamic> user) {
    if (_isEditing) return; // don't overwrite while editing
    _bioController.text = user['bio'] ?? '';
    _phoneController.text = user['phone_number'] ?? '';
    _yearController.text = (user['year'] ?? '').toString();
    _companyCtrl.text = user['company'] ?? '';
    _gradYearCtrl.text = (user['graduation_year'] ?? '').toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) _populateControllers(state.user);
          if (state is ProfileError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return GradientBackground(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          if (state is ProfileLoaded) {
            final user = state.user;
            final role = user['role'] as String?;
            return GradientBackground(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      _buildHeroHeader(context, user, role),
                      _buildInfoSection(user, role),
                      if (_isEditing) _buildEditSection(role),
                      _buildActionButtons(context, role),
                    ],
                  ),
                ),
              ),
            );
          }
          return GradientBackground(
            child: Center(
              child: Text(
                'Loading profile…',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Hero Header ─────────────────────────────────────────────────────────────

  Widget _buildHeroHeader(
    BuildContext context,
    Map<dynamic, dynamic> user,
    String? role,
  ) {
    final initials = (user['full_name'] as String? ?? 'U')
        .substring(0, 1)
        .toUpperCase();
    final rc = _roleColor(role);

    return Container(
      padding: EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF263151))),
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [rc, AppColors.primary]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: rc.withValues(alpha: 0.4),
                      blurRadius: 28,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: user['avatar_url'] != null
                    ? ClipOval(
                        child: Image.network(
                          user['avatar_url'],
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
              ),
              if (_isEditing)
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(color: rc, shape: BoxShape.circle),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),

          // Name
          Text(
            user['full_name'] ?? 'Guest',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 10),

          // Role + Department badges
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _badgeChip(_roleLabel(role), _roleIcon(role), rc),
              if (user['department'] != null)
                _badgeChip(
                  user['department'] as String,
                  Icons.apartment_rounded,
                  AppColors.accent,
                ),
            ],
          ),
          SizedBox(height: 10),

          // Email
          Text(
            user['email'] ?? '',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Section (role-specific) ────────────────────────────────────────────

  Widget _buildInfoSection(Map<dynamic, dynamic> user, String? role) {
    final isStudent = role == 'student' || role == null;
    final isStaff = role == 'staff' || role == 'hod';
    final isAlumni = role == 'alumni';

    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Student-specific ──
          if (isStudent) ...[
            _SectionLabel('Academic Info'),
            SizedBox(height: 12),
            _infoCard([
              _InfoRow(
                icon: Icons.badge_outlined,
                label: 'Roll No',
                value: user['roll_number'] ?? '—',
              ),
              _InfoRow(
                icon: Icons.school_outlined,
                label: 'Year',
                value: user['year']?.toString() ?? '—',
              ),
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: user['phone_number'] ?? '—',
              ),
            ]),
          ],

          // ── Staff / HOD specific ──
          if (isStaff) ...[
            _SectionLabel('Faculty Info'),
            SizedBox(height: 12),
            _infoCard([
              _InfoRow(
                icon: Icons.apartment_rounded,
                label: 'Department',
                value: user['department'] ?? '—',
              ),
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: user['phone_number'] ?? '—',
              ),
            ]),
          ],

          // ── Alumni specific ──
          if (isAlumni) ...[
            _SectionLabel('Career Info'),
            SizedBox(height: 12),
            _infoCard([
              _InfoRow(
                icon: Icons.work_rounded,
                label: 'Company',
                value: user['company'] ?? '—',
              ),
              _InfoRow(
                icon: Icons.calendar_today,
                label: 'Graduation Year',
                value: user['graduation_year']?.toString() ?? '—',
              ),
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: user['phone_number'] ?? '—',
              ),
            ]),
          ],

          SizedBox(height: 20),

          // Bio (all roles)
          _SectionLabel('Bio'),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.fromBorderSide(
                BorderSide(color: Color(0xFF263151)),
              ),
            ),
            child: Text(
              user['bio'] ?? 'No bio added yet.',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Edit Section (role-specific fields) ────────────────────────────────────

  Widget _buildEditSection(String? role) {
    final isStudent = role == 'student' || role == null;
    final isStaff = role == 'staff' || role == 'hod';
    final isAlumni = role == 'alumni';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('Edit Profile'),
          SizedBox(height: 12),
          GlassCard(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // ── Student fields ──
                if (isStudent) ...[
                  _editField(
                    _yearController,
                    'Year of Study',
                    Icons.school_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 14),
                ],

                // ── Staff / HOD fields ──
                if (isStaff) ...[SizedBox(height: 14)],

                // ── Alumni fields ──
                if (isAlumni) ...[
                  _editField(
                    _companyCtrl,
                    'Current Company',
                    Icons.work_rounded,
                  ),
                  SizedBox(height: 14),
                  _editField(
                    _gradYearCtrl,
                    'Graduation Year',
                    Icons.calendar_today,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 14),
                ],

                // ── Common fields ──
                _editField(
                  _phoneController,
                  'Phone Number',
                  Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 14),
                _editField(
                  _bioController,
                  'Bio',
                  Icons.notes_rounded,
                  maxLines: 3,
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _editField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  // ── Action Buttons ───────────────────────────────────────────────────────────

  Widget _buildActionButtons(BuildContext context, String? role) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        children: [
          // Edit / Save
          GradientButton(
            label: _isEditing ? 'Save Changes' : 'Edit Profile',
            icon: _isEditing ? Icons.save_rounded : Icons.edit_rounded,
            onPressed: () {
              if (_isEditing) {
                final updates = <String, dynamic>{
                  'bio': _bioController.text,
                  'phone_number': _phoneController.text,
                };
                if (role == 'student' || role == null) {
                  if (_yearController.text.isNotEmpty) {
                    updates['year'] = int.tryParse(_yearController.text);
                  }
                }
                if (role == 'staff' || role == 'hod') {
                  // additional staff/hod fields can be added here
                }
                if (role == 'alumni') {
                  updates['company'] = _companyCtrl.text;
                  if (_gradYearCtrl.text.isNotEmpty) {
                    updates['graduation_year'] = int.tryParse(
                      _gradYearCtrl.text,
                    );
                  }
                }
                context.read<ProfileBloc>().add(UpdateProfile(updates));
              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),

          if (role == 'hod' && !_isEditing) ...[
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  showAddUserSheet(context).then((success) {
                    if (success == true && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('User created successfully!'),
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.9,
                          ),
                        ),
                      );
                    }
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: Icon(Icons.person_add_rounded, size: 18),
                label: Text(
                  'Add New User',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],

          if (!_isEditing) ...[
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => const ChangePasswordSheet(),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: Icon(Icons.lock_reset_rounded, size: 18),
                label: Text(
                  'Change Password',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],

          SizedBox(height: 12),

          // Sign Out — properly dispatches AuthLogoutRequested
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: BorderSide(color: Colors.redAccent, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(Icons.logout_rounded, size: 18),
              label: Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared Widgets ───────────────────────────────────────────────────────────

  Widget _infoCard(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.fromBorderSide(BorderSide(color: Color(0xFF263151))),
      ),
      child: Column(
        children: rows
            .map(
              (r) => Column(
                children: [
                  r,
                  if (rows.last != r)
                    Divider(height: 1, indent: 52, color: Color(0xFF263151)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _badgeChip(String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          SizedBox(width: 14),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).textTheme.bodySmall?.color,
        letterSpacing: 1.2,
      ),
    );
  }
}
