import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authStateSubscription;

  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    _initializeAuth();
  }

  void _initializeAuth() {
    _authStateSubscription = _authRepository.authStateChanges.listen(
      (User? firebaseUser) {
        if (firebaseUser != null) {
          final user = UserModel(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            username: firebaseUser.displayName ?? 'Unknown User',
            avatarUrl: firebaseUser.photoURL ?? '',
          );
          emit(AuthAuthenticated(user: user));
        } else {
          emit(const AuthUnauthenticated());
        }
      },
      onError: (Object error) {
        emit(AuthError(message: error.toString()));
      },
    );
  }

  Future<void> signInWithGoogle() async {
    try {
      emit(const AuthLoading());
      await _authRepository.signInWithGoogle();
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      emit(const AuthLoading());
      await _authRepository.signOut();
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  String? get currentUserId {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.user.id;
    }
    return null;
  }

  bool get isAuthenticated => state is AuthAuthenticated;

  bool get isLoading => state is AuthLoading;

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
