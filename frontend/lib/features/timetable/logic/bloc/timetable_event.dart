import 'package:equatable/equatable.dart';

abstract class TimetableEvent extends Equatable {
  const TimetableEvent();

  @override
  List<Object> get props => [];
}

class LoadTimetable extends TimetableEvent {
  final int semester;
  final String courseName;

  const LoadTimetable({required this.semester, required this.courseName});

  @override
  List<Object> get props => [semester, courseName];
}

class AddTimetableEntry extends TimetableEvent {
  final Map<String, dynamic> entry;

  const AddTimetableEntry(this.entry);

  @override
  List<Object> get props => [entry];
}

class DeleteTimetableEntry extends TimetableEvent {
  final int id;
  final int semester;
  final String courseName;

  const DeleteTimetableEntry({
    required this.id,
    required this.semester,
    required this.courseName,
  });

  @override
  List<Object> get props => [id, semester, courseName];
}
