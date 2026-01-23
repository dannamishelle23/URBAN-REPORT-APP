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
  bool _editMode = false; // Modo edicion desactivado por defecto

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.reporte.titulo);
    _descripcionCtrl =
        TextEditingController(text: widget.reporte.descripcion);
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
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

  Future<void> _guardarCambios() async {
    if (_tituloCtrl.text.trim().isEmpty ||
        _descripcionCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos'),
          backgroundColor: Color(0xFFdc2626),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _service.actualizarReporte(widget.reporte.id, {
        'titulo': _tituloCtrl.text.trim(),
        'descripcion': _descripcionCtrl.text.trim(),
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte actualizado'),
            backgroundColor: Color(0xFF10b981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFdc2626),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _eliminar() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar reporte'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este reporte? Esta acción no se puede deshacer.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await _service.eliminarReporte(widget.reporte.id);
                if (mounted) {
                  Navigator.pop(context); // Cerrar diálogo
                  Navigator.pop(context); // Volver a lista
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reporte eliminado'),
                      backgroundColor: Color(0xFF10b981),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: const Color(0xFFdc2626),
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFdc2626),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Detalle del Reporte'),
        backgroundColor: const Color(0xFF1e3a8a),
        elevation: 2,
        shadowColor: const Color(0xFF1e3a8a),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          if (!_editMode)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _editMode = true),
              tooltip: 'Editar reporte',
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _eliminar,
            tooltip: 'Eliminar reporte',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto
            if (widget.reporte.fotoUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.reporte.fotoUrl!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 250,
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
              const SizedBox(height: 24),
            ],

            // Badges de categoría y estado
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _getColorByCategory(widget.reporte.categoria)
                            .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          _getColorByCategory(widget.reporte.categoria),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    widget.reporte.categoria.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getColorByCategory(widget.reporte.categoria),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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
            const SizedBox(height: 20),

            // Título
            Text(
              'Título',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1e3a8a).withOpacity(0.7),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            if (_editMode)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(
                    color: Color(0xFFe2e8f0),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _tituloCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Título del reporte',
                    hintStyle: TextStyle(color: Color(0xFFcbd5e1)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1e3a8a),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFe2e8f0),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  widget.reporte.titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1e3a8a),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Descripción
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
            if (_editMode)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(
                    color: Color(0xFFe2e8f0),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _descripcionCtrl,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Describe el problema',
                    hintStyle: TextStyle(color: Color(0xFFcbd5e1)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF475569),
                    height: 1.6,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFe2e8f0),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  widget.reporte.descripcion,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF475569),
                    height: 1.6,
                  ),
                ),
              ),
            const SizedBox(height: 32),

            // Botones
            if (_editMode)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _editMode = false;
                          _tituloCtrl.text = widget.reporte.titulo;
                          _descripcionCtrl.text = widget.reporte.descripcion;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF1e3a8a),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1e3a8a),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _loading ? null : _guardarCambios,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1e3a8a),
                        disabledBackgroundColor: const Color(0xFF94a3b8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Guardar cambios',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => setState(() => _editMode = true),
                  icon: const Icon(Icons.edit),
                  label: const Text(
                    'Editar reporte',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1e3a8a),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
