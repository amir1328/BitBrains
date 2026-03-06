import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/bloc/material_bloc.dart';
import '../../logic/bloc/material_bloc_definitions.dart';
import '../../../../core/theme/app_theme.dart';

/// Shows the upload bottom sheet and returns true if upload succeeded.
Future<bool?> showUploadMaterialSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<MaterialBloc>(),
      child: _UploadSheet(),
    ),
  );
}

class _UploadSheet extends StatefulWidget {
  const _UploadSheet();

  @override
  State<_UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends State<_UploadSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _courseCtrl = TextEditingController(text: 'AI&DS');
  final _semCtrl = TextEditingController(text: '5');

  PlatformFile? _pickedFile;
  bool _uploading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _courseCtrl.dispose();
    _semCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'ppt',
        'pptx',
        'txt',
        'png',
        'jpg',
      ],
      withData: false,
      withReadStream: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedFile = result.files.first);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedFile == null) {
      setState(() => _errorMsg = 'Please select a file to upload.');
      return;
    }
    if (_pickedFile!.path == null) {
      setState(() => _errorMsg = 'Could not read file path. Try again.');
      return;
    }

    setState(() {
      _uploading = true;
      _errorMsg = null;
    });

    try {
      final ds = context.read<MaterialBloc>().remoteDataSource;
      await ds.uploadMaterial(
        title: _titleCtrl.text.trim(),
        courseName: _courseCtrl.text.trim(),
        semester: int.tryParse(_semCtrl.text.trim()) ?? 5,
        description: _descCtrl.text.trim(),
        filePath: _pickedFile!.path!,
        fileName: _pickedFile!.name,
      );
      // Refresh the materials list
      if (mounted) {
        context.read<MaterialBloc>().add(MaterialsLearned());
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _uploading = false;
        _errorMsg = e.toString().replaceFirst('Exception: ', '');
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

              // Title
              ShaderMask(
                shaderCallback: (b) => LinearGradient(
                  colors: [AppColors.primary, AppColors.accentLight],
                ).createShader(b),
                child: Text(
                  'Upload Material',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Fill in details and attach a file',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              SizedBox(height: 24),

              // Title field
              _field(
                _titleCtrl,
                'Title',
                Icons.title_rounded,
                hint: 'e.g. Unit 3 – Neural Networks',
              ),

              SizedBox(height: 14),

              // Description
              _field(
                _descCtrl,
                'Description (optional)',
                Icons.notes_rounded,
                maxLines: 2,
                required: false,
              ),

              SizedBox(height: 14),

              // Course + Semester row
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _courseCtrl,
                      'Course',
                      Icons.apartment_rounded,
                    ),
                  ),
                  SizedBox(width: 12),
                  SizedBox(
                    width: 90,
                    child: _field(
                      _semCtrl,
                      'Sem',
                      Icons.school_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // File picker
              GestureDetector(
                onTap: _uploading ? null : _pickFile,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _pickedFile != null
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _pickedFile != null
                          ? AppColors.primary.withValues(alpha: 0.4)
                          : Color(0xFF263151),
                    ),
                  ),
                  child: _pickedFile == null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.attach_file_rounded,
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Tap to select a file',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _fileIcon(_pickedFile!.extension),
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _pickedFile!.name,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _formatSize(_pickedFile!.size),
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.color,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _pickedFile = null),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              // Error
              if (_errorMsg != null) ...[
                SizedBox(height: 12),
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

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: GestureDetector(
                  onTap: _uploading ? null : _submit,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _uploading
                          ? null
                          : LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                            ),
                      color: _uploading
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: _uploading
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
                      child: _uploading
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
                                  Icons.cloud_upload_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Upload Material',
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

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    String? hint,
    int maxLines = 1,
    bool required = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 14,
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  IconData _fileIcon(String? ext) {
    switch (ext?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Icons.image_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
