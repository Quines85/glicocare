import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:glicoare/core/router.dart';
import 'package:glicoare/core/theme/app_theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/cadastro',
      builder: (context, state) => const PatientFormScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const TodayScreen(),
    ),
    GoRoute(
      path: '/registro',
      builder: (context, state) => const ReadingFormScreen(),
    ),
    GoRoute(
      path: '/analysis',
      builder: (context, state) => const AnalysisScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GlicoCare',
      theme: appTheme,
      darkTheme: appTheme.copyWith(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      routerDelegate: router.delegate,
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routeInformationRedirectionStrategy: RouteInformationRedirectionStrategy.updateDisabled,
      navigatorKey: navigatorKey,
    );
  }
}