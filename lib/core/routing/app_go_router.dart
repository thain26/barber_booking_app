import 'package:baberbookingapp/core/presentation/bottom_nav.dart';
import 'package:baberbookingapp/core/routing/app_routes.dart';
import 'package:baberbookingapp/features/appointments/presentation/pages/appointment_form_page.dart';
import 'package:baberbookingapp/features/auth/presentation/login_page.dart';
import 'package:baberbookingapp/features/auth/presentation/signup_page.dart';
import 'package:baberbookingapp/features/home/pages/home_page.dart';
import 'package:baberbookingapp/features/profile/presentation/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/appointments/presentation/pages/appointment_list_page.dart';
import 'go_router_refresh_change.dart';

class AppGoRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          int currentIndex = _getIndexForLocation(state.matchedLocation);
          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNav(initialIndex: currentIndex),
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.appointments,
            builder: (context, state) => const AppointmentListPage(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: AppRoutes.bookAppointment,
            builder: (context, state) => AppointmentFormPage(
              serviceDetails: state.extra as Map<String, dynamic>?,
            ),
          )
        ],
      ),
    ],
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final loggedIn = user != null;
      final loggingIn = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup;
      if (!loggedIn && !loggingIn) return AppRoutes.login;
      if (loggedIn && loggingIn) return AppRoutes.home;
      return null;
    },
    refreshListenable:
        GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  );

  static int _getIndexForLocation(String path) {
    if (path.startsWith(AppRoutes.home)) {
      return 0;
    } else if (path.startsWith(AppRoutes.appointments)) {
      return 1;
    } else if (path.startsWith(AppRoutes.profile)) {
      return 2;
    }
    return 0;
  }
}
