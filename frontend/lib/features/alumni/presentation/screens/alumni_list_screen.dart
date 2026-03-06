import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../logic/bloc/alumni_bloc.dart';
import '../../logic/bloc/alumni_event.dart';
import '../../logic/bloc/alumni_state.dart';
import '../../../../core/theme/app_theme.dart';

class AlumniListScreen extends StatefulWidget {
  final bool canEdit;

  const AlumniListScreen({super.key, this.canEdit = false});

  @override
  State<AlumniListScreen> createState() => _AlumniListScreenState();
}

class _AlumniListScreenState extends State<AlumniListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AlumniBloc>().add(LoadAlumni());
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open $urlString')));
      }
    }
  }

  void _showUpdateProfileDialog() {
    final companyController = TextEditingController();
    final titleController = TextEditingController();
    final yearController = TextEditingController();
    final linkedinController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.people_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 14),
                  Text(
                    'Update Alumni Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              TextField(
                controller: companyController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'Current Company',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
              ),
              SizedBox(height: 14),
              TextField(
                controller: titleController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'Job Title',
                  prefixIcon: Icon(Icons.work_outline_rounded),
                ),
              ),
              SizedBox(height: 14),
              TextField(
                controller: yearController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'Graduation Year',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
              ),
              SizedBox(height: 14),
              TextField(
                controller: linkedinController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'LinkedIn URL',
                  prefixIcon: Icon(Icons.link_rounded),
                ),
              ),
              SizedBox(height: 24),
              GradientButton(
                label: 'Save Profile',
                icon: Icons.save_rounded,
                onPressed: () {
                  context.read<AlumniBloc>().add(
                    UpdateAlumniProfile({
                      if (companyController.text.isNotEmpty)
                        'current_company': companyController.text,
                      if (titleController.text.isNotEmpty)
                        'job_title': titleController.text,
                      'graduation_year': int.tryParse(yearController.text),
                      if (linkedinController.text.isNotEmpty)
                        'linkedin_url': linkedinController.text,
                    }),
                  );
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
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
                            'Alumni Network',
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
                          'Connect with your seniors',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                    if (widget.canEdit)
                      GestureDetector(
                        onTap: _showUpdateProfileDialog,
                        child: Tooltip(
                          message: 'Update Alumni Profile',
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.fromBorderSide(
                                BorderSide(color: Color(0xFF263151)),
                              ),
                            ),
                            child: Icon(
                              Icons.edit_rounded,
                              size: 18,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Expanded(
                child: BlocConsumer<AlumniBloc, AlumniState>(
                  listener: (context, state) {
                    if (state is AlumniProfileUpdateSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Profile updated!')),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is AlumniLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    } else if (state is AlumniLoaded) {
                      if (state.alumni.isEmpty) {
                        return _buildEmptyState();
                      }
                      return ListView.builder(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: state.alumni.length,
                        itemBuilder: (ctx, i) => _AlumniCard(
                          alum: state.alumni[i],
                          onLinkedIn: (url) => _launchUrl(url),
                          onEmail: (email) => _launchUrl('mailto:$email'),
                        ),
                      );
                    } else if (state is AlumniError) {
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
            ],
          ),
        ),
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
              Icons.people_outline_rounded,
              size: 40,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'No alumni found',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Alumni will appear here once they register',
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

class _AlumniCard extends StatelessWidget {
  final Map alum;
  final void Function(String) onLinkedIn;
  final void Function(String) onEmail;
  const _AlumniCard({
    required this.alum,
    required this.onLinkedIn,
    required this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    final name = alum['user_name'] as String? ?? 'Alumni';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'A';
    final gradYear = alum['graduation_year'];

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.fromBorderSide(
          BorderSide(color: Color(0xFF263151), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (alum['job_title'] != null ||
                    alum['current_company'] != null) ...[
                  SizedBox(height: 3),
                  Text(
                    '${alum['job_title'] ?? 'N/A'} at ${alum['current_company'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 8),
                if (gradYear != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: AppColors.accent.withOpacity(0.25),
                      ),
                    ),
                    child: Text(
                      'Class of $gradYear',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              if (alum['linkedin_url'] != null)
                _actionButton(
                  Icons.link_rounded,
                  AppColors.primary,
                  () => onLinkedIn(alum['linkedin_url']),
                ),
              SizedBox(height: 6),
              if (alum['user_email'] != null)
                _actionButton(
                  Icons.email_outlined,
                  AppColors.accent,
                  () => onEmail(alum['user_email']),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
