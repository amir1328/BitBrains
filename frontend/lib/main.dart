import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/routes.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'helpers/service_locator.dart';
import 'features/auth/logic/bloc/auth_bloc.dart';
import 'features/auth/logic/bloc/auth_event.dart';
import 'features/materials/logic/bloc/material_bloc.dart';
import 'features/chat/logic/bloc/chat_bloc.dart';
import 'features/timetable/logic/bloc/timetable_bloc.dart';
import 'features/profile/logic/bloc/profile_bloc.dart';
import 'features/group_chat/logic/bloc/group_chat_bloc.dart';
import 'features/achievements/logic/bloc/achievement_bloc.dart';
import 'features/alumni/logic/bloc/alumni_bloc.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notification service
  await NotificationService().initialize();

  setupServiceLocator();
  runApp(const BitBrainsApp());
}

class BitBrainsApp extends StatefulWidget {
  const BitBrainsApp({super.key});

  @override
  State<BitBrainsApp> createState() => _BitBrainsAppState();
}

class _BitBrainsAppState extends State<BitBrainsApp> {
  late final AuthBloc _authBloc;
  late final dynamic router;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>()..add(AuthCheckRequested());
    router = createRouter(_authBloc);

    // Handle notification taps — navigate user appropriately
    NotificationService().onNotificationTap = (data) {
      final type = data['type'];
      if (type == 'new_material') {
        router.go('/home');
      } else if (type == 'group_message') {
        final roomId = data['room_id'] ?? 'general';
        router.go('/group-chat/$roomId');
      }
    };
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<MaterialBloc>(create: (_) => sl<MaterialBloc>()),
        BlocProvider<ChatBloc>(create: (_) => sl<ChatBloc>()),
        BlocProvider<TimetableBloc>(create: (_) => sl<TimetableBloc>()),
        BlocProvider<ProfileBloc>(create: (_) => sl<ProfileBloc>()),
        BlocProvider<GroupChatBloc>(create: (_) => sl<GroupChatBloc>()),
        BlocProvider<AchievementBloc>(create: (_) => sl<AchievementBloc>()),
        BlocProvider<AlumniBloc>(create: (_) => sl<AlumniBloc>()),
      ],
      child: MaterialApp.router(
        title: 'BitBrains',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: router,
      ),
    );
  }
}
