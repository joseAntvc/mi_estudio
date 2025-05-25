
import 'package:flutter/material.dart';

class PlanView extends StatelessWidget {
  const PlanView({super.key, 
    required this.title,
    required this.price,
    required this.description,
    this.onPressed,
    this.isCurrent = false, 
    this.ahorro,
  });

  final String title;
  final String price;
  final String description;
  final VoidCallback? onPressed;
  final bool isCurrent;
  final String? ahorro;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: isCurrent ? theme.primaryColor : null,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ahorro != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  ahorro!,
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            Text(title, style: theme.textTheme.titleLarge!.copyWith(color: isCurrent ? Colors.white : null)),
            const SizedBox(height: 8),
            Text(price, style: theme.textTheme.headlineSmall!.copyWith(color: isCurrent ? Colors.white : null)),
            const SizedBox(height: 8),
            Text(description, style: TextStyle(color: isCurrent ? Colors.white70 : null)),
            const SizedBox(height: 16),
            isCurrent 
              ? Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text('Plan activo', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
              )
              : ElevatedButton(
                onPressed: onPressed,
                child: Text('Suscribirse'),
              ),
          ],
        ),
      ),
    );
  }
}