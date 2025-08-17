import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';
import 'package:micro_journal/src/features/home/presentation/widgets/comment_item_widget.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:solar_icons/solar_icons.dart';

class CommentsModalSheet extends StatefulWidget {
  final String journalId;

  const CommentsModalSheet({
    super.key,
    required this.journalId,
  });

  static void show({
    required BuildContext context,
    required String journalId,
  }) {
    showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      constraints: const BoxConstraints(maxWidth: 500),
      builder: (context) => CommentsModalSheet(
        journalId: journalId,
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
  late CommentsCubit _commentCubit;
  CommentModel? _replyingTo;

  @override
  void initState() {
    super.initState();
    _commentFocusNode = FocusNode();
    _commentCubit = getIt<CommentsCubit>();
    _commentCubit.loadComments(widget.journalId);
  }

  @override
  void dispose() {
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _handleAddComment() {
    final currentUserInfo = getIt<AuthRepository>().currentUser;
    final commentControl =
        formGroup.control(FormControlName.comment) as FormControl<String>;
    final commentText = commentControl.value?.trim() ?? '';

    if (commentText.isNotEmpty) {
      final currentUser = UserModel(
        id: currentUserInfo!.uid,
        email: currentUserInfo.email!,
        username: currentUserInfo.displayName!,
        avatarUrl: currentUserInfo.photoURL!,
      );

      final newComment = CommentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        journalId: widget.journalId,
        content: commentText,
        user: currentUser,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        parentCommentId: _replyingTo?.id,
        likes: [],
      );

      _commentCubit.addComment(newComment);

      commentControl.value = '';
      setState(() {
        _replyingTo = null;
      });
      _commentFocusNode.unfocus();
    }
  }

  void _handleReply(CommentModel comment) {
    final commentControl =
        formGroup.control(FormControlName.comment) as FormControl<String>;
    setState(() {
      _replyingTo = comment;
      commentControl.value = '@${comment.user!.username} ';
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

  List<CommentModel> _getTopLevelComments(List<CommentModel> allComments) {
    return allComments
        .where((comment) => comment.parentCommentId == null)
        .toList();
  }

  List<CommentModel> _getRepliesForComment(
      List<CommentModel> allComments, String parentCommentId,) {
    return allComments
        .where((comment) => comment.parentCommentId == parentCommentId)
        .toList();
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
                          fontSize: 18,
                        ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 0.3),
            Expanded(
              child: BlocBuilder<CommentsCubit, CommentsState>(
                bloc: _commentCubit,
                builder: (context, state) {
                  final comments = state is CommentsLoaded
                      ? state.comments
                      : List.generate(3, (index) => CommentModel.sampleData());
                  if (comments.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            SolarIconsOutline.chatRound,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No comments yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Be the first to leave a comment!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is CommentsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading comments',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _commentCubit.loadComments(widget.journalId);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _getTopLevelComments(comments).length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      final userId = getIt<AuthRepository>().currentUser!.uid;
                      final topLevelComment =
                          _getTopLevelComments(comments)[index];
                      final replies =
                          _getRepliesForComment(comments, topLevelComment.id);
                      return CommentItemWidget(
                        comment: comment,
                        replies: replies,
                        currentUserId: userId,
                        onReply: _handleReply,
                      );
                    },
                  );
                },
              ),
            ),
            if (_replyingTo != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey[100],
                child: Row(
                  children: [
                    Icon(
                      SolarIconsOutline.reply,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Replying to @${_replyingTo!.user!.username}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _cancelReply,
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[200]!,
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
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
                            ? 'Reply to @${_replyingTo!.user!.username}...'
                            : 'Add a comment...',
                        borderRadius: 20,
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
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: hasText
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Post',
                              style: TextStyle(
                                color:
                                    hasText ? Colors.white : Colors.grey[400],
                                fontSize: 14,
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
            ),
          ],
        ),
      ),
    );
  }
}
