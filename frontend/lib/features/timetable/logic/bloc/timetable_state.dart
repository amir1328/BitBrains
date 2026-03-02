import 'package:equatable/equatable.dart';
import '../../data/timetable_model.dart';

abstract class TimetableState extends Equatable {
  const TimetableState();

  @override
  List<Object> get props => [];
}

class TimetableInitial extends TimetableState {}

class TimetableLoading extends TimetableState {}

class TimetableLoaded extends TimetableState {
  final List<TimetableEntry> entries;

  const TimetableLoaded(this.entries);

  @override
  List<Object> get props => [entries];
}

class TimetableError extends TimetableState {
  final String message;

  const TimetableError(this.message);

  @override
  List<Object> get props => [message];
}

class TimetableOperationSuccess extends TimetableState {
  final String message;

  const TimetableOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}
