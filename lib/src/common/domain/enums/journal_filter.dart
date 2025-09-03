import 'package:flutter/material.dart';

enum JournalFilter {
  all('All', Icons.list_alt, 'Show all journals'),
  anonymous('Anonymous', Icons.visibility_off, 'Show only anonymous journals'),
  following('Following', Icons.people, 'Show journals from people you follow'),
  mine('My Journals', Icons.person, 'Show only your journals');

  const JournalFilter(this.label, this.icon, this.description);
  final String label;
  final IconData icon;
  final String description;
}
