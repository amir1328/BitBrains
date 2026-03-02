import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/material_repository.dart';
import 'material_bloc_definitions.dart';

class MaterialBloc extends Bloc<MaterialEvent, StudyMaterialState> {
  final MaterialRepository repository;

  MaterialBloc({required this.repository}) : super(MaterialInitial()) {
    on<MaterialsLearned>(_onMaterialsLearned);
  }

  Future<void> _onMaterialsLearned(
    MaterialsLearned event,
    Emitter<StudyMaterialState> emit,
  ) async {
    emit(MaterialLoading());
    try {
      final materials = await repository.getMaterials(
        courseName: event.course,
        semester: event.semester,
      );
      emit(MaterialLoaded(materials));
    } catch (e) {
      emit(MaterialError(e.toString()));
    }
  }
}
