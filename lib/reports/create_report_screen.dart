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
  String? _errorMessage; // Para mostrar errores en la UI

  @override
  void initState() {
    super.initState();
    _mostrarDiagnostico();
  }

  Future<void> _mostrarDiagnostico() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    String diagnostico = '';
    bool hayError = false;
    
    try {
      // Verificar conexión a Supabase
      diagnostico += 'Verificando conexión a Supabase...\n';
      final user = Supabase.instance.client.auth.currentUser;
      diagnostico += 'Usuario: ${user?.email ?? "No autenticado"}\n';
      diagnostico += 'User ID: ${user?.id ?? "N/A"}\n\n';
      
      // Intentar listar buckets
      diagnostico += 'Intentando listar buckets...\n';
      try {
        final buckets = await Supabase.instance.client.storage.listBuckets();
        if (buckets.isEmpty) {
          diagnostico += 'Lista vacía (normal con anon key)\n';
        } else {
          final nombres = buckets.map((b) => b.name).join(', ');
          diagnostico += 'Buckets: $nombres\n';
        }
      } catch (e) {
        diagnostico += 'No se pudo listar buckets: $e\n';
        diagnostico += '(Esto es normal con anon key)\n';
      }
      
      diagnostico += '\nEl bucket "imagenes" debe existir en Supabase.';
      
    } catch (e) {
      hayError = true;
      diagnostico += '\nError general: $e';
    }
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text(hayError ? 'Error de Diagnóstico' : 'Diagnóstico'),
        content: SingleChildScrollView(
          child: SelectableText(
            diagnostico,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

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
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('❌ Error'),
          content: const Text('Debe seleccionar ubicación e imagen'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    
    if (user == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('❌ Error'),
          content: const Text('Usuario no autenticado'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null; // Limpiar error anterior
    });

    try {
      final imageUrl = await _storageService.uploadImage(_imagen!, user.id);

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

      if (mounted) {
        // Limpiar el formulario
        _tituloCtrl.clear();
        _descripcionCtrl.clear();
        setState(() {
          _imagen = null;
          _ubicacion = null;
          _categoria = 'bache';
        });
        
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte creado exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      final errorStr = e.toString();
      if (mounted) {
        setState(() => _errorMessage = errorStr);
        // Mostrar SnackBar como notificación adicional
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al guardar. Ver detalles abajo.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Crear Reporte'),
        backgroundColor: const Color(0xFF1e3a8a),
        foregroundColor: Colors.white,
      ),
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

              // Imagen
              const Text(
                'Foto del problema',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1e3a8a),
                ),
              ),
              const SizedBox(height: 12),

              if (_imagen == null)
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF3b82f6),
                        width: 2.5,
                      ),
                      color: const Color(0xFFF0F4FF),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 60,
                            color: Color(0xFF1e3a8a),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Toque para agregar foto',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1e3a8a),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        _imagen!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: _pickImage,
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF1e3a8a),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // Ubicación
              const Text(
                'Ubicación del problema',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1e3a8a),
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
                  ),
                  label: Text(
                    _ubicacion == null
                        ? 'Seleccionar ubicación'
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

              // Mostrar error si existe
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Error al guardar:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setState(() => _errorMessage = null),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        _errorMessage!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1e3a8a),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Guardar Reporte',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }
}
