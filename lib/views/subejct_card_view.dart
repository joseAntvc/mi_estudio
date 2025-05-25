import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubejctCardView extends StatelessWidget {
  const SubejctCardView({
    super.key,
    required this.subject,
    required this.theme,
    this.onEdit,
    this.onDelete,
  });

  final QueryDocumentSnapshot<Object?> subject;
  final ThemeData theme;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  Color darken(Color color, [double amount = .3]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(subject['color']);
    final icon = IconData(subject['icono'], fontFamily: 'MaterialIcons');
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.only(left: 15, top: 15, bottom: 15),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Icon(icon, color: darken(color), size: 90),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              subject['nombre'],
              style: theme.textTheme.labelSmall?.copyWith(fontSize: 20),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: PopupMenuButton(
              tooltip: "Opciones",
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: onEdit != null,
                  onTap: onEdit,
                  child: Row(
                    children: const [
                      Icon(Icons.edit, size: 15),
                      SizedBox(width: 5),
                      Text("Editar"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  enabled: onEdit != null,
                  onTap: onDelete,
                  child: Row(
                    children: const [
                      Icon(Icons.delete, size: 15),
                      SizedBox(width: 5),
                      Text("Eliminar"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}