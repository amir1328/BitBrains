import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  final String role; // student, staff, etc.
  final String? department;
  final int? year;
  final String? rollNumber;

  const AuthRegisterRequested({
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    this.department,
    this.year,
    this.rollNumber,
  });
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}
