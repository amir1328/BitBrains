import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/auth_repository.dart';
import '../../../../features/profile/data/profile_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;

  AuthBloc({required this.authRepository, required this.profileRepository})
    : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = await authRepository.isLoggedIn();
    if (!isLoggedIn) {
      emit(AuthUnauthenticated());
      return;
    }

    // ── Cache-first: emit instantly from cache, no network wait ──────────────
    final cachedUser = await authRepository.getCachedUser();
    if (cachedUser != null) {
      emit(AuthAuthenticated(cachedUser)); // ← instant, no delay
    }

    // ── Background refresh from network (silently updates state) ─────────────
    try {
      final freshUser = await profileRepository.getProfile();
      await authRepository.saveUserCache(freshUser); // keep cache fresh
      emit(AuthAuthenticated(freshUser));
    } catch (e) {
      // Network failed, but we already emitted from cache — user is still in
      if (cachedUser == null) {
        // No cache and network failed → force logout
        await authRepository.logout();
        emit(AuthUnauthenticated());
      }
      // If cache existed, leave the authenticated state as-is
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.login(event.email, event.password);
      final user = await profileRepository.getProfile();
      await authRepository.saveUserCache(user); // cache for next launch
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final data = {
        "email": event.email,
        "password": event.password,
        "full_name": event.fullName,
        "role": event.role,
        "department": event.department,
        "year": event.year,
        "roll_number": event.rollNumber,
      };
      data.removeWhere((key, value) => value == null);
      await authRepository.register(data);
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout(); // also clears user cache
    emit(AuthUnauthenticated());
  }
}
