import 'package:flutter/material.dart';
import '../../data/timetable_model.dart';
import '../../../../core/theme/app_theme.dart';

class TimetableEntryForm extends StatefulWidget {
  final TimetableEntry? entry;
  final int semester;
  final String courseName;
  final String dayOfWeek;

  const TimetableEntryForm({
    super.key,
    this.entry,
    required this.semester,
    required this.courseName,
    required this.dayOfWeek,
  });

  @override
  State<TimetableEntryForm> createState() => _TimetableEntryFormState();
}

class _TimetableEntryFormState extends State<TimetableEntryForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _subjectController;
  late TextEditingController _teacherController;
  late TextEditingController _roomController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(
      text: widget.entry?.subject ?? '',
    );
    _teacherController = TextEditingController(
      text: widget.entry?.teacherName ?? '',
    );
    _roomController = TextEditingController(text: widget.entry?.roomNo ?? '');

    _startTime =
        _parseTime(widget.entry?.startTime) ?? TimeOfDay(hour: 9, minute: 0);
    _endTime =
        _parseTime(widget.entry?.endTime) ?? TimeOfDay(hour: 10, minute: 0);
  }

  TimeOfDay? _parseTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (_) {}
    return null;
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _teacherController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final initialTime = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'course_name': widget.courseName,
        'semester': widget.semester,
        'day_of_week': widget.dayOfWeek,
        'subject': _subjectController.text.trim(),
        'teacher_name': _teacherController.text.trim(),
        'room_no': _roomController.text.trim(),
        'start_time': _formatTime(_startTime),
        'end_time': _formatTime(_endTime),
      };

      Navigator.of(context).pop(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entry != null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Class' : 'Add Class',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Text(
                  '${widget.dayOfWeek} • Sem ${widget.semester} ${widget.courseName}',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // Subject Name
                TextFormField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    prefixIcon: const Icon(Icons.book_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Teacher Name
                TextFormField(
                  controller: _teacherController,
                  decoration: InputDecoration(
                    labelText: 'Teacher Name',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Room No
                TextFormField(
                  controller: _roomController,
                  decoration: InputDecoration(
                    labelText: 'Room Number',
                    prefixIcon: const Icon(Icons.room_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 20),

                // Time Pickers
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(context, true),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start Time',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _startTime.format(context),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(context, false),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'End Time',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _endTime.format(context),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Save Changes' : 'Add Class',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
