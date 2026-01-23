//Subir imagenes a supabase storage y devolver la URL publica
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final _supabase = Supabase.instance.client;

  /// Intenta listar buckets (solo para diagnóstico, puede fallar con anon key)
  Future<List<String>> listarBuckets() async {
    try {
      final buckets = await _supabase.storage.listBuckets();
      return buckets.map((b) => b.name).toList();
    } catch (e) {
      // listBuckets puede fallar con anon key, retornar lista vacía
      return ['(No se pudo listar - permisos insuficientes)'];
    }
  }

  Future<String> uploadImage(File file, String userId) async {
    String debugInfo = '';
    
    try {
      // PASO 1: Intentar listar buckets (solo informativo)
      debugInfo += 'PASO 1: Intentando listar buckets...\n';
      try {
        final buckets = await _supabase.storage.listBuckets();
        final bucketNames = buckets.map((b) => b.name).toList();
        debugInfo += 'Buckets encontrados: $bucketNames\n';
      } catch (e) {
        debugInfo += 'No se pudo listar buckets (normal con anon key): $e\n';
      }

      // PASO 2: Leer archivo
      debugInfo += 'PASO 2: Leyendo archivo...\n';
      debugInfo += 'Ruta del archivo: ${file.path}\n';
      
      if (!await file.exists()) {
        throw Exception('El archivo no existe en la ruta: ${file.path}');
      }
      
      final bytes = await file.readAsBytes();
      debugInfo += 'Bytes leídos: ${bytes.length}\n';

      if (bytes.isEmpty) {
        throw Exception('El archivo está vacío');
      }

      // PASO 3: Preparar nombre
      debugInfo += 'PASO 3: Preparando nombre...\n';
      final extension = path.extension(file.path).toLowerCase();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_$timestamp$extension';
      debugInfo += 'Nombre del archivo: $fileName\n';
      debugInfo += 'Content-Type: ${_getContentType(extension)}\n';

      // PASO 4: Subir al bucket "imagenes"
      debugInfo += 'PASO 4: Subiendo a bucket "imagenes"...\n';
      await _supabase.storage.from('IMAGENES').uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: _getContentType(extension),
            ),
          );
      debugInfo += 'Archivo subido exitosamente\n';

      // PASO 5: Obtener URL pública
      debugInfo += 'PASO 5: Obteniendo URL pública...\n';
      final publicUrl = _supabase.storage.from('IMAGENES').getPublicUrl(fileName);
      debugInfo += 'URL: $publicUrl\n';

      return publicUrl;
      
    } on StorageException catch (e) {
      throw Exception(
        '$debugInfo\n'
        '--- ERROR DE STORAGE ---\n'
        'Código HTTP: ${e.statusCode}\n'
        'Mensaje: ${e.message}\n'
        'Error completo: $e'
      );
    } catch (e) {
      throw Exception('$debugInfo\n--- ERROR ---\n$e');
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
      await _supabase.storage.from('IMAGENES').remove([fileName]);
    } catch (e) {
      throw Exception('Error al eliminar imagen: $e');
    }
  }
}
