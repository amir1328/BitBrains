import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/achievement_repository.dart';
import 'achievement_event.dart';
import 'achievement_state.dart';

class AchievementBloc extends Bloc<AchievementEvent, AchievementState> {
  final AchievementRepository repository;

  AchievementBloc({required this.repository}) : super(AchievementInitial()) {
    on<LoadAchievements>(_onLoadAchievements);
    on<CreateAchievement>(_onCreateAchievement);
  }

  Future<void> _onLoadAchievements(
    LoadAchievements event,
    Emitter<AchievementState> emit,
  ) async {
    emit(AchievementLoading());
    try {
      final achievements = await repository.getAchievements();
      emit(AchievementLoaded(achievements: achievements));
    } catch (e) {
      emit(AchievementError(e.toString()));
    }
  }

  Future<void> _onCreateAchievement(
    CreateAchievement event,
    Emitter<AchievementState> emit,
  ) async {
    emit(AchievementLoading());
    try {
      final data = {
        "title": event.title,
        "description": event.description,
        "date": event.date,
        "category": event.category,
      };
      await repository.createAchievement(data);
      emit(AchievementCreatedSuccess());
      add(LoadAchievements());
    } catch (e) {
      emit(AchievementError(e.toString()));
    }
  }
}
