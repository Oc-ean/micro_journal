import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';

class CommentItemWidget extends StatefulWidget {
  final CommentModel comment;
  final List<CommentModel> replies;
  final String currentUserId;
  final void Function(CommentModel) onReply;

  const CommentItemWidget({
    super.key,
    required this.comment,
    required this.replies,
    required this.currentUserId,
    required this.onReply,
  });

  @override
  State<CommentItemWidget> createState() => _CommentItemWidgetState();
}

class _CommentItemWidgetState extends State<CommentItemWidget> {
  bool _showAllReplies = false;

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);

    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }

  List<TextSpan> _parseCommentContent(String content) {
    final List<TextSpan> spans = [];
    final words = content.split(' ');

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      if (word.startsWith('@')) {
        spans.add(
          TextSpan(
            text: word,
            style: TextStyle(
              color: context.theme.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: word,
            style: const TextStyle(
              fontSize: 14,
              height: 1.3,
            ),
          ),
        );
      }

      if (i < words.length - 1) {
        spans.add(const TextSpan(text: ' '));
      }
    }

    return spans;
  }

  Widget _buildReplyItem(CommentModel reply) {
    final isLiked = reply.likes.contains(widget.currentUserId);

    return Container(
      margin: const EdgeInsets.only(left: 44.0, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: reply.user?.avatarUrl != null
                ? NetworkImage(reply.user!.avatarUrl)
                : null,
            radius: 14,
            backgroundColor: Colors.grey[300],
            child: reply.user?.avatarUrl == null
                ? Text(
                    reply.user?.username.substring(0, 1).toUpperCase() ?? '?',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: reply.isAnonymous
                            ? 'Anonymous'
                            : (reply.user?.username ?? 'Unknown'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: '  ${_getTimeAgo(reply.createdAt)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: _parseCommentContent(reply.content),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (reply.likes.isNotEmpty) ...[
                      Text(
                        '${reply.likes.length} ${reply.likes.length == 1 ? 'like' : 'likes'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    GestureDetector(
                      onTap: () => widget.onReply(reply),
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
                ),
              ],
            ),
          ),
          CommentLikeButton(
            comment: reply,
            isLiked: isLiked,
            userId: widget.currentUserId,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = widget.comment.likes.contains(widget.currentUserId);
    final hasReplies = widget.replies.isNotEmpty;
    final replyCount = widget.replies.length;

    final visibleReplies = _showAllReplies
        ? widget.replies
        : (hasReplies ? widget.replies.take(1).toList() : <CommentModel>[]);
    final hiddenRepliesCount = replyCount - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: widget.comment.user?.avatarUrl != null
                    ? NetworkImage(widget.comment.user!.avatarUrl)
                    : null,
                radius: 16,
                backgroundColor: Colors.grey[300],
                child: widget.comment.user?.avatarUrl == null
                    ? Text(
                        widget.comment.user?.username
                                .substring(0, 1)
                                .toUpperCase() ??
                            '?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: widget.comment.isAnonymous
                                ? 'Anonymous'
                                : (widget.comment.user?.username ?? 'Unknown'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text: '  ${_getTimeAgo(widget.comment.createdAt)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Comment content
                    RichText(
                      text: TextSpan(
                        children: _parseCommentContent(widget.comment.content),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Action buttons
                    Row(
                      children: [
                        if (widget.comment.likes.isNotEmpty) ...[
                          Text(
                            '${widget.comment.likes.length} ${widget.comment.likes.length == 1 ? 'like' : 'likes'}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        GestureDetector(
                          onTap: () => widget.onReply(widget.comment),
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
                    ),
                  ],
                ),
              ),
              CommentLikeButton(
                comment: widget.comment,
                isLiked: isLiked,
                userId: widget.currentUserId,
              ),
            ],
          ),
        ),
        if (hasReplies) ...[
          ...visibleReplies.map((reply) => _buildReplyItem(reply)),
          if (!_showAllReplies && hiddenRepliesCount > 0)
            Padding(
              padding: const EdgeInsets.only(left: 44, bottom: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showAllReplies = true;
                  });
                },
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 1,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'View $hiddenRepliesCount more ${hiddenRepliesCount == 1 ? 'reply' : 'replies'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_showAllReplies && replyCount > 1)
            Padding(
              padding: const EdgeInsets.only(left: 44, bottom: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showAllReplies = false;
                  });
                },
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 1,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hide replies',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}
