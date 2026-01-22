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

  Future<void> _pickCamera() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _imagen = File(picked.path));
    }
  }

  Future<void> _pickGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imagen = File(picked.path));
    }
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
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Reporte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingrese un título' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingrese una descripción' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: _categoria,
                items: const [
                  DropdownMenuItem(value: 'bache', child: Text('Bache')),
                  DropdownMenuItem(value: 'luminaria', child: Text('Luminaria')),
                  DropdownMenuItem(value: 'basura', child: Text('Basura')),
                  DropdownMenuItem(value: 'otro', child: Text('Otro')),
                ],
                onChanged: (v) => setState(() => _categoria = v!),
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
              const SizedBox(height: 16),

              /// 📷 IMAGEN
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: _pickCamera,
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo),
                    onPressed: _pickGallery,
                  ),
                ],
              ),
              if (_imagen != null)
                Image.file(_imagen!, height: 150, fit: BoxFit.cover),

              const SizedBox(height: 16),

              /// 🗺️ MAPA
              OutlinedButton.icon(
                icon: const Icon(Icons.map),
                label: Text(
                  _ubicacion == null
                      ? 'Seleccionar ubicación'
                      : 'Ubicación seleccionada',
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

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _guardar,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Guardar Reporte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
