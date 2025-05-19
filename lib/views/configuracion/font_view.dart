import 'package:flutter/material.dart';

class FontView extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const FontView({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  TextStyle fontStyle(BuildContext context) {
    return TextStyle(
      fontSize: 14,
      color: selected ? Theme.of(context).colorScheme.primary : null,
      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      fontFamily: label
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: selected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          spacing: 8,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Aa", style: fontStyle(context)),
            Text(label, style: fontStyle(context)),
          ],
        ),
      ),
    );
  }
}