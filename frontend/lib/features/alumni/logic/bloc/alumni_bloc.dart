import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/alumni_repository.dart';
import 'alumni_event.dart';
import 'alumni_state.dart';

class AlumniBloc extends Bloc<AlumniEvent, AlumniState> {
  final AlumniRepository repository;

  AlumniBloc({required this.repository}) : super(AlumniInitial()) {
    on<LoadAlumni>(_onLoadAlumni);
    on<UpdateAlumniProfile>(_onUpdateAlumniProfile);
  }

  Future<void> _onLoadAlumni(
    LoadAlumni event,
    Emitter<AlumniState> emit,
  ) async {
    emit(AlumniLoading());
    try {
      final alumni = await repository.getAlumni();
      emit(AlumniLoaded(alumni: alumni));
    } catch (e) {
      emit(AlumniError(e.toString()));
    }
  }

  Future<void> _onUpdateAlumniProfile(
    UpdateAlumniProfile event,
    Emitter<AlumniState> emit,
  ) async {
    emit(AlumniLoading());
    try {
      await repository.updateProfile(event.data);
      emit(AlumniProfileUpdateSuccess());
      add(LoadAlumni());
    } catch (e) {
      emit(AlumniError(e.toString()));
    }
  }
}
