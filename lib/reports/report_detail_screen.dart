import 'package:flutter/material.dart';
import '../models/reporte.dart';
import '../services/report_service.dart';

class ReportDetailScreen extends StatefulWidget {
  final Reporte reporte;

  const ReportDetailScreen({super.key, required this.reporte});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final _service = ReportService();

  late TextEditingController _tituloCtrl;
  late TextEditingController _descripcionCtrl;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.reporte.titulo);
    _descripcionCtrl =
        TextEditingController(text: widget.reporte.descripcion);
  }

  Future<void> _guardarCambios() async {
    setState(() => _loading = true);
    await _service.actualizarReporte(widget.reporte.id, {
      'titulo': _tituloCtrl.text.trim(),
      'descripcion': _descripcionCtrl.text.trim(),
    });
    if (mounted) Navigator.pop(context);
  }

  Future<void> _eliminar() async {
    await _service.eliminarReporte(widget.reporte.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Reporte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _eliminar,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (widget.reporte.fotoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.reporte.fotoUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            if (widget.reporte.fotoUrl != null)
              const SizedBox(height: 16),
            TextField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descripcionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _guardarCambios,
                child: const Text('Guardar cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
