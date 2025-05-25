import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mi_estudio/firebase/note_firebase.dart';
import 'package:mi_estudio/firebase/subject_firebase.dart';
import 'package:mi_estudio/utils/custom_widgets/custom_loading.dart';
import 'package:mi_estudio/utils/custom_widgets/custom_toast.dart';
import 'package:mi_estudio/utils/function/function_darken.dart';
import 'package:mi_estudio/utils/function/function_dowload_file.dart';
import 'package:mi_estudio/utils/provider/note_from_provider.dart';
import 'package:mi_estudio/views/note/video_preview.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteDateilsScreen extends StatelessWidget {
  const NoteDateilsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final noteId = ModalRoute.of(context)!.settings.arguments as String;
    final noteFirebase = NoteFirebase();
    final subjectFirebase  = SubjectFirebase();
    final separated = const SizedBox(height: 10);
    final pageController = PageController();
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 500; 

    return Scaffold(
      body: StreamBuilder(
        stream: noteFirebase.getNoteById(noteId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomLoading();
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            Future.microtask(() {
              Navigator.pop(context);
            });
            return const SizedBox();
          }
          final noteData = snapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> fileUrls = noteData['hasAttachments'] ? (noteData['fileUrls'] ?? []) as List<dynamic> : [];
          final subjectId = noteData['subjectId'];
          final imaVidUrls = fileUrls.where((url) {
            final u = url.toString().toLowerCase();
              return u.endsWith('.jpg') ||
                u.endsWith('.jpeg') ||
                u.endsWith('.png') ||
                u.endsWith('.webp') ||
                u.endsWith('.gif') ||
                u.endsWith('.mp4') ||
                u.endsWith('.mov');
              }).toList();
          final otherFiles = fileUrls.where((url) {
            final u = url.toString().toLowerCase();
              return !(u.endsWith('.jpg') ||
                u.endsWith('.jpeg') ||
                u.endsWith('.png') ||
                u.endsWith('.webp') ||
                u.endsWith('.gif') ||
                u.endsWith('.mp4') ||
                u.endsWith('.mov'));
              }).toList();

          Widget info() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(noteData['title'], style: theme.textTheme.headlineMedium),
              separated,
              if (subjectId != null && subjectId != '')
                StreamBuilder(
                  stream: subjectFirebase.getSubjectById(subjectId),
                  builder: (context, subjectSnapshot) {
                    if (!subjectSnapshot.hasData || !subjectSnapshot.data!.exists) {
                      return Chip(
                        label: const Text('Sin categoría'),
                        avatar: const Icon(Icons.category, color: Colors.grey),
                        backgroundColor: Colors.grey[200],
                      );
                    }
                    final subjectData = subjectSnapshot.data!.data() as Map<String, dynamic>;
                    final color = Color(subjectData['color']);
                    final icon = IconData(subjectData['icono'], fontFamily: 'MaterialIcons');
                    final colorDarken  = darken(color);
                    return Chip(
                      label: Text(subjectData['nombre'], style: TextStyle(color: colorDarken, fontWeight: FontWeight.bold)),
                      avatar: Icon(icon, color: colorDarken),
                      backgroundColor: color.withOpacity(0.2),
                      shape: StadiumBorder(side: BorderSide(color: colorDarken)),
                    );
                  },
                )
              else
                Chip(
                  label: const Text('Sin categoría'),
                  avatar: const Icon(Icons.category, color: Colors.grey),
                  backgroundColor: Colors.grey[200],
                ),
              if (noteData['content'] != null && (noteData['content'] as String).trim().isNotEmpty) ...[
                separated,
                Text(noteData['content'], style: theme.textTheme.bodyLarge),
              ],
            ],
          );
          
          Widget carrusel() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Imagenes y videos', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.primaryColor,
                  )
                ),
                height: 400,
                child: PageView.builder(
                  controller: pageController,
                  physics: BouncingScrollPhysics(),
                  itemCount: imaVidUrls.length,
                  itemBuilder: (context, index) {
                    final url = imaVidUrls[index].toString();
                    if (url.endsWith('.mp4') || url.endsWith('.mov')) {
                      // Widget para video
                      return VideoPreview(url: url);
                    } else {
                      // Widget para imagen
                      return Stack(
                        children: [
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl: url,
                                fit: BoxFit.scaleDown,
                                placeholder: (context, _) => const CustomLoading(size: 50),
                                errorWidget: (context, _, __) => const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: Icon(Icons.download, color: theme.primaryColor, size: 28),
                              tooltip: 'Descargar imagen',
                              onPressed: () => downloadFile(context, url, url.split('/').last),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
              separated,
              Center(
                child: SmoothPageIndicator(
                  controller: pageController,
                  count: imaVidUrls.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: theme.colorScheme.primary,
                    dotColor: theme.colorScheme.primary,
                    dotHeight: 10,
                    dotWidth: 10,
                    expansionFactor: 5,
                  ),
                ),
              ),
            ],
          );
          
          Widget archivos() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Archivos adjuntos', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Column(
                children: otherFiles.map((url) {
                  final fileName = url.toString().split('/').last;
                  final extension = fileName.split('.').last;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(_getIconFile(extension), color: theme.colorScheme.primary),
                      title: Text(fileName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                      trailing: IconButton(
                        icon: Icon(Icons.download, color: theme.primaryColor,),
                        onPressed: () => downloadFile(context, url.toString(), fileName),
                      ),
                      onTap: () async {
                        final uri = Uri.parse(url.toString());
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          );
          
          return Scaffold(
            appBar: AppBar(
              title: const Text('Detalle de nota', style: TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar nota',
                  onPressed: () {
                    final provider = Provider.of<NoteFormProvider>(context, listen: false);
                    provider.loadExistingData({
                      'title': noteData['title'],
                      'content': noteData['content'],
                      'subjectId': noteData['subjectId'],
                      'docId': noteId,
                      'fileUrls': noteData['fileUrls'] ?? [],
                    });
                    Navigator.pushNamed(context, '/noteForm');
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: 'Eliminar nota',
                    onPressed: () {
                      showDialog(
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
                              onPressed: () {
                                Navigator.pop(context);
                                noteFirebase.deleteNote(noteId);
                                CustomToast.show(context, "Nota eliminada");
                              },
                              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: isWide
                  ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(flex: 2, child: info()),
                      if (imaVidUrls.isNotEmpty) ...[
                        const SizedBox(width: 32),
                        Flexible(flex: 2, child: carrusel()),
                      ],
                      if (otherFiles.isNotEmpty) ...[
                        const SizedBox(width: 32),
                        Flexible(flex: 2, child: archivos()),
                      ],
                    ],
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      info(),
                      if (imaVidUrls.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        carrusel(), 
                      ],
                      if (otherFiles.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        archivos()
                      ],
                    ],  
                  ),
              ),
            ),
          );
        }
      ),
    );
  }

  IconData _getIconFile(String extension) {
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
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

