import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/timetable_repository.dart';
import 'timetable_event.dart';
import 'timetable_state.dart';

class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  final TimetableRepository repository;

  TimetableBloc({required this.repository}) : super(TimetableInitial()) {
    on<LoadTimetable>(_onLoadTimetable);
    on<AddTimetableEntry>(_onAddTimetableEntry);
    on<DeleteTimetableEntry>(_onDeleteTimetableEntry);
    on<UpdateTimetableEntry>(_onUpdateTimetableEntry);
  }

  Future<void> _onLoadTimetable(
    LoadTimetable event,
    Emitter<TimetableState> emit,
  ) async {
    emit(TimetableLoading());
    try {
      final entries = await repository.getTimetable(
        semester: event.semester,
        courseName: event.courseName,
      );
      emit(TimetableLoaded(entries));
    } catch (e) {
      emit(TimetableError(e.toString()));
    }
  }

  Future<void> _onAddTimetableEntry(
    AddTimetableEntry event,
    Emitter<TimetableState> emit,
  ) async {
    emit(TimetableLoading());
    try {
      await repository.createEntry(event.entry);
      emit(const TimetableOperationSuccess("Entry added successfully"));
      // Refresh timeline automatically
      add(
        LoadTimetable(
          semester: event.entry['semester'],
          courseName: event.entry['course_name'],
        ),
      );
    } catch (e) {
      emit(TimetableError(e.toString()));
    }
  }

  Future<void> _onDeleteTimetableEntry(
    DeleteTimetableEntry event,
    Emitter<TimetableState> emit,
  ) async {
    try {
      await repository.deleteEntry(event.id);
      add(
        LoadTimetable(semester: event.semester, courseName: event.courseName),
      );
    } catch (e) {
      emit(TimetableError(e.toString()));
    }
  }

  Future<void> _onUpdateTimetableEntry(
    UpdateTimetableEntry event,
    Emitter<TimetableState> emit,
  ) async {
    emit(TimetableLoading());
    try {
      await repository.updateEntry(event.id, event.entry);
      add(
        LoadTimetable(semester: event.semester, courseName: event.courseName),
      );
      emit(const TimetableOperationSuccess("Entry updated successfully"));
    } catch (e) {
      emit(TimetableError(e.toString()));
    }
  }
}
