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
      // We don't reload here automatically because we might want to stay on the same screen context
      // The UI should trigger a reload if needed, or we could do it here if we had the context
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
}
