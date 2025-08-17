import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:solar_icons/solar_icons.dart';

class CommentLikeButton extends StatefulWidget {
  final CommentModel comment;
  final bool isLiked;
  final String userId;

  const CommentLikeButton({
    required this.comment,
    required this.isLiked,
    required this.userId,
  });

  @override
  State<CommentLikeButton> createState() => CommentLikeButtonState();
}

class CommentLikeButtonState extends State<CommentLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late CommentLikesCubit _commentLikesCubit;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    _commentLikesCubit = CommentLikesCubit(getIt<JournalRepository>());
  }

  @override
  void dispose() {
    _animationController.dispose();
    _commentLikesCubit.close();
    super.dispose();
  }

  void _onLikeTap() {
    if (widget.isLiked) {
      _commentLikesCubit.unlikeComment(widget.comment.id, widget.userId);
    } else {
      _commentLikesCubit.likeComment(widget.comment.id, widget.userId);
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommentLikesCubit, CommentLikesState>(
      bloc: _commentLikesCubit,
      listener: (context, state) {
        if (state is CommentLikesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update like: ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: BlocBuilder<CommentLikesCubit, CommentLikesState>(
        bloc: _commentLikesCubit,
        builder: (context, state) {
          final isLoading = state is CommentLikesLoading;

          return GestureDetector(
            onTap: isLoading ? null : _onLikeTap,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isLiked ? _scaleAnimation.value : 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey[400]!,
                              ),
                            ),
                          )
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: Icon(
                              widget.isLiked
                                  ? SolarIconsBold.heart
                                  : SolarIconsOutline.heart,
                              key: ValueKey(widget.isLiked),
                              size: 16,
                              color: widget.isLiked
                                  ? Colors.red
                                  : Colors.grey[600],
                            ),
                          ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
