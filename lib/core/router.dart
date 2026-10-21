import 'package:go_router/go_router.dart';
import 'package:glicoare/features/onboarding/presentation/onboarding_screen.dart';
import 'package:glicoare/features/patient_form/presentation/patient_form_screen.dart';
import 'package:glicoare/features/today/presentation/today_screen.dart';
import 'package:glicoare/features/reading_form/presentation/reading_form_screen.dart';
import 'package:glicoare/features/analysis/presentation/analysis_screen.dart';
import 'package:glicoare/features/history/presentation/history_screen.dart';
import 'package:glicoare/features/settings/presentation/settings_screen.dart';

/// Roteador central usando go_router.
/// Todas as rotas são definidas aqui para manter o navegação consistente.
class AppRouter {
  final GoRouter router = GoRouter(
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
}