import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:reactive_forms/reactive_forms.dart';

class CreateJournalPage extends StatefulWidget {
  const CreateJournalPage({super.key});

  @override
  State<CreateJournalPage> createState() => _CreateJournalPageState();
}

class _CreateJournalPageState extends State<CreateJournalPage> {
  final FormGroup _formGroup = fb.group({
    FormControlName.thoughts: FormControl<String>(),
    FormControlName.intention: FormControl<String>(),
  });
  String selectedMood = '';
  List<String> selectedTags = [];

  final List<Map<String, String>> moods = [
    {'value': 'amazing', 'emoji': '🤩'},
    {'value': 'happy', 'emoji': '😊'},
    {'value': 'okay', 'emoji': '😐'},
    {'value': 'sad', 'emoji': '😢'},
    {'value': 'terrible', 'emoji': '😭'},
  ];

  final List<String> defaultTags = [
    'gratitude',
    'work',
    'family',
    'health',
    'goals',
    'stress',
    'win',
    'reflection',
    'love',
    'growth',
  ];

  void _selectMood(String mood) {
    setState(() {
      selectedMood = mood;
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

  String _getMoodDisplay() {
    if (selectedMood.isEmpty) return '';
    return selectedMood.substring(0, 1).toUpperCase() +
        selectedMood.substring(1);
  }

  void _submitJournal() {
    if (_formGroup.valid && selectedMood.isNotEmpty) {
      final thoughts = _formGroup.control('thoughts').value;
      final intention = _formGroup.control('intention').value;
      logman.info('Selected Mood: $_getMoodDisplay');
      logman.info('Selected Tags: $selectedTags');
      logman.info('Thoughts: $thoughts');
      logman.info('Intention: $intention');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal entry saved successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a mood and share your thoughts'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Journal Entry'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _submitJournal,
            child: Text(
              'Save',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
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
              // Mood Question
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
                  final isSelected = selectedMood == mood['value'];
                  return GestureDetector(
                    onTap: () => _selectMood(mood['value']!),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? context.theme.primaryColor.withValues(alpha: 0.2)
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
                          mood['emoji']!,
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
                    color: selectedMood.isNotEmpty
                        ? context.theme.primaryColor.withValues(alpha: 0.7)
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
                name: FormControlName.intention,
                hintText:
                    "Share your thoughts, what happened today, or how you're feeling...",
                maxLines: 8,
                borderRadius: 12,
                textCapitalization: TextCapitalization.sentences,
                // textInputAction: TextInputAction.newline,
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
                              ? context.theme.primaryColor
                                  .withValues(alpha: 0.2)
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        '#$tag',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
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

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitJournal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Create Journal Entry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
