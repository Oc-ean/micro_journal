import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';

class FollowButton extends StatefulWidget {
  final bool isFromNotificationPage;
  final String targetUserId;

  final VoidCallback? onFollowChanged;

  const FollowButton({
    super.key,
    this.isFromNotificationPage = false,
    required this.targetUserId,
    this.onFollowChanged,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  late final FollowCubit _followCubit;

  @override
  void initState() {
    super.initState();
    _followCubit = FollowCubit(
      userRepository: getIt<UserRepository>(),
    );
    _followCubit.loadFollowingStatus(widget.targetUserId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FollowCubit, FollowState>(
      bloc: _followCubit,
      builder: (context, state) {
        final (isLoading, isFollowing) = _getButtonState(state);

        return CustomButton(
          loading: isLoading,
          text: widget.isFromNotificationPage
              ? (isFollowing ? 'Following' : 'Follow back')
              : (isFollowing ? 'Following' : 'Follow'),
          height: 37,
          width: 200,
          boxRadius: 9,
          fontSize: 14,
          onTap: _handleFollowToggle,
        );
      },
    );
  }

  (bool isLoading, bool isFollowing) _getButtonState(FollowState state) {
    switch (state) {
      case FollowLoading():
        return (true, _getPreviousFollowStatus());
      case FollowLoaded():
        return (false, state.followingStatus[widget.targetUserId] ?? false);
      case FollowError():
        return (false, _getPreviousFollowStatus());
      default:
        return (false, false);
    }
  }

  bool _getPreviousFollowStatus() {
    final currentState = _followCubit.state;
    if (currentState is FollowLoaded) {
      return currentState.followingStatus[widget.targetUserId] ?? false;
    }
    return false;
  }

  Future<void> _handleFollowToggle() async {
    try {
      await _followCubit.toggleFollow(
        widget.targetUserId,
        widget.isFromNotificationPage,
      );
      widget.onFollowChanged?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${_getPreviousFollowStatus() ? 'unfollow' : 'follow'} user',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
