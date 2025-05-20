// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:mi_estudio/firebase/note_firebase.dart';
import 'package:mi_estudio/utils/custom_loading.dart';
import 'package:mi_estudio/utils/custom_toast.dart';
import 'package:mi_estudio/utils/provider/note_from_provider.dart';
import 'package:provider/provider.dart';

class NoteFormScreen extends StatefulWidget {
  const NoteFormScreen({super.key});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final NoteFirebase _noteFirebase = NoteFirebase();

  Future<void> _pickFiles() async {
    final provider = context.read<NoteFormProvider>();
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );
      if (result != null) {
        for (final file in result.files) {
          provider.addAttachment(file);
        }
      }
    } on PlatformException catch (_) {
      CustomToast.show(context, 'Error al seleccionar archivos', type: 'e');
    }
  }

  Future<void> _saveNote() async {
    final provider = context.read<NoteFormProvider>();
    if (!_formKey.currentState!.validate()) return;
    provider.setLoading(true);
    try {
      await _noteFirebase.addNote(
        provider.toMap(),
        files: provider.attachments,
      );
      provider.clear();
      CustomToast.show(context, 'Nota guardada');
      Navigator.pop(context);
    } catch (e) {
      CustomToast.show(context, 'Error al guardar', type: 'e');
    } finally {
      provider.setLoading(false);
    }
  }

  Widget _subjects(DocumentSnapshot? subject) {
    if (subject == null || !subject.exists) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: const Row(
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: Icon(Icons.category, size: 18, color: Colors.grey)
            ),
            SizedBox(width: 12),
            Text('Sin categoría', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }
    final color = Color(subject['color']);
    final icon = IconData(subject['icono'], fontFamily: 'MaterialIcons');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: darken(color)),
            ),
            child: Icon(icon, size: 18, color: darken(color)),
          ),
          Text(subject['nombre'], style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _subjectSelected(DocumentSnapshot? subject) {
    if (subject == null) {
      return Padding(
        padding: const EdgeInsets.only(left: 16),
        child: const Text('Sin categoría', style: TextStyle(fontSize: 16)),
      );
    }
    
    final color = Color(subject['color']);
    final icon = IconData(subject['icono'], fontFamily: 'MaterialIcons');
    
    return Row(
      children: [
        Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
          ),
          child: Icon(icon, size: 18, color: darken(color)),
        ),
        const SizedBox(width: 12),
        Text(subject['nombre'], style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Color darken(Color color, [double amount = .3]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NoteFormProvider>(context, listen: false);
    final theme = Theme.of(context);
    final separador = const SizedBox(height: 24);
    final separador2 = const SizedBox(height: 8);

    return WillPopScope(
      onWillPop: () async { 
        provider.clear();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nueva nota', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: BackButton(
            onPressed: () {
              provider.clear();
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed:() => _saveNote(), 
            ),
          ],
        ),
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Título', style: theme.textTheme.bodyLarge),
                    separador2,
                    TextFormField( //Campo de titulo
                      onChanged: provider.setTitle,
                      validator: (value) => value?.isEmpty ?? true ? 'Ingresa un título' : null,
                    ),
                    separador,
                    StreamBuilder( //Campo de materia
                      stream: _noteFirebase.getSubjectsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) return const Text('Error al cargar materias');
                        if (!snapshot.hasData) return CustomLoading(size: 30);
                        final subjects = snapshot.data!.docs;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Materia', style: theme.textTheme.bodyLarge),
                            separador2,
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: theme.dividerColor),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Consumer<NoteFormProvider>(
                                builder: (context, prov, _) {
                                  return DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      dropdownColor: theme.scaffoldBackgroundColor,
                                      menuWidth: MediaQuery.of(context).size.width * 0.7,
                                      menuMaxHeight: MediaQuery.of(context).size.height * 0.5,      
                                      value: prov.subjectId,
                                      isExpanded: true,
                                      items: [
                                        DropdownMenuItem(
                                          value: null,
                                          child: _subjects(null),
                                        ),
                                        ...subjects.map((subject) {
                                          return DropdownMenuItem(
                                            value: subject.id,
                                            child: _subjects(subject),
                                          );
                                        }),
                                      ],
                                      selectedItemBuilder: (context) {
                                        return [
                                          DropdownMenuItem(
                                            value: null,
                                            child: _subjectSelected(null),
                                          ),
                                          ...subjects.map((subject) {
                                            return DropdownMenuItem(
                                              value: subject.id,
                                              child: _subjectSelected(subject),
                                            );
                                          }),
                                        ];
                                      },
                                      onChanged: prov.setSubject,
                                      padding: const EdgeInsets.only(right: 16),
                                      borderRadius: BorderRadius.circular(16),
                                      elevation: 2,
                                      icon: const Icon(Icons.arrow_drop_down),
                                      hint: const Text('Selecciona una materia'),
                                    ),
                                  );
                                }
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    separador,
                    Text('Contenido', style: theme.textTheme.bodyLarge),
                    separador2,
                    TextFormField( //Campo de contenido
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
                      style: const TextStyle(fontSize: 16),
                      maxLines: 10,
                      onChanged: provider.setContent,
                    ),
                    separador,
                    // Archivos adjuntos
                    Text('Archivos adjuntos', style: theme.textTheme.bodyLarge),
                    separador2,
                    Consumer<NoteFormProvider>(
                      builder: (context, prov, _) {
                        return (prov.attachments.isEmpty) 
                          ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: theme.dividerColor),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text('No hay archivos adjuntos', style: theme.textTheme.bodyMedium),
                            ),
                          ) 
                          : Column(
                            children: prov.attachments.map((file) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getIconFile(file),
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                title: Text(
                                  file.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: () => prov.removeAttachment(prov.attachments.indexOf(file)),
                                ),
                              ),
                            )).toList(),
                          );
                      }
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.attach_file, color: Colors.white),
                      label: const Text('Agregar archivo'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _pickFiles,
                    ),
                  ],
                ),
              ),
            ),
            Consumer<NoteFormProvider>(
              builder: (context, prov, _) {
                return prov.isLoading
                  ? CustomLoading()
                  : SizedBox.shrink();
              }
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconFile(PlatformFile file) {
    final extension = file.extension?.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }
}