//Listar reportes
import 'package:flutter/material.dart';
import '../models/reporte.dart';
import '../services/report_service.dart';
import 'report_detail_screen.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final _service = ReportService();
  late Future<List<Reporte>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getMisReportes();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _service.getMisReportes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<Reporte>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error cargando reportes'));
          }

          final reportes = snapshot.data ?? [];

          if (reportes.isEmpty) {
            return const Center(child: Text('No tienes reportes'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reportes.length,
            itemBuilder: (_, i) {
              final r = reportes[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.report),
                  title: Text(r.titulo),
                  subtitle: Text(r.descripcion),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ReportDetailScreen(reporte: r),
                      ),
                    );
                    _refresh();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
