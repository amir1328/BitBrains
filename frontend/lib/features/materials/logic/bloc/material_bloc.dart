import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/material_remote_data_source.dart';
import '../../data/material_repository.dart';
import 'material_bloc_definitions.dart';

class MaterialBloc extends Bloc<MaterialEvent, StudyMaterialState> {
  final MaterialRepository repository;

  MaterialBloc({required this.repository}) : super(MaterialInitial()) {
    on<MaterialsLearned>(_onMaterialsLearned);
    on<DeleteMaterial>(_onDeleteMaterial);
  }

  /// Exposed so the upload sheet can call uploadMaterial directly.
  MaterialRemoteDataSource get remoteDataSource => repository.remoteDataSource;

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

  Future<void> _onDeleteMaterial(
    DeleteMaterial event,
    Emitter<StudyMaterialState> emit,
  ) async {
    final currentState = state;
    if (currentState is MaterialLoaded) {
      try {
        await repository.deleteMaterial(event.materialId);
        // Remove from the local list instead of a full reload
        final updatedMaterials = currentState.materials
            .where((m) => m['id'] != event.materialId)
            .toList();

        emit(MaterialLoaded(updatedMaterials));
      } catch (e) {
        // Here we could emit an error state or a specific delete error state.
        // For simplicity, we fallback to the error state.
        emit(MaterialError(e.toString()));
      }
    }
  }
}
