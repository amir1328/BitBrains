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
  final List<Map<String, dynamic>> jobs;

  const AlumniLoaded({this.alumni = const [], this.jobs = const []});

  AlumniLoaded copyWith({
    List<Map<String, dynamic>>? alumni,
    List<Map<String, dynamic>>? jobs,
  }) {
    return AlumniLoaded(alumni: alumni ?? this.alumni, jobs: jobs ?? this.jobs);
  }

  @override
  List<Object> get props => [alumni, jobs];
}

class AlumniError extends AlumniState {
  final String message;

  const AlumniError(this.message);

  @override
  List<Object> get props => [message];
}

class AlumniProfileUpdateSuccess extends AlumniState {}

class JobCreateSuccess extends AlumniState {}
