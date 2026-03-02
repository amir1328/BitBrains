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
    if (isLoggedIn) {
      try {
        final user = await profileRepository.getProfile();
        emit(AuthAuthenticated(user));
      } catch (e) {
        // Token might be invalid
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
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
      // Filter out nulls
      data.removeWhere((key, value) => value == null);

      await authRepository.register(data);
      // Automatically login or ask user to login? Let's ask to login for now, or just auto-login.
      // For simplicity, let's just emit Unauthenticated with a success message?
      // Or auto login. Let's try auto login logic here or just tell UI to navigate.
      // Let's emit Unauthenticated so they can login.
      // Ideally we would return a "RegistrationSuccess" state, but for now:
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }
}
