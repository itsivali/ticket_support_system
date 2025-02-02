import 'package:flutter/material.dart';

class SkillSelector extends StatelessWidget {
  final List<String> selectedSkills;
  final Function(List<String>) onChanged;

  static const List<String> availableSkills = [
    'Technical Support',
    'Customer Service',
    'Problem Solving',
    'Communication',
    'Software',
    'Hardware',
  ];

  const SkillSelector({
    super.key,
    required this.selectedSkills,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Skills',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableSkills.map((skill) {
            final isSelected = selectedSkills.contains(skill);
            return FilterChip(
              label: Text(skill),
              selected: isSelected,
              onSelected: (selected) {
                final updatedSkills = List<String>.from(selectedSkills);
                if (selected) {
                  updatedSkills.add(skill);
                } else {
                  updatedSkills.remove(skill);
                }
                onChanged(updatedSkills);
              },
              avatar: Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                size: 18,
              ),
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.primary,
            );
          }).toList(),
        ),
        if (selectedSkills.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Select at least one skill',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}