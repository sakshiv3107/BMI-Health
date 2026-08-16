//import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:assignment/features/auth/auth_provider.dart';
import 'package:assignment/features/auth/screens/login_screen.dart';
import 'package:assignment/features/auth/screens/signup_screen.dart';
import 'package:assignment/features/auth/forgot_password_screen.dart';
import 'package:assignment/features/home/screens/main_shell.dart';
import 'package:assignment/features/profile/screens/user_details_setup_screen.dart';
import 'package:assignment/features/profile/providers/profile_providers.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final profiles = ref.watch(allProfilesProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // If the authentication state is loading, don't redirect yet.
      if (authState.isLoading) return null;

      final isAuth = authState.valueOrNull != null;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot-password';

      if (!isAuth) {
        return isLoggingIn ? null : '/login';
      }

      // If logged in, check if user has set up at least one profile
      final hasProfile = profiles.isNotEmpty;
      if (!hasProfile) {
        if (state.matchedLocation != '/user-details') {
          return '/user-details';
        }
        return null;
      }

      // If user has a profile but tries to go to setup page, send to home
      if (state.matchedLocation == '/user-details') {
        return '/';
      }

      if (isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainShell(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/user-details',
        builder: (context, state) => const UserDetailsSetupScreen(),
      ),
    ],
  );
});
