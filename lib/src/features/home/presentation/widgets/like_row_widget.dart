import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:solar_icons/solar_icons.dart';

class LikeRowWidget extends StatefulWidget {
  final String journalId;
  final String userId;
  final bool isLiked;
  const LikeRowWidget({
    super.key,
    required this.journalId,
    required this.userId,
    required this.isLiked,
  });

  @override
  State<LikeRowWidget> createState() => _LikeRowWidgetState();
}

class _LikeRowWidgetState extends State<LikeRowWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late JournalLikesCubit _likesCubit;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.4,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _likesCubit = JournalLikesCubit(getIt<JournalRepository>());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onLikeTap(bool isLiked) {
    if (isLiked) {
      _likesCubit.unlikeJournal(widget.journalId, widget.userId);
    } else {
      _likesCubit.likeJournal(widget.journalId, widget.userId);
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JournalLikesCubit, JournalLikesState>(
      bloc: _likesCubit,
      listener: (context, state) {
        if (state is JournalLikesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<JournalLikesCubit, JournalLikesState>(
        bloc: _likesCubit,
        builder: (context, state) {
          final isLoading = state is JournalLikesLoading &&
              state.journalId == widget.journalId;
          final isLiked = state is JournalLikesSuccess &&
                  state.journalId == widget.journalId
              ? state.isLiked
              : widget.isLiked;
          return GestureDetector(
            onTap: isLoading
                ? null
                : () {
                    _onLikeTap(isLiked);
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: widget.isLiked
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: widget.isLiked ? _scaleAnimation.value : 1.0,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (widget.isLiked &&
                                _animationController.isAnimating)
                              Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Icon(
                                  SolarIconsOutline.heart,
                                  size: 20,
                                  color: Colors.red.withValues(alpha: 0.3),
                                ),
                              ),
                            AnimatedSwitcher(
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
                                size: 20,
                                color:
                                    widget.isLiked ? Colors.red : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  if (isLoading)
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                    )
                  else
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        widget.isLiked ? 'Liked' : 'Like',
                        key: ValueKey(widget.isLiked),
                        style: TextStyle(
                          color: widget.isLiked ? Colors.red : Colors.grey,
                          fontWeight: widget.isLiked
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
