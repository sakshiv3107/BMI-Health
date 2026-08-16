import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment/features/auth/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<void> {
  late AuthRepository _authRepository;

  @override
  Future<void> build() async{
    _authRepository = ref.watch(authRepositoryProvider);
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authRepository.signInWithEmail(email, password));
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authRepository.signUpWithEmail(email, password));
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authRepository.signInWithGoogle());
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authRepository.sendPasswordResetEmail(email));
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authRepository.signOut());
  }
}
