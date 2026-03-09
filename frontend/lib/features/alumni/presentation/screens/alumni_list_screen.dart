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

class _AlumniListScreenState extends State<AlumniListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  int? _filterYear;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<AlumniBloc>().add(LoadAlumni());
    context.read<AlumniBloc>().add(LoadJobs());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.accent,
                labelColor: AppColors.accent,
                unselectedLabelColor: Theme.of(
                  context,
                ).textTheme.bodySmall?.color,
                tabs: const [
                  Tab(text: 'Directory'),
                  Tab(text: 'Opportunities'),
                ],
              ),
              SizedBox(height: 12),
              Expanded(
                child: BlocConsumer<AlumniBloc, AlumniState>(
                  listener: (context, state) {
                    if (state is AlumniProfileUpdateSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Profile updated!')),
                      );
                    } else if (state is JobCreateSuccess) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Job posted!')));
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
                      return TabBarView(
                        controller: _tabController,
                        children: [
                          _buildDirectoryTab(state.alumni),
                          _buildOpportunitiesTab(state.jobs),
                        ],
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
      floatingActionButton: widget.canEdit
          ? FloatingActionButton.extended(
              onPressed: _showPostJobDialog,
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              icon: Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'Post Job',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDirectoryTab(List<Map<String, dynamic>> alumni) {
    var filteredAlumni = alumni;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredAlumni = filteredAlumni.where((alum) {
        final name = (alum['user_name'] as String?)?.toLowerCase() ?? '';
        final company =
            (alum['current_company'] as String?)?.toLowerCase() ?? '';
        final title = (alum['job_title'] as String?)?.toLowerCase() ?? '';
        return name.contains(query) ||
            company.contains(query) ||
            title.contains(query);
      }).toList();
    }
    if (_filterYear != null) {
      filteredAlumni = filteredAlumni
          .where((alum) => alum['graduation_year'] == _filterYear)
          .toList();
    }

    final years =
        alumni
            .map((a) => a['graduation_year'] as int?)
            .where((y) => y != null)
            .toSet()
            .toList()
            .cast<int>()
          ..sort((a, b) => b.compareTo(a));

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search explicitly (e.g. Google, Data Scientist)',
                    prefixIcon: Icon(Icons.search_rounded, size: 18),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              if (years.isNotEmpty) ...[
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: PopupMenuButton<int?>(
                    initialValue: _filterYear,
                    icon: Icon(
                      Icons.filter_list_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    onSelected: (int? val) {
                      setState(() => _filterYear = val);
                    },
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem<int?>(
                          value: null,
                          child: Text('All Years'),
                        ),
                        ...years.map(
                          (y) => PopupMenuItem<int?>(
                            value: y,
                            child: Text('Class of $y'),
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: filteredAlumni.isEmpty
              ? _buildEmptyState(
                  'No matches found',
                  'Try adjusting your search or filters',
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    context.read<AlumniBloc>().add(LoadAlumni());
                  },
                  color: AppColors.accent,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: filteredAlumni.length,
                    itemBuilder: (ctx, i) => _AlumniCard(
                      alum: filteredAlumni[i],
                      onLinkedIn: (url) => _launchUrl(url),
                      onEmail: (email) => _launchUrl('mailto:$email'),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildOpportunitiesTab(List<Map<String, dynamic>> jobs) {
    if (jobs.isEmpty) {
      return _buildEmptyState(
        'No opportunities yet',
        'Jobs posted by alumni will appear here',
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AlumniBloc>().add(LoadJobs());
      },
      color: AppColors.accent,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: jobs.length,
        itemBuilder: (ctx, i) =>
            _JobCard(job: jobs[i], onApply: (url) => _launchUrl(url)),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
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
            title,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _showPostJobDialog() {
    final titleController = TextEditingController();
    final companyController = TextEditingController();
    final urlController = TextEditingController();
    final descriptionController = TextEditingController();

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
                        colors: [AppColors.accent, AppColors.timeAfternoon],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.work_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 14),
                  Text(
                    'Post Opportunity',
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
                controller: titleController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'Job/Opportunity Title',
                  prefixIcon: Icon(Icons.work_outline_rounded),
                ),
              ),
              SizedBox(height: 14),
              TextField(
                controller: companyController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'Company',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
              ),
              SizedBox(height: 14),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'Description / Note to students',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              SizedBox(height: 14),
              TextField(
                controller: urlController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'Apply URL (Optional)',
                  prefixIcon: Icon(Icons.link_rounded),
                ),
              ),
              SizedBox(height: 24),
              GradientButton(
                label: 'Post Job',
                icon: Icons.send_rounded,
                onPressed: () {
                  if (titleController.text.isEmpty ||
                      companyController.text.isEmpty ||
                      descriptionController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please fill out Title, Company and Description.',
                        ),
                      ),
                    );
                    return;
                  }
                  context.read<AlumniBloc>().add(
                    CreateJob({
                      'title': titleController.text,
                      'company': companyController.text,
                      'description': descriptionController.text,
                      if (urlController.text.isNotEmpty)
                        'apply_url': urlController.text,
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

class _JobCard extends StatelessWidget {
  final Map job;
  final void Function(String) onApply;
  const _JobCard({required this.job, required this.onApply});

  @override
  Widget build(BuildContext context) {
    final title = job['title'] ?? 'Role';
    final company = job['company'] ?? 'Company';
    final description = job['description'] ?? '';
    final applyUrl = job['apply_url'];
    final alumniName = job['alumni_name'] ?? 'Alumni';

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.fromBorderSide(
          BorderSide(color: Color(0xFF263151), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accent, AppColors.timeAfternoon],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    Icons.business_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      company,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          SizedBox(height: 14),
          Divider(color: Color(0xFF263151), height: 1),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Posted by $alumniName',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              if (applyUrl != null && applyUrl.toString().trim().isNotEmpty)
                InkWell(
                  onTap: () => onApply(applyUrl),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Apply',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: AppColors.accent,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
