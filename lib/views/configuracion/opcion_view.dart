import 'package:flutter/material.dart';

class OpcionView extends StatelessWidget {
  const OpcionView({super.key, required this.title, required this.icon, this.cerrar = false, required this.onTap});

  final String title;
  final IconData icon;
  final bool cerrar;
  final VoidCallback onTap;


  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon,
          color: cerrar ? Colors.red : Theme.of(context).colorScheme.primary),
      title: Text(title, style: TextStyle(color: cerrar ? Colors.red : null, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, color: cerrar ? Colors.red : Theme.of(context).colorScheme.primary),
      onTap: onTap,
    );
  }
}
