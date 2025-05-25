import 'package:flutter/material.dart';
import 'package:mi_estudio/firebase/note_firebase.dart';
import 'package:mi_estudio/firebase/subject_firebase.dart';
import 'package:mi_estudio/firebase/task_firebase.dart';
import 'package:mi_estudio/utils/custom_widgets/custom_loading.dart';
import 'package:mi_estudio/utils/custom_widgets/custom_toast.dart';
import 'package:mi_estudio/utils/provider/connectivity_provider.dart';
import 'package:mi_estudio/utils/provider/subject_from_provider.dart';
import 'package:mi_estudio/views/subejct_card_view.dart';
import 'package:provider/provider.dart';

class SubjectScreen extends StatelessWidget {
  const SubjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subject = SubjectFirebase();
    final isWide = MediaQuery.of(context).size.width > 500; 
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis materias', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: isOnline
                ? () => Navigator.pushNamed(context, "/subjectForm")
                : null,
          )
        ],
      ),
      body: Stack(
        children: [
          Padding(
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
                        Image.asset('assets/logo.png', color: theme.disabledColor, width: 50),
                        const SizedBox(height: 16),
                        Text('No tienes materias aún', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('Presiona el botón + para agregar una', style: theme.textTheme.bodyMedium),
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
                    return SubejctCardView(
                      subject: subject,
                      theme: theme,
                      onEdit: isOnline
                        ? () {
                            Provider.of<SubjectFromProvider>(context, listen: false).loadExistingData({
                              'nombre': subject['nombre'],
                              'color': subject['color'],
                              'icono': subject['icono'],
                              'docId': subject.id,
                            });
                            Navigator.pushNamed(context, "/subjectForm");
                          }
                        : null,
                    onDelete: isOnline
                        ? () async => await _showDeleteDialog(context, subject.id)
                        : null,
                    );
                  },
                );
              },
            ),
          ),
          Consumer<SubjectFromProvider>(
            builder: (context, prov, _) {
              return prov.isDelete
                ? CustomLoading()
                : SizedBox.shrink();
            }
          ),
        ],
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
          actions:[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                try {
                  CustomToast.show(context, "Materia eliminada");
                  Navigator.of(context).pop();
                  final provider = Provider.of<SubjectFromProvider>(context, listen: false);
                  provider.setIsDelete(true);
                  await SubjectFirebase().deleteSubject(docId);
                  await NoteFirebase().clearSubjectFromNotes(docId);
                  await TaskFirebase().clearSubjectFromTask(docId);
                  provider.setIsDelete(false);
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