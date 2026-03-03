import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/logic/bloc/auth_bloc.dart';
import '../features/auth/logic/bloc/auth_state.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/materials/presentation/screens/material_list_screen.dart';
import '../features/group_chat/presentation/screens/group_chat_screen.dart';
import '../features/achievements/presentation/screens/achievement_screen.dart';

/// Notifier that converts a Bloc stream into a ChangeNotifier
/// so GoRouter can refresh when auth state changes.
class _BlocChangeNotifier<B extends BlocBase<S>, S> extends ChangeNotifier {
  final B bloc;
  late final StreamSubscription<S> _sub;

  _BlocChangeNotifier(this.bloc) {
    _sub = bloc.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

GoRouter createRouter(AuthBloc authBloc) {
  final refreshNotifier = _BlocChangeNotifier(authBloc);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoggedIn = authState is AuthAuthenticated;
      final isAuthLoading =
          authState is AuthInitial || authState is AuthLoading;

      final onAuthPage =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Still checking — don't redirect yet
      if (isAuthLoading) return null;

      // Logged in but on auth pages → go home
      if (isLoggedIn && onAuthPage) return '/home';

      // Not logged in and not on auth page → go to login
      if (!isLoggedIn && !onAuthPage) return '/login';

      return null; // no redirect needed
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeShell()),
      GoRoute(
        path: '/group-chat/:roomId',
        builder: (context, state) {
          final roomId = state.pathParameters['roomId'] ?? 'general';
          return GroupChatScreen(roomId: roomId);
        },
      ),
      GoRoute(
        path: '/achievements',
        builder: (context, state) => const AchievementScreen(),
      ),
    ],
  );
}
