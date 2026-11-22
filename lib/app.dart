import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/backend.dart';
import 'screens/chats_screen.dart';
import 'screens/login_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

class FamilyApp extends StatefulWidget {
  const FamilyApp({super.key, required this.backend});

  final Backend backend;

  @override
  State<FamilyApp> createState() => _FamilyAppState();
}

class _FamilyAppState extends State<FamilyApp> {
  late final AppState _state = AppState(widget.backend);

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  Widget _home() {
    if (!_state.authReady) {
      return const _Splash(key: ValueKey('splash'));
    }
    return _state.loggedIn
        ? const ChatsScreen(key: ValueKey('chats'))
        : const LoginScreen(key: ValueKey('login'));
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: ListenableBuilder(
        listenable: _state,
        builder: (context, _) {
          return MaterialApp(
            title: 'پیام‌رسان خانواده',
            debugShowCheckedModeBanner: false,
            locale: const Locale('fa'),
            supportedLocales: const [Locale('fa')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: buildTheme(Brightness.light),
            darkTheme: buildTheme(Brightness.dark),
            themeMode: _state.themeMode,
            home: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _home(),
            ),
          );
        },
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
