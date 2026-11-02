import 'package:flutter/material.dart';

class ConferenceProgressIndicator extends StatelessWidget {
  const ConferenceProgressIndicator({
    super.key,
    required this.labels,
    required this.currentIndex,
    required this.bookedCategories,
    required this.skippedCategories,
    required this.onStepSelected,
  });

  final List<String> labels;
  final int currentIndex;
  final Set<String> bookedCategories;
  final Set<String> skippedCategories;
  final ValueChanged<int> onStepSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step ${currentIndex + 1} of ${labels.length}',
          style: const TextStyle(
            color: Color(0xFF8A7A75),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 66,
          child: Row(
            children: [
              for (var index = 0; index < labels.length; index++) ...[
                if (index > 0) const SizedBox(width: 4),
                Expanded(child: _stepItem(index)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _shortLabel(String label) => switch (label) {
    'Restaurant & Food' => 'Food',
    'Sound & Screens' => 'Sound',
    'Decorations' => 'Decor',
    'Photography' => 'Photo',
    'Transportation' => 'Transport',
    _ => label,
  };

  Widget _stepItem(int index) {
    final label = labels[index];
    final category = _categoryForLabel(label);
    final isBooked = bookedCategories.contains(category);
    final isSkipped = skippedCategories.contains(category);
    final isCurrent = currentIndex == index;
    final color = isCurrent
        ? const Color(0xFF3E2C26)
        : isBooked
        ? const Color(0xFFE7F1E9)
        : const Color(0xFFFFFFFF);
    final foreground = isCurrent
        ? Colors.white
        : isBooked
        ? const Color(0xFF39734A)
        : const Color(0xFF3E2C26);

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: () => onStepSelected(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrent
                  ? const Color(0xFF3E2C26)
                  : const Color(0xFFE9DED5),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isBooked
                    ? Icons.check_circle_rounded
                    : isSkipped
                    ? Icons.skip_next_rounded
                    : isCurrent
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: foreground,
                size: 16,
              ),
              const SizedBox(height: 3),
              Text(
                _shortLabel(label),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontSize: 8,
                  fontWeight: isCurrent || isBooked
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryForLabel(String label) => switch (label) {
    'Halls' => 'hall',
    'Restaurant & Food' => 'food',
    'Sound & Screens' => 'sound',
    'Decorations' => 'decoration',
    'Photography' => 'photography',
    _ => 'transportation',
  };
}
