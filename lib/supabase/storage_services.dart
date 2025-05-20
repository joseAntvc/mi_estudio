import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart';

class StorageServices {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<String?> updoadFile(File image, String id) async{
    String file = extension(image.path);
    String folder = "$id/profile";
    String fileName = '${DateTime.now().millisecondsSinceEpoch.toString()}$file';
    
    final files = await supabase.storage.from('miestudio').list(path: folder);
    if (files.isNotEmpty) {
      final paths = files.map((file) => '$folder/${file.name}').toList();
      await supabase.storage.from('miestudio').remove(paths);
    }

    await supabase.storage.from('miestudio').upload("$folder/$fileName", image);
    final getUrl = supabase.storage.from('miestudio').getPublicUrl("$folder/$fileName");
    return getUrl;
  }

  Future<List<String>> uploadNoteFiles({
    required String userId,
    required String noteId,
    required List<PlatformFile> files,
  }) async {
    final List<String> downloadUrls = [];
    final String folderPath = "$userId/notes/$noteId";

    for (final file in files) {
      if (file.path == null) continue;
      final fullPath = '$folderPath/${file.name}';
      try {
        // Subir el archivo
        await supabase.storage.from('miestudio').upload(fullPath, File(file.path!));
        // Obtener URL pública
        final url = supabase.storage.from('miestudio').getPublicUrl(fullPath);
        downloadUrls.add(url);
      } catch (e) {
        print('Error al subir archivo: $e');
        // Continuar con los demás archivos si hay error
      }
    }
    return downloadUrls;
  }

  Future<void> deleteNoteFiles({
    required String userId,
    required String noteId,
  }) async {
    final String folderPath = "$userId/notes/$noteId";
    try {
      final files = await supabase.storage.from('miestudio').list(path: folderPath);
      if (files.isNotEmpty) {
        final paths = files.map((file) => '$folderPath/${file.name}').toList();
        await supabase.storage.from('miestudio').remove(paths);
      }
    } catch (e) {
      print('Error al eliminar archivos: $e');
    }
  }
}