import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';

part 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  StreamSubscription<UserModel?>? _userDataSubscription;
  String? _currentUserId;

  UserProfileCubit(
      {required UserRepository userRepository,
      required AuthRepository authRepository,})
      : _userRepository = userRepository,
        _authRepository = authRepository,
        super(const UserProfileInitial()) {
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      final userId = _authRepository.currentUser!.uid;
      logman.info('loadUserProfile userId: $userId');
      if (_currentUserId == userId && state is UserProfileLoaded) {
        return;
      }

      _currentUserId = userId;
      emit(const UserProfileLoading());

      await _userDataSubscription?.cancel();

      _userDataSubscription = _userRepository.streamUserData(userId).listen(
        (UserModel? userData) {
          if (userData != null) {
            emit(UserProfileLoaded(user: userData));
          } else {
            emit(const UserProfileError(message: 'User profile not found'));
          }
        },
        onError: (Object error) {
          emit(UserProfileError(message: error.toString()));
        },
      );
    } catch (e) {
      emit(UserProfileError(message: e.toString()));
    }
  }

  Future<void> updateProfile({
    String? username,
    String? avatarUrl,
  }) async {
    try {
      final currentState = state;
      if (currentState is UserProfileLoaded) {
        emit(UserProfileUpdating(currentUser: currentState.user));
      }

      await _userRepository.updateUserProfile(
        username: username,
        avatarUrl: avatarUrl,
      );
    } catch (e) {
      final currentState = state;
      if (currentState is UserProfileUpdating) {
        emit(UserProfileLoaded(user: currentState.currentUser));
      }
      emit(UserProfileError(message: e.toString()));
    }
  }

  Future<void> refreshProfile() async {
    if (_currentUserId != null) {
      final currentState = state;
      if (currentState is UserProfileLoaded) {
        await loadUserProfile();
      }
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _userRepository.deleteAccount();
      clearProfile();
    } catch (e) {
      emit(UserProfileError(message: e.toString()));
    }
  }

  void clearProfile() {
    _userDataSubscription?.cancel();
    _currentUserId = null;
    emit(const UserProfileInitial());
  }

  UserModel? get currentUser {
    final currentState = state;
    if (currentState is UserProfileLoaded) {
      return currentState.user;
    } else if (currentState is UserProfileUpdating) {
      return currentState.currentUser;
    }
    return null;
  }

  bool get isProfileLoaded => state is UserProfileLoaded;

  bool get isLoading => state is UserProfileLoading;

  bool get isUpdating => state is UserProfileUpdating;

  @override
  Future<void> close() {
    _userDataSubscription?.cancel();
    return super.close();
  }
}
