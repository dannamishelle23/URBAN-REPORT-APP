//Crear nuevo reporte
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';

import '../services/report_service.dart';
import '../services/storage_service.dart';
import '../models/reporte.dart';
import '../map/map_picker_screen.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();

  final _reportService = ReportService();
  final _storageService = StorageService();
  final _picker = ImagePicker();

  String _categoria = 'bache';
  LatLng? _ubicacion;
  File? _imagen;
  bool _loading = false;

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Wrap(
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
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF1e3a8a)),
                title: const Text(
                  'Tomar foto',
                  style: TextStyle(
                    color: Color(0xFF1e3a8a),
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                onTap: () async {
                  final picked = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 70,
                  );
                  if (picked != null) {
                    setState(() => _imagen = File(picked.path));
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo, color: Color(0xFF1e3a8a)),
                title: const Text(
                  'Elegir de galería',
                  style: TextStyle(
                    color: Color(0xFF1e3a8a),
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                onTap: () async {
                  final picked = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 70,
                  );
                  if (picked != null) {
                    setState(() => _imagen = File(picked.path));
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_ubicacion == null || _imagen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione ubicación e imagen'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = Supabase.instance.client.auth.currentUser!;
    setState(() => _loading = true);

    try {
      final imageUrl =
          await _storageService.uploadImage(_imagen!, user.id);

      final reporte = Reporte(
        id: '',
        usuarioId: user.id,
        titulo: _tituloCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim(),
        categoria: _categoria,
        estado: 'pendiente',
        latitud: _ubicacion!.latitude,
        longitud: _ubicacion!.longitude,
        fotoUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      await _reportService.crearReporte(reporte);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: const Color(0xFFdc2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Título
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: Color(0xFF3b82f6),
                    width: 1.5,
                  ),
                ),
                child: TextFormField(
                  controller: _tituloCtrl,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1e3a8a),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Título del reporte',
                    labelStyle: TextStyle(
                      color: Color(0xFF1e3a8a),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.title,
                      color: Color(0xFF3b82f6),
                      size: 22,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    filled: true,
                    fillColor: Color(0xFFF8FAFC),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Ingrese un título' : null,
                ),
              ),
              const SizedBox(height: 18),

              // Descripción
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: Color(0xFF3b82f6),
                    width: 1.5,
                  ),
                ),
                child: TextFormField(
                  controller: _descripcionCtrl,
                  maxLines: 4,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1e3a8a),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Descripción detallada',
                    labelStyle: TextStyle(
                      color: Color(0xFF1e3a8a),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.description,
                      color: Color(0xFF3b82f6),
                      size: 22,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    filled: true,
                    fillColor: Color(0xFFF8FAFC),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty
                          ? 'Ingrese una descripción'
                          : null,
                ),
              ),
              const SizedBox(height: 18),

              // Categoría
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: Color(0xFF3b82f6),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField(
                    value: _categoria,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1e3a8a),
                      fontWeight: FontWeight.w500,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'bache',
                        child: Text('🕳️ Bache'),
                      ),
                      DropdownMenuItem(
                        value: 'luminaria',
                        child: Text('💡 Luminaria'),
                      ),
                      DropdownMenuItem(
                        value: 'basura',
                        child: Text('🗑️ Basura'),
                      ),
                      DropdownMenuItem(
                        value: 'otro',
                        child: Text('📍 Otro'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _categoria = v!),
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      labelStyle: TextStyle(
                        color: Color(0xFF1e3a8a),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.category,
                        color: Color(0xFF3b82f6),
                        size: 22,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Imagen - Botón Grande
              Text(
                'Foto del problema',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1e3a8a),
                ),
              ),
              const SizedBox(height: 12),

              if (_imagen == null)
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF3b82f6),
                        width: 2.5,
                      ),
                      color: const Color(0xFFF0F4FF),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF3b82f6).withOpacity(0.15),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 72,
                            color: Color(0xFF1e3a8a),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Cargue su foto',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1e3a8a),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Text(
                            'Toque para tomar una foto\no elegir de su galería',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF94a3b8),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _imagen!,
                          height: 280,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1e3a8a),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.check_circle,
                                color: Color(0xFF10b981),
                                size: 22,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Foto cargada',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Ubicación
              Text(
                'Ubicación del problema',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1e3a8a),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  icon: const Icon(
                    Icons.location_on,
                    color: Color(0xFF1e3a8a),
                    size: 22,
                  ),
                  label: Text(
                    _ubicacion == null
                        ? 'Seleccionar ubicación en mapa'
                        : '✓ Ubicación seleccionada',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1e3a8a),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF1e3a8a),
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MapPickerScreen(),
                      ),
                    );
                    if (result != null) {
                      setState(() => _ubicacion = result);
                    }
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _guardar,
                  icon: _loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.check),
                  label: Text(
                    _loading ? 'Guardando...' : 'Guardar Reporte',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1e3a8a),
                    disabledBackgroundColor: const Color(0xFF94a3b8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 6,
                    shadowColor: const Color(0xFF1e3a8a),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
