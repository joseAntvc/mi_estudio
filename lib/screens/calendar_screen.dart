import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mi_estudio/firebase/subject_firebase.dart';
import 'package:mi_estudio/firebase/task_firebase.dart';
import 'package:mi_estudio/utils/custom_widgets/custom_loading.dart';
import 'package:mi_estudio/utils/custom_widgets/custom_toast.dart';
import 'package:mi_estudio/views/task_form_view.dart';
import 'package:provider/provider.dart';
import 'package:mi_estudio/utils/provider/task_provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class TaskCalendarDataSource extends CalendarDataSource {
  TaskCalendarDataSource(List<Appointment> appointments) {
    this.appointments = appointments;
  }
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final isWide = MediaQuery.of(context).size.width > 500; 

    return WillPopScope(
      onWillPop: () async { 
        provider.clear();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Calendario', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading:BackButton(
            onPressed: () {
              provider.clear();
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: StreamBuilder(
            stream: SubjectFirebase().getSubjectsStream(),
            builder: (context, subjectSnapshot) {
              if (!subjectSnapshot.hasData) return const CustomLoading();
              final subjects = subjectSnapshot.data!.docs;
              final subjectColors = {
                for (var doc in subjects)
                  doc.id: Color(doc['color']),
              };
              return StreamBuilder(
                stream: TaskFirebase().selectTask(),
                builder: (context, taskSnapshot) {
                  if (!taskSnapshot.hasData) return const CustomLoading();
                  final tasks = taskSnapshot.data!.docs;
                  final appointments = tasks.map<Appointment>((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final subject = data['title'] ?? 'Tarea';
                    final subjectId = data['subjectId'];
                    final color = subjectColors[subjectId] ?? Colors.grey[300]!;
                    final startTime = (data['startDate'] as Timestamp).toDate();
                    final endTime = (data['endDate'] as Timestamp).toDate();
                    return Appointment(
                      startTime: startTime,
                      endTime: endTime,
                      subject: subject,
                      color: color,
                    );
                  }).toList();
                  Widget leyenda() => Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    direction: isWide ? Axis.vertical : Axis.horizontal,
                    children: [
                      ConstrainedBox(
                        constraints: isWide ? const BoxConstraints(maxWidth: 150) : const BoxConstraints(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.black12),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Sin categoría',
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.visible,
                                softWrap: true,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...subjects.map((subject) {
                        final color = Color(subject['color']);
                        final name = subject['nombre'];
                        return ConstrainedBox(
                          constraints: isWide ? const BoxConstraints(maxWidth: 150) : const BoxConstraints(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.black12),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  name,
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.visible,
                                  softWrap: true,
                                  maxLines: 2, // O más si lo deseas
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  );

                  Widget calendario()=> SizedBox(
                    height: 500,
                    child: SfCalendar(
                      view: CalendarView.month,
                      headerHeight: 50,
                      todayHighlightColor: theme.primaryColor,
                      todayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      cellBorderColor: Colors.grey[400],
                      backgroundColor: Colors.grey[50],
                      headerStyle: CalendarHeaderStyle(
                        backgroundColor: Colors.grey[100],
                        textStyle: TextStyle(color: theme.primaryColor, fontSize: 20, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      viewHeaderStyle: const ViewHeaderStyle(
                        dayTextStyle: TextStyle(color: Colors.black),
                        dateTextStyle: TextStyle(color: Colors.black),
                      ),
                      timeSlotViewSettings: TimeSlotViewSettings(
                        timeTextStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w500),
                        dateFormat: 'd',
                        dayFormat: 'EEE',
                        timeFormat: 'h:mm a',
                      ),
                      monthViewSettings: MonthViewSettings(
                        agendaStyle: AgendaStyle(
                          backgroundColor: theme.scaffoldBackgroundColor,
                          appointmentTextStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w500),
                          dayTextStyle: TextStyle(color: theme.primaryColor, fontSize: 16),
                          dateTextStyle: TextStyle(color: theme.primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        monthCellStyle: MonthCellStyle(
                          trailingDatesTextStyle: TextStyle(color: Colors.grey[400]),
                          leadingDatesTextStyle: TextStyle(color: Colors.grey[400]),
                          textStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w500),
                        ),
                      ),
                      minDate: DateTime(DateTime.now().year - 1, 1, 1),
                      maxDate: DateTime(DateTime.now().year + 1, 12, 31),
                      showNavigationArrow: true,
                      showDatePickerButton: true,
                      showTodayButton: true,
                      allowedViews: const [
                        CalendarView.day,
                        CalendarView.week,
                        CalendarView.month,
                      ],
                      dataSource: TaskCalendarDataSource(appointments),
                      onSelectionChanged: (details) {
                        provider.setSelectedDate(details.date);
                      },
                    ),
                  );

                  return isWide 
                    ? Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: SingleChildScrollView(child: leyenda())
                        ),
                        const SizedBox(width: 32),
                        Flexible(
                          flex: 4,
                          child: SingleChildScrollView(child: calendario())
                        )
                      ],
                    )
                    : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          leyenda(),
                          const SizedBox(height: 16),
                          calendario()
                        ],
                                        ),
                    );
                },
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (provider.selectedDate == null) {
              CustomToast.show(context, 'Selecciona un día en el calendario', type: 'w');
              return;
            }
            _showTaskForm(context, provider.selectedDate!);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showTaskForm(BuildContext context, DateTime selectedDate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (contex) {
        Provider.of<TaskProvider>(context, listen: false).setDate(selectedDate);
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(contex).viewInsets.bottom,
            left: 20, right: 20, top: 20
          ),
          child: TaskFormView(
            initialDate: selectedDate,
          ),
        );
      },
    );
  }
}