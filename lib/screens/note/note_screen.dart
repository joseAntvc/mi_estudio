import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mi_estudio/firebase/note_firebase.dart';
import 'package:mi_estudio/firebase/subject_firebase.dart';
import 'package:mi_estudio/utils/custom_widgets/custom_loading.dart';
import 'package:mi_estudio/utils/function/function_darken.dart';
import 'package:mi_estudio/utils/provider/note_from_provider.dart';
import 'package:mi_estudio/views/note/note_card_view.dart';
import 'package:provider/provider.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {

  Widget _subjects(String name, {Color? color, IconData? icon}) {
    if (icon == null || color == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text('Sin categoría', style: TextStyle(fontSize: 16)),
      );
    }
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
          Text(name, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _subjectSelected(String name, {Color? color, IconData? icon}) {
    if (color == null || icon == null) {
      return Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Text(name, style: TextStyle(fontSize: 16)),
      );
    }
    
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
        Text(name, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final note = NoteFirebase();
    final subject = SubjectFirebase();
    final theme = Theme.of(context);
    final provider = Provider.of<NoteFormProvider>(context);
    final isWide = MediaQuery.of(context).size.width > 500; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis notas', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, "/noteForm");
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder(
          stream: subject.getSubjectsStream(),
          builder: (context, subjectsSnapshot) {
            if (subjectsSnapshot.connectionState == ConnectionState.waiting) {
              return CustomLoading();
            }
            final subjects = subjectsSnapshot.data!.docs;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.primaryColor),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      dropdownColor: theme.scaffoldBackgroundColor,
                      menuMaxHeight: MediaQuery.of(context).size.height * 0.5,      
                      isExpanded: true,
                      value: provider.selectedSubjectId,
                      padding: const EdgeInsets.only(right: 16),
                      borderRadius: BorderRadius.circular(16),
                      elevation: 2,
                      icon: Icon(Icons.arrow_drop_down, color: theme.primaryColor,),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text("Todas las materias"),
                        ),
                        DropdownMenuItem(
                          value: 'none',
                          child: _subjects(
                            'Sin categoría', 
                            color: Colors.grey, 
                            icon: Icons.category,
                          )),
                        ...subjects.map((subject) {
                          return DropdownMenuItem(
                            value: subject.id,
                            child: _subjects(
                              subject['nombre'],
                              color: Color(subject['color']),
                              icon: IconData(subject['icono'], fontFamily: 'MaterialIcons'),
                            ),
                          );
                        }),
                      ],
                      selectedItemBuilder: (context){
                        return [
                          DropdownMenuItem(
                            value: null,
                            child: _subjectSelected(
                              "Todas las materias"
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'none',
                            child: _subjectSelected(
                              'Sin categoría', 
                              color: Colors.grey, 
                              icon: Icons.category,
                            ),
                          ),
                          ...subjects.map((subject) {
                            return DropdownMenuItem(
                              value: subject.id,
                              child: _subjectSelected(
                                subject['nombre'],
                                color: Color(subject['color']),
                                icon: IconData(subject['icono'], fontFamily: 'MaterialIcons'),
                              ),
                            );
                          }),
                        ];
                      },
                      onChanged: (value) {
                        provider.setSubjectId(value);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder(
                    stream: note.selectNotes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CustomLoading();
                      } 
                      // Filtra las notas según la materia seleccionada
                      final notes = snapshot.hasData
                          ? snapshot.data!.docs.where((note) {
                              final noteSubjectId = note['subjectId'];
                              if (provider.selectedSubjectId == null) return true;
                              if (provider.selectedSubjectId == 'none') {
                                return noteSubjectId == null || noteSubjectId == '';
                              }
                              return noteSubjectId == provider.selectedSubjectId;
                            }).toList()
                          : [];
                      if (notes.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/logo.png', color: theme.disabledColor, width: 50),
                              const SizedBox(height: 16),
                              Text(
                                provider.selectedSubjectId == null
                                  ? 'No tienes notas aún'
                                  : provider.selectedSubjectId == 'none'
                                    ? 'No tienes notas sin categoría'
                                    : 'No tienes notas de esta materia',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text('Presiona el botón + para agregar una', style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        );
                      }
                      return MasonryGridView.count(
                        physics: const BouncingScrollPhysics(),
                        crossAxisCount: isWide ? 3 : 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          final subjectList = subjects.where((subject) => subject.id == note['subjectId']);
                          final subject = subjectList.isNotEmpty ? subjectList.first : null;
                          return NoteCardView(
                            subject: subject,
                            note: note,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
