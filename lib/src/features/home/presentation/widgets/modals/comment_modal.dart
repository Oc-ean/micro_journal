import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:solar_icons/solar_icons.dart';

class CommentsModalSheet extends StatefulWidget {
  final List<CommentModel> comments;
  final void Function(String)? onAddComment;
  final void Function(CommentModel)? onLikeComment;

  const CommentsModalSheet({
    super.key,
    required this.comments,
    this.onAddComment,
    this.onLikeComment,
  });

  static void show({
    required BuildContext context,
    required List<CommentModel> comments,
    void Function(String)? onAddComment,
    void Function(CommentModel)? onLikeComment,
  }) {
    showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      constraints: const BoxConstraints(maxWidth: 500),
      builder: (context) => CommentsModalSheet(
        comments: comments,
        onAddComment: onAddComment,
        onLikeComment: onLikeComment,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  @override
  State<CommentsModalSheet> createState() => _CommentsModalSheetState();
}

class _CommentsModalSheetState extends State<CommentsModalSheet> {
  final FormGroup formGroup = fb.group({
    FormControlName.comment: FormControl<String>(),
  });
  late FocusNode _commentFocusNode;
  CommentModel? _replyingTo;
  late List<CommentModel> _comments;

  @override
  void initState() {
    super.initState();
    _commentFocusNode = FocusNode();
    _comments = List.from(widget.comments);
  }

  @override
  void dispose() {
    _commentFocusNode.dispose();
    super.dispose();
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  void _handleAddComment() {
    final commentControl =
        formGroup.control(FormControlName.comment) as FormControl<String>;
    final commentText = commentControl.value?.trim() ?? '';
    if (commentText.isNotEmpty) {
      final currentUser = UserModel(
        id: 'sample',
        username: 'current_user',
        avatarUrl:
            'https://images.pexels.com/photos/1321942/pexels-photo-1321942.jpeg',
      );

      if (_replyingTo != null) {
        // Handle reply
        final replyComment = CommentModel(
          user: currentUser,
          text: commentText,
          timestamp: DateTime.now(),
        );

        // Find the parent comment and add the reply
        for (int i = 0; i < _comments.length; i++) {
          if (_comments[i] == _replyingTo) {
            setState(() {
              _comments[i] = CommentModel(
                user: _comments[i].user,
                text: _comments[i].text,
                likes: _comments[i].likes,
                timestamp: _comments[i].timestamp,
                isLiked: _comments[i].isLiked,
                replies: [..._comments[i].replies, replyComment],
              );
            });
            break;
          }
        }
      } else {
        // Handle new comment
        final newComment = CommentModel(
          user: currentUser,
          text: commentText,
          timestamp: DateTime.now(),
        );

        setState(() {
          _comments.insert(0, newComment); // Add to beginning of list
        });
      }

      // Call callback if provided
      widget.onAddComment?.call(commentText);

      // Clear input and reset state
      commentControl.value = '';
      _replyingTo = null;
      _commentFocusNode.unfocus();
    }
  }

  void _handleReply(CommentModel comment) {
    final commentControl =
        formGroup.control(FormControlName.comment) as FormControl<String>;
    setState(() {
      _replyingTo = comment;
      commentControl.value = '@${comment.user.username} ';
      _commentFocusNode.requestFocus();
    });
  }

  void _cancelReply() {
    final commentControl =
        formGroup.control(FormControlName.comment) as FormControl<String>;
    setState(() {
      _replyingTo = null;
      commentControl.value = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveForm(
      formGroup: formGroup,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Header with drag handle
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Comments',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 0.3),

            // Comments List
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  return _buildCommentItem(_comments[index]);
                },
              ),
            ),

            if (_replyingTo != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: context.theme.cardColor,
                child: Row(
                  children: [
                    Text(
                      'Replying to @${_replyingTo!.user.username}',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _cancelReply,
                      child: const Icon(
                        Icons.close,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),

            // Comment Input
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: context.theme.scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[200]!,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      'https://images.pexels.com/photos/1321942/pexels-photo-1321942.jpeg',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomFormTextField<String>(
                      name: FormControlName.comment,
                      focusNode: _commentFocusNode,
                      hintText: _replyingTo != null
                          ? 'Reply to @${_replyingTo!.user.username}...'
                          : 'Add a comment...',
                      borderRadius: 20,
                      filled: true,
                      fillColor: context.theme.scaffoldBackgroundColor,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _handleAddComment(),
                      showError: false,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ReactiveFormConsumer(
                    builder: (context, formGroup, child) {
                      final commentControl =
                          formGroup.control('comment') as FormControl<String>;
                      final hasText =
                          (commentControl.value ?? '').trim().isNotEmpty;

                      return GestureDetector(
                        onTap: hasText ? _handleAddComment : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            'Post',
                            style: TextStyle(
                              color: hasText
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[400],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment, {bool isReply = false}) {
    return Padding(
      padding: EdgeInsets.only(
        left: isReply ? 44 : 0,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(comment.user.avatarUrl),
                radius: isReply ? 14 : 16,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.user.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getTimeAgo(comment.timestamp),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.text,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (comment.likes > 0) ...[
                          Text(
                            '${comment.likes} ${comment.likes == 1 ? 'like' : 'likes'}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        if (!isReply) ...[
                          GestureDetector(
                            onTap: () => _handleReply(comment),
                            child: Text(
                              'Reply',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        comment.isLiked = !comment.isLiked;
                        if (comment.isLiked) {
                          comment.likes++;
                        } else {
                          comment.likes =
                              comment.likes > 0 ? comment.likes - 1 : 0;
                        }
                      });
                      widget.onLikeComment?.call(comment);
                    },
                    child: Icon(
                      comment.isLiked
                          ? SolarIconsBold.heart
                          : SolarIconsOutline.heart,
                      size: 16,
                      color: comment.isLiked ? Colors.red : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Replies
          if (!isReply && comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: comment.replies
                    .map((reply) => _buildCommentItem(reply, isReply: true))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
