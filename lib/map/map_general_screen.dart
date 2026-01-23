import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../models/reporte.dart';
import '../services/report_service.dart';

class MapGeneralScreen extends StatefulWidget {
  const MapGeneralScreen({super.key});

  @override
  State<MapGeneralScreen> createState() => _MapGeneralScreenState();
}

class _MapGeneralScreenState extends State<MapGeneralScreen> {
  final _reportService = ReportService();

  LatLng _userLocation = const LatLng(-0.180653, -78.467834); // Quito
  bool _loading = true;
  List<Reporte> _reportes = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _getUserLocation();
    await _loadReportes();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition();
      _userLocation = LatLng(pos.latitude, pos.longitude);
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _loadReportes() async {
    try {
      final data = await _reportService.getMisReportes();
      _reportes = data.where((r) => r.estado != 'resuelto').toList();
    } catch (e) {
      debugPrint('Error cargando reportes: $e');
    }
  }

  Color _getColorByCategory(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'bache':
        return const Color(0xFFf59e0b);
      case 'luminaria':
        return const Color(0xFF3b82f6);
      case 'basura':
        return const Color(0xFF10b981);
      case 'alcantarilla':
        return const Color(0xFF1e3a8a);
      default:
        return const Color(0xFF1e3a8a);
    }
  }


  void _showReporteDetalle(Reporte reporte) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (_) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFe2e8f0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (reporte.fotoUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      reporte.fotoUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFFf1f5f9),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Color(0xFF94a3b8),
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  reporte.titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1e3a8a),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getColorByCategory(reporte.categoria).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getColorByCategory(reporte.categoria),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        reporte.categoria.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getColorByCategory(reporte.categoria),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf59e0b).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFf59e0b),
                          width: 1.5,
                        ),
                      ),
                      child: const Text(
                        'PENDIENTE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFf59e0b),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(height: 1, color: const Color(0xFFe2e8f0)),
                const SizedBox(height: 16),
                Text(
                  'Descripción',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1e3a8a).withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reporte.descripcion,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF475569),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF1e3a8a),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1e3a8a),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF1e3a8a),
                ),
              ),
            )
          : Stack(
              children: [
                _buildMap(),
                if (_reportes.isEmpty) _buildEmptyState(),
              ],
            ),
    );
  }

  Widget _buildMap() {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: _userLocation,
            initialZoom: 14,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.urbanreport',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _userLocation,
                  width: 50,
                  height: 50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1e3a8a).withOpacity(0.25),
                        ),
                      ),
                      const Icon(
                        Icons.my_location,
                        color: Color(0xFF1e3a8a),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            MarkerLayer(
              markers: _reportes.map((reporte) {
                return Marker(
                  point: LatLng(reporte.latitud, reporte.longitud),
                  width: 45,
                  height: 45,
                  child: GestureDetector(
                    onTap: () => _showReporteDetalle(reporte),
                    child: Icon(
                      Icons.location_pin,
                      size: 45,
                      color: _getColorByCategory(reporte.categoria),
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLegendItem('🕳️', 'Bache', const Color(0xFFf59e0b)),
                const SizedBox(height: 10),
                _buildLegendItem('💡', 'Luminaria', const Color(0xFF3b82f6)),
                const SizedBox(height: 10),
                _buildLegendItem('🗑️', 'Basura', const Color(0xFF10b981)),
                const SizedBox(height: 10),
                _buildLegendItem('📍', 'Otro', const Color(0xFF1e3a8a)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.info_outline,
              color: Color(0xFF1e3a8a),
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'Aún no hay reportes en esta zona',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Sé el primero en reportar un problema',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748b),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String emoji, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
