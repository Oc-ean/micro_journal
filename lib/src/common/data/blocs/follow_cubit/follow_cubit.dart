import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';

part 'follow_state.dart';

class FollowCubit extends Cubit<FollowState> {
  final UserRepository _userRepository;

  FollowCubit({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(FollowInitial());

  final Map<String, bool> _followingStatus = {};

  String? currentUserId = getIt<AuthRepository>().currentUser?.uid;

  Future<void> loadFollowingStatus(String targetUserId) async {
    emit(FollowLoading());
    try {
      final isFollowing =
          await _userRepository.isFollowing(currentUserId!, targetUserId);
      _followingStatus[targetUserId] = isFollowing;

      emit(FollowLoaded(Map.from(_followingStatus)));
    } catch (e) {
      emit(FollowError(e.toString()));
    }
  }

  Future<void> toggleFollow(
    String targetUserId,
    bool isFromNotificationPage,
  ) {
    final isFollowing = _followingStatus[targetUserId] ?? false;
    if (isFromNotificationPage) {
      if (isFollowing) {
        return unfollowUser(targetUserId);
      } else {
        return acceptFollowRequest(targetUserId);
      }
    }
    if (isFollowing) {
      return unfollowUser(targetUserId);
    } else {
      return followUser(targetUserId);
    }
  }

  Future<void> followUser(
    String targetUserId,
  ) async {
    emit(FollowLoading());
    try {
      final success =
          await _userRepository.followUser(currentUserId!, targetUserId);
      if (success) {
        _followingStatus[targetUserId] = true;
        emit(FollowLoaded(Map.from(_followingStatus)));
      } else {
        emit(const FollowError('Failed to follow user'));
      }
    } catch (e) {
      emit(FollowError('An error occurred: $e'));
    }
  }

  Future<void> unfollowUser(String targetUserId) async {
    emit(FollowLoading());
    try {
      final success =
          await _userRepository.unfollowUser(currentUserId!, targetUserId);
      if (success) {
        _followingStatus[targetUserId] = false;
        emit(FollowLoaded(Map.from(_followingStatus)));
      } else {
        emit(const FollowError('Failed to unfollow user'));
      }
    } catch (e) {
      emit(FollowError('An error occurred: $e'));
    }
  }

  Future<void> acceptFollowRequest(String targetUserId) async {
    emit(FollowLoading());
    try {
      final success = await _userRepository.acceptFollowRequest(
        currentUserId!,
        targetUserId,
      );
      if (success) {
        _followingStatus[targetUserId] = true;
        emit(FollowLoaded(Map.from(_followingStatus)));
      } else {
        emit(const FollowError('Failed to unfollow user'));
      }
    } catch (e) {
      emit(FollowError('An error occurred: $e'));
    }
  }
}
