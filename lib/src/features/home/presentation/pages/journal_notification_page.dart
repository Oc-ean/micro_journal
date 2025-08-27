import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';
import 'package:solar_icons/solar_icons.dart';

class JournalNotificationDetailPage extends StatefulWidget {
  final String postId;
  final String? commentId;
  final String notificationType;

  const JournalNotificationDetailPage({
    super.key,
    required this.postId,
    this.commentId,
    required this.notificationType,
  });

  @override
  State<JournalNotificationDetailPage> createState() =>
      _JournalNotificationDetailPageState();
}

class _JournalNotificationDetailPageState
    extends State<JournalNotificationDetailPage> {
  late JournalRepository _journalRepository;
  late CommentsCubit _commentsCubit;
  JournalModel? _journal;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _journalRepository = getIt<JournalRepository>();
    _commentsCubit = getIt<CommentsCubit>();
    _loadJournalData();
  }

  Future<void> _loadJournalData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final journal = await _journalRepository.getJournalById(widget.postId);

      if (journal != null) {
        setState(() {
          _journal = journal;
          _isLoading = false;
        });

        if (widget.notificationType == 'comment' ||
            widget.notificationType == 'comment_like') {
          _commentsCubit.loadComments(widget.postId);
        }
      } else {
        setState(() {
          _error = 'Post not found or has been deleted';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load post: $e';
        _isLoading = false;
      });
    }
  }

  void _openCommentsModal() {
    if (_journal != null) {
      CommentsModalSheet.show(
        context: context,
        journalId: widget.postId,
      );
    }
  }

  Widget _buildNotificationHeader() {
    String title = '';
    IconData icon = SolarIconsOutline.bell;
    Color iconColor = Colors.blue;

    switch (widget.notificationType) {
      case 'comment':
        title = 'New Comment';
        icon = SolarIconsOutline.chatRound;
        iconColor = Colors.green;
      case 'comment_like':
        title = 'Comment Liked';
        icon = SolarIconsBold.heart;
        iconColor = Colors.red;
      case 'like':
        title = 'Post Liked';
        icon = SolarIconsBold.heart;
        iconColor = Colors.red;
      default:
        title = 'Notification';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap the post to interact or view comments',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = getIt<AuthRepository>().currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: const BackIconButton(),
      ),
      body: RefreshIndicator(
        onRefresh: _loadJournalData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationHeader(),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_error != null)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          SolarIconsOutline.dangerTriangle,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Oops!',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.red[700],
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadJournalData,
                          icon: const Icon(SolarIconsOutline.refresh),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_journal != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Related Post',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        if (widget.notificationType == 'comment' ||
                            widget.notificationType == 'comment_like') {
                          _openCommentsModal();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: (widget.notificationType == 'comment' ||
                                  widget.notificationType == 'comment_like')
                              ? Border.all(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.3),
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: PostWidget(
                          journal: _journal!,
                          currentUserId: currentUserId,
                          onComment: _openCommentsModal,
                        ),
                      ),
                    ),
                    if (widget.notificationType == 'comment' ||
                        widget.notificationType == 'comment_like')
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              SolarIconsOutline.infoCircle,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tap the post above to view and respond to comments',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: _journal != null &&
              (widget.notificationType == 'comment' ||
                  widget.notificationType == 'comment_like')
          ? FloatingActionButton.extended(
              onPressed: _openCommentsModal,
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(SolarIconsOutline.chatRound),
              label: const Text('View Comments'),
            )
          : null,
    );
  }
}
