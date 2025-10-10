import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';

part 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  StreamSubscription<UserModel?>? _userDataSubscription;
  String? _currentUserId;

  UserProfileCubit({
    required UserRepository userRepository,
    required AuthRepository authRepository,
  })  : _userRepository = userRepository,
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

  Future<void> togglePushNotifications(bool enabled) async {
    final currentUser = this.currentUser;
    if (currentUser == null) return;

    try {
      if (enabled) {
        final settings = await FirebaseMessaging.instance.requestPermission();

        if (settings.authorizationStatus != AuthorizationStatus.authorized) {
          emit(
            UserProfileLoaded(
              user: currentUser.copyWith(
                enablePushNotifications: false,
                systemNotificationsEnabled: false,
              ),
            ),
          );
          return;
        }
      }

      await _userRepository.togglePushNotifications(currentUser.id, enabled);

      final updatedUser = currentUser.copyWith(
        enablePushNotifications: enabled,
        systemNotificationsEnabled: enabled,
      );

      emit(UserProfileLoaded(user: updatedUser));
    } catch (e) {
      emit(UserProfileError(message: e.toString()));
    }
  }

  Future<void> toggleAnonymousSharing(bool isEnabled) async {
    final currentUser = this.currentUser;
    if (currentUser == null) return;

    try {
      await _userRepository.toggleAnonymousSharing(currentUser.id, isEnabled);

      final updatedUser = currentUser.copyWith(
        enabledAnonymousSharing: isEnabled,
      );

      emit(UserProfileLoaded(user: updatedUser));
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

  Future<void> checkSystemNotificationStatus() async {
    final currentUser = this.currentUser;
    if (currentUser == null) return;

    try {
      final notificationService = getIt<NotificationService>();
      final systemEnabled = await notificationService.areNotificationsEnabled();

      if (!systemEnabled && currentUser.enablePushNotifications) {
        await _userRepository.togglePushNotifications(currentUser.id, false);

        final updatedUser = currentUser.copyWith(
          enablePushNotifications: false,
          systemNotificationsEnabled: false,
        );
        emit(UserProfileLoaded(user: updatedUser));
      } else if (systemEnabled != currentUser.systemNotificationsEnabled) {
        final updatedUser = currentUser.copyWith(
          systemNotificationsEnabled: systemEnabled,
        );
        emit(UserProfileLoaded(user: updatedUser));
      }
    } catch (e) {
      logman.error('Failed to check system notification status: $e');
    }
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
