import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/app_environment.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'router/app_router.dart';
import 'providers/auth_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // HACK 1: Hides the yellow overflow boxes globally
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const SizedBox.shrink();
  };

  // AppEnvironmentConfig.current reads Flutter's own appFlavor (set
  // directly by --flavor at build time) — throws immediately below if no
  // flavor was provided or it doesn't match a known environment, rather
  // than silently initializing against production.
  await Firebase.initializeApp(options: AppEnvironmentConfig.firebaseOptions);

  // Initialize notification
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
  } catch (e) {
    debugPrint('Notification init error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const GoJobsApp(),
    ),
  );
}

class GoJobsApp extends StatelessWidget {
  const GoJobsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: MaterialApp.router(
        title: 'GoJobs',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeProvider.themeMode,
        routerConfig: AppRouter.router,

        // HACK 2: Locks text scale to 1.0, ignoring Android phone settings
        builder: (context, child) {
          final scaled = MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
          // Non-prod visual indicator: catches a tester glancing at a
          // dev/staging build before they act on data they see in it.
          // Centralized here rather than per-screen, per the environment
          // design in docs/architecture/ENVIRONMENTS.md.
          if (AppEnvironmentConfig.current == AppEnvironment.prod) {
            return scaled;
          }
          return Banner(
            message: AppEnvironmentConfig.name.toUpperCase(),
            location: BannerLocation.topStart,
            color: AppEnvironmentConfig.current == AppEnvironment.dev
                ? Colors.green
                : Colors.orange,
            child: scaled,
          );
        },
      ),
    );
  }
}
