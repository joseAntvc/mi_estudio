import 'package:flutter/material.dart';

class HeadView extends StatelessWidget {
  const HeadView({super.key, required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/logo.png', width: 80, color: theme.primaryColor,),
        Text(titulo, style: theme.textTheme.displayMedium, textAlign: TextAlign.center),
      ],
    );
  }
}