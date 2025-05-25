import 'package:flutter/material.dart';
import 'package:mi_estudio/firebase/task_firebase.dart';
import 'package:mi_estudio/models/calendar_model.dart';
import 'package:mi_estudio/utils/custom_widgets/custom_toast.dart';
import 'package:mi_estudio/utils/function/function_darken.dart';
import 'package:mi_estudio/utils/provider/task_provider.dart';
import 'package:mi_estudio/views/task_form_view.dart';
import 'package:provider/provider.dart';

class TaskDayView extends StatelessWidget {
  final DateTime date;
  final List<CalendarAppointment> appointments;

  const TaskDayView({super.key, required this.date, required this.appointments});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);

    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tareas del ${date.day}/${date.month}/${date.year}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  provider.clear();
                  provider.setDate(date);
                  Navigator.pop(context); // Cierra el modal
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => Padding(
                      padding: EdgeInsets.all(20),
                      child: TaskFormView(initialDate: date),
                    ),
                  );
                },
              ),
            ],
          ),
          const Divider(),
          if (appointments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No hay tareas para este día'),
            ),
          ...appointments.map((appointment) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: appointment.color,
                borderRadius: BorderRadius.circular(5)
              ),
              child: Icon(appointment.subjectIcon, color: darken(appointment.color)),
            ),
            title: Text(appointment.subject),
            subtitle: Text(
              '${appointment.startTime.hour.toString().padLeft(2, '0')}:${appointment.startTime.minute.toString().padLeft(2, '0')} - '
              '${appointment.endTime.hour.toString().padLeft(2, '0')}:${appointment.endTime.minute.toString().padLeft(2, '0')}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    final doc = await TaskFirebase().getTaskById(appointment.taskId);
                    provider.setTaskFromDoc(doc);
                    Navigator.pop(context); // Cierra el modal
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => Padding(
                        padding: EdgeInsets.all(20),
                        child: TaskFormView(initialDate: date),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('¿Eliminar nota?'),
                        content: const Text('Esta acción no se puede deshacer.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () async {
                            Navigator.pop(context);
                            await TaskFirebase().deleteTask(appointment.taskId);
                            Navigator.pop(context); // Cierra el modal
                            CustomToast.show(context, 'Tarea eliminada');
                            },
                            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}