import 'package:equatable/equatable.dart';

abstract class AlumniEvent extends Equatable {
  const AlumniEvent();

  @override
  List<Object> get props => [];
}

class LoadAlumni extends AlumniEvent {}

class UpdateAlumniProfile extends AlumniEvent {
  final Map<String, dynamic> data;

  const UpdateAlumniProfile(this.data);

  @override
  List<Object> get props => [data];
}
