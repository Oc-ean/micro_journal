import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';

part 'user_details_state.dart';

class UserDetailsCubit extends Cubit<UserDetailsState> {
  final UserRepository _userRepository;
  StreamSubscription<UserModel?>? _userSubscription;

  UserDetailsCubit({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(UserDetailsInitial());

  Future<void> loadUserDetails(String userId) async {
    emit(UserDetailsLoading());

    await _userSubscription?.cancel();
    _userSubscription = null;

    try {
      final recentPosts = await _userRepository.getRecentUserPosts(userId);

      _userSubscription = _userRepository.streamUserData(userId).listen(
        (user) {
          if (user != null) {
            emit(
              UserDetailsLoaded(
                user: user,
                recentPosts: recentPosts,
              ),
            );
          } else {
            emit(const UserDetailsError(message: 'User not found'));
          }
        },
        onError: (Object error) {
          emit(
              UserDetailsError(message: 'Failed to load user details: $error'),);
        },
      );
    } catch (e) {
      emit(UserDetailsError(message: 'Failed to load user details: $e'));
    }
  }

  Future<void> refreshUserDetails() async {
    final currentState = state;
    if (currentState is UserDetailsLoaded) {
      await loadUserDetails(currentState.user.id);
    }
  }

  void clearUserDetails() {
    _userSubscription?.cancel();
    _userSubscription = null;
    emit(UserDetailsInitial());
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
