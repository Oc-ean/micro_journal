import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:reactive_forms/reactive_forms.dart';

class CreateJournalPage extends StatefulWidget {
  final String currentUserId;
  const CreateJournalPage({super.key, required this.currentUserId});

  @override
  State<CreateJournalPage> createState() => _CreateJournalPageState();
}

class _CreateJournalPageState extends State<CreateJournalPage> {
  late JournalCubit _journalCubit;
  late AuthRepository _authRepository;

  final FormGroup _formGroup = fb.group({
    FormControlName.thoughts:
        FormControl<String>(validators: [Validators.required]),
    FormControlName.intention: FormControl<String>(),
  });

  String selectedMoodValue = '';
  String selectedMoodEmoji = '';
  List<String> selectedTags = [];
  bool? isAnonymous;

  @override
  void initState() {
    super.initState();
    _journalCubit = getIt<JournalCubit>();
    _authRepository = getIt<AuthRepository>();
    _initializeAnonymousSetting(widget.currentUserId);
  }

  void _selectMood(Mood mood) {
    setState(() {
      selectedMoodValue = mood.value;
      selectedMoodEmoji = mood.emoji;
    });
  }

  void _toggleTag(String tag) {
    setState(() {
      if (selectedTags.contains(tag)) {
        selectedTags.remove(tag);
      } else {
        selectedTags.add(tag);
      }
    });
  }

  void _toggleAnonymous(bool value) {
    setState(() {
      isAnonymous = value;
    });
  }

  String _getMoodDisplay() {
    if (selectedMoodValue.isEmpty) return '';
    return selectedMoodValue.substring(0, 1).toUpperCase() +
        selectedMoodValue.substring(1);
  }

  void _submitJournal(BuildContext context) {
    if (_formGroup.valid && selectedMoodValue.isNotEmpty) {
      final currentUser = _authRepository.currentUser;

      final thoughts =
          _formGroup.control(FormControlName.thoughts).value as String;
      final intention =
          _formGroup.control(FormControlName.intention).value as String?;
      if (currentUser == null) {
        context.showSnackBarUsingText(
          'Please sign in to create a journal entry',
        );
        return;
      }
      final anonymousValue = isAnonymous ?? false;

      final journal = JournalModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        mood: Mood(value: selectedMoodValue, emoji: selectedMoodEmoji),
        thoughts: thoughts,
        intention: intention,
        tags: selectedTags,
        isAnonymous: anonymousValue,
        user: UserModel(
          id: currentUser.uid,
          username: anonymousValue
              ? generateAnonymousUsername()
              : currentUser.displayName!,
          email: currentUser.email!,
          avatarUrl: currentUser.photoURL!,
        ),
      );

      _journalCubit.createJournal(journal);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a mood and share your thoughts'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _journalCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JournalCubit, JournalState>(
      bloc: _journalCubit,
      listener: (context, state) {
        if (state is JournalError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is JournalCreated) {
          context.pop();
          context.showSnackBarUsingText('Journal entry saved successfully!');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Journal Entry'),
          elevation: 0,
          actions: [
            BlocBuilder<JournalCubit, JournalState>(
              bloc: _journalCubit,
              builder: (context, state) {
                return TextButton(
                  onPressed: state is JournalCreating
                      ? null
                      : () => _submitJournal(context),
                  child: state is JournalCreating
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Text(
                          'Save',
                          style: TextStyle(
                            color: state is JournalCreating
                                ? Colors.grey
                                : Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                );
              },
            ),
          ],
        ),
        body: ReactiveForm(
          formGroup: _formGroup,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How are you feeling?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: moods.map((mood) {
                    final isSelected = selectedMoodValue == mood.value;
                    return GestureDetector(
                      onTap: () => _selectMood(mood),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? context.theme.primaryColor.withAlpha(50)
                              : context.theme.cardColor,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            mood.emoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 15),
                Center(
                  child: Text(
                    _getMoodDisplay(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: selectedMoodValue.isNotEmpty
                          ? context.theme.primaryColor.withAlpha(180)
                          : Colors.grey[500],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "What's on your mind?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                const CustomFormTextField<String>(
                  name: FormControlName.thoughts,
                  hintText:
                      "Share your thoughts, what happened today, or how you're feeling...",
                  maxLines: 8,
                  borderRadius: 12,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 25),
                const Text(
                  "Today's intention (optional)",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                const CustomFormTextField<String>(
                  name: FormControlName.intention,
                  hintText: 'What do you want to focus on today?',
                  borderRadius: 12,
                  textCapitalization: TextCapitalization.sentences,
                  showError: false,
                ),
                const SizedBox(height: 25),
                const Text(
                  'Add tags',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: defaultTags.map((tag) {
                    final isSelected = selectedTags.contains(tag);
                    return GestureDetector(
                      onTap: () => _toggleTag(tag),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.theme.primaryColor
                              : context.theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? context.theme.primaryColor.withAlpha(50)
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isSelected ? Colors.white : null,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withAlpha(25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isAnonymous == true
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: context.theme.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAnonymous == true
                                  ? 'Anonymous Mode'
                                  : 'Public Mode',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: context.theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isAnonymous == true
                                  ? 'Your identity will be encrypted and hidden'
                                  : 'Your profile will be visible to others',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .primaryColor
                                    .withAlpha(150),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isAnonymous ?? false,
                        onChanged: _toggleAnonymous,
                        activeColor: context.theme.primaryColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                if (isAnonymous == true)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withAlpha(25),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: context.theme.primaryColor,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your journal is shared anonymously within our community. Feel free to express yourself authentically - you can create one meaningful entry each day.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _initializeAnonymousSetting(String userId) async {
    final user = await getIt<UserRepository>().getUserData(userId);
    final isAnonymousSharingEnabled = user?.enabledAnonymousSharing;
    setState(() {
      isAnonymous = isAnonymousSharingEnabled;
    });
  }
}
