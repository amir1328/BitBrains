import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../logic/bloc/profile_bloc.dart';
import '../../logic/bloc/profile_event.dart';
import '../../logic/bloc/profile_state.dart';
import '../../../../core/theme/app_theme.dart';

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded && !_isEditing) {
            _bioController.text = state.user['bio'] ?? '';
            _phoneController.text = state.user['phone_number'] ?? '';
            _yearController.text = (state.user['year'] ?? '').toString();
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const GradientBackground(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          } else if (state is ProfileLoaded) {
            final user = state.user;
            return GradientBackground(
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeroHeader(context, user),
                      _buildInfoSection(user),
                      if (_isEditing) _buildEditSection(),
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
            );
          }
          return const GradientBackground(
            child: Center(
              child: Text(
                'Loading profile...',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, Map<dynamic, dynamic> user) {
    final initials = (user['full_name'] as String? ?? 'U')
        .substring(0, 1)
        .toUpperCase();
    final role = (user['role'] as String? ?? 'student').toUpperCase();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF263151))),
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
              ),
              if (_isEditing)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user['full_name'] ?? 'Guest',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _badgeChip(role, AppColors.primary),
              if (user['department'] != null) ...[
                const SizedBox(width: 8),
                _badgeChip(user['department'], AppColors.accent),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            user['email'] ?? '',
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Map<dynamic, dynamic> user) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('Account Info'),
          const SizedBox(height: 12),
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
          const SizedBox(height: 20),
          const _SectionLabel('Bio'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: const Border.fromBorderSide(
                BorderSide(color: Color(0xFF263151)),
              ),
            ),
            child: Text(
              user['bio'] ?? 'No bio added yet.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('Edit Profile'),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Year of Study',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _bioController,
                  maxLines: 3,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    prefixIcon: Icon(Icons.notes_rounded),
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        children: [
          GradientButton(
            label: _isEditing ? 'Save Changes' : 'Edit Profile',
            icon: _isEditing ? Icons.save_rounded : Icons.edit_rounded,
            onPressed: () {
              if (_isEditing) {
                context.read<ProfileBloc>().add(
                  UpdateProfile({
                    'bio': _bioController.text,
                    'phone_number': _phoneController.text,
                    if (_yearController.text.isNotEmpty)
                      'year': int.tryParse(_yearController.text),
                  }),
                );
              }
              setState(() => _isEditing = !_isEditing);
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => context.go('/login'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0xFF263151)),
        ),
      ),
      child: Column(
        children: rows
            .map(
              (r) => Column(
                children: [
                  r,
                  if (rows.last != r) const Divider(height: 1, indent: 52),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _badgeChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
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
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 1.2,
      ),
    );
  }
}
