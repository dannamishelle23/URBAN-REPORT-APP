//Subir imagenes a supabase storage y devolver la URL publica
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String bucket = 'reportes';

  Future<String> uploadImage(File file, String userId) async {
    final fileName =
        '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';

    await _supabase.storage.from(bucket).upload(
          fileName,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    return _supabase.storage.from(bucket).getPublicUrl(fileName);
  }
}
