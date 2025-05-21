import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mi_estudio/firebase/subject_firebase.dart';
import 'package:mi_estudio/firebase/task_firebase.dart';
import 'package:mi_estudio/utils/custom_widgets/custom_loading.dart';
import 'package:mi_estudio/utils/custom_widgets/custom_toast.dart';
import 'package:mi_estudio/utils/function/function_darken.dart';
import 'package:mi_estudio/utils/provider/task_provider.dart';
import 'package:provider/provider.dart';

class TaskFormView extends StatefulWidget {
  final DateTime initialDate;
  const TaskFormView({super.key, required this.initialDate});

  @override
  State<TaskFormView> createState() => _TaskFormViewState();
}

class _TaskFormViewState extends State<TaskFormView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<TaskProvider>(context);

    _titleController.text = provider.title ?? '';

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Nueva tarea/examen', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Título'),
            validator: (v) => v == null || v.isEmpty ? 'Ingresa un título' : null,
            onChanged: provider.setTitle,
          ),
          const SizedBox(height: 16),
          StreamBuilder(
            stream: SubjectFirebase().getSubjectsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Text('Error al cargar materias');
              if (!snapshot.hasData) return CustomLoading(size: 30);
              final subjects = snapshot.data!.docs;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: theme.scaffoldBackgroundColor,
                        menuWidth: MediaQuery.of(context).size.width * 0.7,
                        menuMaxHeight: MediaQuery.of(context).size.height * 0.5,
                        value: provider.subjectId,
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
                        onChanged: provider.setSubjectId,
                        padding: const EdgeInsets.only(right: 16),
                        borderRadius: BorderRadius.circular(16),
                        elevation: 2,
                        icon: const Icon(Icons.arrow_drop_down),
                        hint: const Text('Selecciona una materia'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Fecha: ${widget.initialDate.toLocal().toString().split(' ')[0]}',
                  style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  child: Text(provider.startTime == null
                      ? 'Seleccionar hora de inicio'
                      : provider.startTime!.format(context)),
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) provider.setStartTime(picked);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  child: Text(provider.endTime == null
                      ? 'Seleccionar hora de fin'
                      : provider.endTime!.format(context)),
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: provider.startTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) provider.setEndTime(picked);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            child: provider.loading ? const CircularProgressIndicator() : const Text('Guardar'),
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              if (provider.startTime == null || provider.endTime == null) {
                CustomToast.show(context, 'Selecciona hora de inicio y fin', type: 'e');
                return;
              }
              // Validación: hora de fin debe ser mayor a la de inicio
              final startDateTime = DateTime(
                widget.initialDate.year,
                widget.initialDate.month,
                widget.initialDate.day,
                provider.startTime!.hour,
                provider.startTime!.minute,
              );
              final endDateTime = DateTime(
                widget.initialDate.year,
                widget.initialDate.month,
                widget.initialDate.day,
                provider.endTime!.hour,
                provider.endTime!.minute,
              );
              if (!endDateTime.isAfter(startDateTime)) {
                CustomToast.show(context, 'La hora de fin debe ser mayor a la de inicio', type: 'w');
                return;
              }
              provider.setLoading(true);
              try {
                await TaskFirebase().addTask(
                  provider.toMap(startDateTime: startDateTime, endDateTime: endDateTime),
                );
                provider.clear();
                CustomToast.show(context, 'Tarea guardada con exito');
                Navigator.pop(context);
              } catch (e) {
                CustomToast.show(context, 'Error al guardar la tarea', type: 'e');
              } finally {
                provider.setLoading(false);
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
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
          const SizedBox(width: 12),
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
            borderRadius: const BorderRadius.only(
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
}