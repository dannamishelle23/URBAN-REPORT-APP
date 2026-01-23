//Subir imagenes a supabase storage y devolver la URL publica
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final _supabase = Supabase.instance.client;

  Future<String> uploadImage(File file, String userId) async {
    String debugInfo = '';
    
    try {
      // PASO 1: Listar buckets
      debugInfo += 'PASO 1: Listando buckets...\n';
      final buckets = await _supabase.storage.listBuckets();
      final bucketNames = buckets.map((b) => b.name).toList();
      debugInfo += 'Buckets encontrados: $bucketNames\n';

      // PASO 2: Verificar que existe "imagenes"
      debugInfo += 'PASO 2: Buscando bucket "imagenes"...\n';
      final existeImagenes = buckets.any((b) => b.name == 'imagenes');
      
      if (!existeImagenes) {
        throw Exception('❌ Bucket "imagenes" NO existe.\nBuckets disponibles: $bucketNames');
      }
      debugInfo += '✅ Bucket "imagenes" encontrado\n';

      // PASO 3: Leer archivo
      debugInfo += 'PASO 3: Leyendo archivo...\n';
      final bytes = await file.readAsBytes();
      debugInfo += 'Bytes: ${bytes.length}\n';

      // PASO 4: Preparar nombre
      debugInfo += 'PASO 4: Preparando nombre...\n';
      final extension = path.extension(file.path).toLowerCase();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_$timestamp$extension';
      debugInfo += 'Nombre: $fileName\n';

      // PASO 5: Subir
      debugInfo += 'PASO 5: Subiendo archivo...\n';
      await _supabase.storage.from('imagenes').uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: _getContentType(extension),
            ),
          );
      debugInfo += '✅ Archivo subido exitosamente\n';

      // PASO 6: Obtener URL
      debugInfo += 'PASO 6: Obteniendo URL...\n';
      final publicUrl = _supabase.storage.from('imagenes').getPublicUrl(fileName);
      debugInfo += 'URL: $publicUrl\n';

      return publicUrl;
      
    } on StorageException catch (e) {
      throw Exception('$debugInfo\n❌ StorageException:\nCódigo: ${e.statusCode}\nMensaje: ${e.message}');
    } catch (e) {
      throw Exception('$debugInfo\n❌ Error: $e');
    }
  }

  String _getContentType(String extension) {
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  Future<void> deleteImage(String fileUrl) async {
    try {
      final fileName = Uri.parse(fileUrl).pathSegments.last;
      await _supabase.storage.from('imagenes').remove([fileName]);
    } catch (e) {
      throw Exception('Error al eliminar imagen: $e');
    }
  }
}