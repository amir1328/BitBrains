import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
// To access getIt defined in main or service locator
// Actually let me look at service locator path: lib/helpers/service_locator.dart is common, or main.dart.
// The lint said `../../../../helpers/service_locator.dart` was unused. That means it WAS imported but `getIt` comes from `kiwi` or `get_it`.
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<bool?> showAddUserSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddUserSheet(),
  );
}

class _AddUserSheet extends StatefulWidget {
  const _AddUserSheet();

  @override
  State<_AddUserSheet> createState() => _AddUserSheetState();
}

class _AddUserSheetState extends State<_AddUserSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _rollCtrl = TextEditingController();

  String _selectedRole = 'student';
  bool _isLoading = false;
  String? _errorMsg;
  bool _obscurePass = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _rollCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final api = getIt<ApiClient>();
      await api.dio.post(
        '/auth/register',
        data: {
          'full_name': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'password': _passCtrl.text,
          'role': _selectedRole,
          'department': 'AI&DS', // Fixed for this app
          'year': _selectedRole == 'student' ? 1 : null,
          'roll_number': _selectedRole == 'student'
              ? _rollCtrl.text.trim()
              : null,
        },
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMsg = e.toString().contains('Exception:')
            ? e.toString().split('Exception: ').last
            : 'Failed to create user. Check connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFF263151)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFF263151),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              ShaderMask(
                shaderCallback: (b) => LinearGradient(
                  colors: [AppColors.primary, AppColors.accentLight],
                ).createShader(b),
                child: Text(
                  'Add New User',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Create a new account for the department',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              SizedBox(height: 24),

              // Role Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                dropdownColor: Theme.of(context).colorScheme.primaryContainer,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  labelText: 'User Role',
                  prefixIcon: Icon(Icons.badge_outlined, size: 18),
                ),
                items: [
                  DropdownMenuItem(value: 'student', child: Text('Student')),
                  DropdownMenuItem(
                    value: 'staff',
                    child: Text('Faculty / Staff'),
                  ),
                  DropdownMenuItem(value: 'alumni', child: Text('Alumni')),
                  DropdownMenuItem(value: 'hod', child: Text('HOD')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
              SizedBox(height: 14),

              // Name
              TextFormField(
                controller: _nameCtrl,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline, size: 18),
                ),
                validator: (v) =>
                    v!.trim().length < 2 ? 'Required (min 2 chars)' : null,
              ),
              SizedBox(height: 14),

              // Email
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined, size: 18),
                ),
                validator: (v) => v!.contains('@') ? null : 'Enter valid email',
              ),
              SizedBox(height: 14),

              // Student Roll Number (Conditional)
              if (_selectedRole == 'student') ...[
                TextFormField(
                  controller: _rollCtrl,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Roll Number',
                    prefixIcon: Icon(Icons.pin_outlined, size: 18),
                  ),
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Required for students' : null,
                ),
                SizedBox(height: 14),
              ],

              // Password
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscurePass,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  labelText: 'Temporary Password',
                  prefixIcon: Icon(Icons.lock_outline, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePass
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                ),
                validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
              ),

              if (_errorMsg != null) ...[
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 14,
                      color: Colors.redAccent,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _errorMsg!,
                        style: TextStyle(color: Colors.redAccent, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: GestureDetector(
                  onTap: _isLoading ? null : _submit,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _isLoading
                          ? null
                          : LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                            ),
                      color: _isLoading
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: _isLoading
                          ? []
                          : [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 14,
                                offset: Offset(0, 5),
                              ),
                            ],
                    ),
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_add_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Create Account',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
