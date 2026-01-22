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
    setState(() => _loading = false);
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled) return;

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition();
    _userLocation = LatLng(pos.latitude, pos.longitude);
  }

  Future<void> _loadReportes() async {
    //Manejo de errores al cargar reportes
    try {
      final data = await _reportService.getMisReportes();
      _reportes = data.where((r) => r.estado != 'resuelto').toList();
      } catch (e) {
        debugPrint('Error cargando reportes: $e');
      }
  }

  void _showReporteDetalle(Reporte reporte) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (reporte.fotoUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    reporte.fotoUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              if (reporte.fotoUrl != null)
                const SizedBox(height: 12),
              Text(
                reporte.titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Categoría: ${reporte.categoria}'),
              Text('Estado: ${reporte.estado}'),
              const SizedBox(height: 12),
              Text(reporte.descripcion),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de Reportes')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: _userLocation,
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.urbanreport',
                ),

                /// 📍 Marcador del usuario
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ],
                ),

                /// 📌 Marcadores de reportes
                MarkerLayer(
                  markers: _reportes.map((reporte) {
                    return Marker(
                      point: LatLng(reporte.latitud, reporte.longitud),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => _showReporteDetalle(reporte),
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}
