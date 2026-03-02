import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/materials/presentation/screens/material_list_screen.dart';
import '../features/group_chat/presentation/screens/group_chat_screen.dart';
import '../features/achievements/presentation/screens/achievement_screen.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    // Home now uses the HomeShell which hosts all bottom nav screens
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
