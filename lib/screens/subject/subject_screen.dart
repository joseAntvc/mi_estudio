import 'package:flutter/material.dart';
import 'package:mi_estudio/firebase/subject_firebase.dart';
import 'package:mi_estudio/utils/custom_loading.dart';
import 'package:mi_estudio/utils/custom_toast.dart';
import 'package:mi_estudio/utils/provider/subject_from_provider.dart';
import 'package:provider/provider.dart';

class SubjectScreen extends StatelessWidget {
  const SubjectScreen({super.key});

  Color darken(Color color, [double amount = .3]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subject = SubjectFirebase();
    final isWide = MediaQuery.of(context).size.width > 500; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis materias', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, "/subjectForm");
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder(
          stream: subject.selectSubject(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CustomLoading();
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school, size: 50, color: theme.disabledColor),
                    const SizedBox(height: 16),
                    Text('No tienes materias aún',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Presiona el botón + para agregar una',
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
              );
            }
            final subjects = snapshot.data!.docs;
            return GridView.builder(
              itemCount: subjects.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWide ? 4 : 2, //Numero de columnas
                mainAxisSpacing: 12, // Espacio entre filas
                crossAxisSpacing: 12, // Espacio entre columnas
              ),
              itemBuilder: (context, index) {
                final subject = subjects[index];
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
                          overflow: TextOverflow.ellipsis, // Opcional, para evitar que crezca sin límite
                          softWrap: true, // Asegura que el texto se ajuste
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: PopupMenuButton(
                          tooltip: "Opciones",
                          icon: Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 15),
                                  SizedBox(width: 5),
                                  Text("Editar"),
                                ],
                              ),
                              onTap: () {
                                Provider.of<SubjectFromProvider>(context, listen: false).loadExistingData({
                                  'nombre': subject['nombre'],
                                  'color': subject['color'],
                                  'icono': subject['icono'],
                                  'docId': subject.id,
                                });
                                Navigator.pushNamed(context, "/subjectForm");
                              },
                            ),
                            PopupMenuItem(
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 15),
                                  SizedBox(width: 5),
                                  Text("Eliminar"),
                                ],
                              ),
                              onTap: () async => await _showDeleteDialog(context, subject.id),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, String docId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar materia'),
          content: const Text('¿Estás seguro de que quieres eliminar esta materia?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                try {
                  await SubjectFirebase().deleteSubject(docId);
                  CustomToast.show(context, "Materia eliminada");
                  Navigator.of(context).pop();
                } catch (e) {
                  CustomToast.show(context, "Error al eliminar la materia", type: "e");
                }
              },
            ),
          ],
        );
      },
    );
  }
}