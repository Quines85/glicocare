import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glicoare/app.dart';

void main() {
  runApp(const MyApp());
}

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
    );
  }
}