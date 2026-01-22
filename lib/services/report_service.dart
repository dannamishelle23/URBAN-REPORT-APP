//CRUD de reportes usando Supabase
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reporte.dart';

class ReportService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtener reportes del usuario autenticado
  Future<List<Reporte>> getMisReportes() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _supabase
        .from('reportes')
        .select()
        .eq('usuario_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => Reporte.fromMap(item))
        .toList();
  }

  /// Crear nuevo reporte
  Future<void> crearReporte(Reporte reporte) async {
    await _supabase.from('reportes').insert(reporte.toMap());
  }

  /// Eliminar reporte
  Future<void> eliminarReporte(String id) async {
    await _supabase.from('reportes').delete().eq('id', id);
  }

  /// Actualizar reporte
  Future<void> actualizarReporte(String id, Map<String, dynamic> data) async {
    await _supabase.from('reportes').update(data).eq('id', id);
  }
}
