import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/home/home_shell.dart';
import 'firebase_options.dart';
import '/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const WathiqApp());
}

class WathiqApp extends StatelessWidget {
  const WathiqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: AuthService.instance),
      ],
      child: MaterialApp(
        title: 'Wathiq',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('ar', ''),
        ],
        home: const SplashWrapper(),
      ),
    );
  }
}

/// This widget shows the splash for 2 seconds, then shows AppRoot
class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showSplash ? const SplashScreen() : const AppRoot();
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        // While Firebase auth is initializing
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // User is logged in
        if (snapshot.hasData) {
          return const HomeShell();
        }

        // User is not logged in
        return const AuthWrapper();
      },
    );
  }
}
