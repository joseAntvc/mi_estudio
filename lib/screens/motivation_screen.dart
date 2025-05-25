import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_estudio/firebase/motivation_firebase.dart';
import 'package:mi_estudio/utils/custom_widgets/custom_loading.dart';
import 'package:mi_estudio/utils/custom_widgets/custom_toast.dart';
import 'package:mi_estudio/utils/provider/connectivity_provider.dart';
import 'package:provider/provider.dart';

class MotivationScreen extends StatefulWidget {
  const MotivationScreen({super.key});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen> {
  final MotivationFirebase _motivationFirebase = MotivationFirebase();
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showMotivationBottomSheet({DocumentSnapshot? doc}) {
    final isEdit = doc != null;
    isEdit ? _controller.text = doc['text'] : _controller.text = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isEdit ? 'Editar Motivación' : 'Añadir Motivación', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Escribe tu motivación...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_controller.text.isNotEmpty) {
                        if (isEdit) {
                          await _motivationFirebase.updateMotivation(doc.id, {
                            'text': _controller.text,
                          });
                        } else {
                          await _motivationFirebase.addMotivation({
                            'text': _controller.text,
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                        }
                        _controller.clear();
                      }
                      CustomToast.show(context, isEdit ? 'Frase actualizada' : 'Frase guardada');
                      Navigator.pop(context);
                    },
                    child: Text(isEdit ? 'Actualizar' : 'Guardar'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }


  Widget _buildDailyMotivation() {
    final theme = Theme.of(context);
    return FutureBuilder(
      future: _motivationFirebase.getGlobalMotivationOfDay(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomLoading(size: 50);
        }
        if (!snapshot.hasData) {
          return _buildEmptyState(
            icon: Icons.auto_awesome,
            message: 'No hay frase para hoy',
            color: Colors.amber[100]!,
          );
        }
        final frase = snapshot.data!;
        return Card(
          margin: const EdgeInsets.only(bottom: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          color: theme.primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Frase del día',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(frase, style: theme.textTheme.labelSmall),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message, required Color color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Theme.of(context).primaryColor),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalMotivations() {
    final theme = Theme.of(context);
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tus motivaciones', style: theme.textTheme.titleMedium),
            IconButton(
              icon: Icon(Icons.add_circle), 
              onPressed: isOnline ? _showMotivationBottomSheet : null),
          ],
        ),
        StreamBuilder<QuerySnapshot>(
          stream: _motivationFirebase.selectMotivation(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CustomLoading();
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState(
                icon: Icons.edit_note,
                message: 'Añade tus propias motivaciones\npara mantenerte inspirado',
                color: Colors.grey[100]!,
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final text = doc['text'];
                final date = doc['createdAt']?.toDate() ?? DateTime.now();
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(text, style: theme.textTheme.labelLarge),
                        subtitle: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                          child: Text('${date.day}/${date.month}/${date.year}', style: theme.textTheme.bodySmall),
                        ),
                        trailing: PopupMenuButton(
                          tooltip: "Opciones",
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              enabled: isOnline,
                              onTap: () => _showMotivationBottomSheet(doc: doc),
                              child: Row(
                                children: const [
                                  Icon(Icons.edit, size: 15),
                                  SizedBox(width: 5),
                                  Text("Editar"),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              enabled: isOnline,
                              onTap: () async {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('¿Eliminar frase?'),
                                    content: const Text('Esta acción no se puede deshacer.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                        Navigator.pop(context);
                                        _motivationFirebase.deleteMotivation(doc.id);
                                        CustomToast.show(context, 'Frase eliminada');
                                        },
                                        child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              }, 
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
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motivación Diaria'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDailyMotivation(),
            _buildPersonalMotivations(),
          ],
        ),
      ),
    );
  }
}