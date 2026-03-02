import 'package:equatable/equatable.dart';

abstract class AchievementEvent extends Equatable {
  const AchievementEvent();

  @override
  List<Object> get props => [];
}

class LoadAchievements extends AchievementEvent {}

class CreateAchievement extends AchievementEvent {
  final String title;
  final String description;
  final String category;
  final String date;

  const CreateAchievement({
    required this.title,
    required this.description,
    required this.category,
    required this.date,
  });

  @override
  List<Object> get props => [title, description, category, date];
}
