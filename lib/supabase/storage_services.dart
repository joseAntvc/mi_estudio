import 'dart:io';
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
}