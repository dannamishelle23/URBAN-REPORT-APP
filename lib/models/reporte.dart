//Representa la tabla reportes en Supabase
class Reporte {
  final String id;
  final String usuarioId;
  final String titulo;
  final String descripcion;
  final String categoria;
  final String estado;
  final double latitud;
  final double longitud;
  final String? fotoUrl;
  final DateTime createdAt;

  Reporte({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.estado,
    required this.latitud,
    required this.longitud,
    this.fotoUrl,
    required this.createdAt,
  });

  /// Convierte JSON de Supabase a objeto Dart
  factory Reporte.fromMap(Map<String, dynamic> map) {
    return Reporte(
      id: map['id'],
      usuarioId: map['usuario_id'],
      titulo: map['titulo'],
      descripcion: map['descripcion'],
      categoria: map['categoria'],
      estado: map['estado'],
      latitud: (map['latitud'] as num).toDouble(),
      longitud: (map['longitud'] as num).toDouble(),
      fotoUrl: map['foto_url'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  /// Convierte objeto Dart a JSON para Supabase
  Map<String, dynamic> toMap() {
    return {
      'usuario_id': usuarioId,
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'estado': estado,
      'latitud': latitud,
      'longitud': longitud,
      'foto_url': fotoUrl,
    };
  }
}
