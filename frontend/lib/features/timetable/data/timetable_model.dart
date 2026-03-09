import 'package:equatable/equatable.dart';

class TimetableEntry extends Equatable {
  final int id;
  final String courseName;
  final int semester;
  final String dayOfWeek;
  final String subject;
  final String teacherName;
  final String roomNo;
  final String startTime;
  final String endTime;

  const TimetableEntry({
    required this.id,
    required this.courseName,
    required this.semester,
    required this.dayOfWeek,
    required this.subject,
    required this.teacherName,
    required this.roomNo,
    required this.startTime,
    required this.endTime,
  });

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      id: json['id'],
      courseName: json['course_name'],
      semester: json['semester'],
      dayOfWeek: json['day_of_week'],
      subject: json['subject'],
      teacherName: json['teacher_name'],
      roomNo: json['room_no'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }

  TimetableEntry copyWith({
    int? id,
    String? courseName,
    int? semester,
    String? dayOfWeek,
    String? subject,
    String? teacherName,
    String? roomNo,
    String? startTime,
    String? endTime,
  }) {
    return TimetableEntry(
      id: id ?? this.id,
      courseName: courseName ?? this.courseName,
      semester: semester ?? this.semester,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      subject: subject ?? this.subject,
      teacherName: teacherName ?? this.teacherName,
      roomNo: roomNo ?? this.roomNo,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  List<Object?> get props => [
    id,
    courseName,
    semester,
    dayOfWeek,
    subject,
    teacherName,
    roomNo,
    startTime,
    endTime,
  ];
}
