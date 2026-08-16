import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:assignment/features/auth/auth_provider.dart';
import 'package:assignment/features/auth/screens/login_screen.dart';
import 'package:assignment/features/auth/screens/signup_screen.dart';
import 'package:assignment/features/auth/forgot_password_screen.dart';
import 'package:assignment/features/auth/screens/onboarding_screen.dart';
import 'package:assignment/features/home/screens/main_shell.dart';
import 'package:assignment/features/profile/screens/user_details_form_screen.dart';
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
      final hasSeenOnboarding = Hive.box('settings').get('has_seen_onboarding', defaultValue: false) as bool;

      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/onboarding';

      if (!isAuth) {
        if (!hasSeenOnboarding) {
          return state.matchedLocation == '/onboarding' ? null : '/onboarding';
        }
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
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
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
        builder: (context, state) {
          final profileId = state.uri.queryParameters['profileId'];
          return UserDetailsFormScreen(profileId: profileId);
        },
      ),
    ],
  );
});
