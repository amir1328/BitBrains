import 'package:equatable/equatable.dart';

abstract class MaterialEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class MaterialsLearned extends MaterialEvent {
  final String? course;
  final int? semester;

  MaterialsLearned({this.course, this.semester});
}

class DeleteMaterial extends MaterialEvent {
  final int materialId;

  DeleteMaterial(this.materialId);

  @override
  List<Object> get props => [materialId];
}

abstract class StudyMaterialState extends Equatable {
  @override
  List<Object> get props => [];
}

class MaterialInitial extends StudyMaterialState {}

class MaterialLoading extends StudyMaterialState {}

class MaterialLoaded extends StudyMaterialState {
  final List<Map<String, dynamic>> materials;

  MaterialLoaded(this.materials);
}

class MaterialError extends StudyMaterialState {
  final String message;

  MaterialError(this.message);
}
