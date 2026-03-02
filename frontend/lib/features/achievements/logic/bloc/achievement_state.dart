import 'package:equatable/equatable.dart';

abstract class AchievementState extends Equatable {
  const AchievementState();

  @override
  List<Object> get props => [];
}

class AchievementInitial extends AchievementState {}

class AchievementLoading extends AchievementState {}

class AchievementLoaded extends AchievementState {
  final List<Map<String, dynamic>> achievements;

  const AchievementLoaded({this.achievements = const []});

  @override
  List<Object> get props => [achievements];
}

class AchievementError extends AchievementState {
  final String message;

  const AchievementError(this.message);

  @override
  List<Object> get props => [message];
}

class AchievementCreatedSuccess extends AchievementState {}
