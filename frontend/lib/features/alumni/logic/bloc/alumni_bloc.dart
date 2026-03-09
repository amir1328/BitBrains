import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/alumni_repository.dart';
import 'alumni_event.dart';
import 'alumni_state.dart';

class AlumniBloc extends Bloc<AlumniEvent, AlumniState> {
  final AlumniRepository repository;

  AlumniBloc({required this.repository}) : super(AlumniInitial()) {
    on<LoadAlumni>(_onLoadAlumni);
    on<UpdateAlumniProfile>(_onUpdateAlumniProfile);
    on<LoadJobs>(_onLoadJobs);
    on<CreateJob>(_onCreateJob);
  }

  Future<void> _onLoadAlumni(
    LoadAlumni event,
    Emitter<AlumniState> emit,
  ) async {
    emit(AlumniLoading());
    try {
      final alumni = await repository.getAlumni();
      if (state is AlumniLoaded) {
        emit((state as AlumniLoaded).copyWith(alumni: alumni));
      } else {
        emit(AlumniLoaded(alumni: alumni));
      }
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

  Future<void> _onLoadJobs(LoadJobs event, Emitter<AlumniState> emit) async {
    emit(AlumniLoading());
    try {
      final jobs = await repository.getJobs();
      if (state is AlumniLoaded) {
        emit((state as AlumniLoaded).copyWith(jobs: jobs));
      } else {
        emit(AlumniLoaded(jobs: jobs));
      }
    } catch (e) {
      emit(AlumniError(e.toString()));
    }
  }

  Future<void> _onCreateJob(CreateJob event, Emitter<AlumniState> emit) async {
    emit(AlumniLoading());
    try {
      await repository.createJob(event.data);
      emit(JobCreateSuccess());
      add(LoadJobs());
    } catch (e) {
      emit(AlumniError(e.toString()));
    }
  }
}
