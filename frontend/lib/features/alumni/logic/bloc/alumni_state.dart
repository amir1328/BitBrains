import 'package:equatable/equatable.dart';

abstract class AlumniState extends Equatable {
  const AlumniState();

  @override
  List<Object> get props => [];
}

class AlumniInitial extends AlumniState {}

class AlumniLoading extends AlumniState {}

class AlumniLoaded extends AlumniState {
  final List<Map<String, dynamic>> alumni;

  const AlumniLoaded({this.alumni = const []});

  @override
  List<Object> get props => [alumni];
}

class AlumniError extends AlumniState {
  final String message;

  const AlumniError(this.message);

  @override
  List<Object> get props => [message];
}

class AlumniProfileUpdateSuccess extends AlumniState {}
