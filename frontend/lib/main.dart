import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/routes.dart';
import 'core/theme/app_theme.dart';
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

void main() {
  setupServiceLocator();
  runApp(const BitBrainsApp());
}

class BitBrainsApp extends StatelessWidget {
  const BitBrainsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
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
        theme: AppTheme.darkTheme,
        routerConfig: router,
      ),
    );
  }
}
