import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/reporte.dart';
import '../services/report_service.dart';
import '../reports/create_report_screen.dart';
import '../reports/report_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _reportService = ReportService();

  Future<List<Reporte>> _cargarReportes() {
    return _reportService.getMisReportes();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reportes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
        ],
      ),

      // 🔽 ESTE ES EL BODY
      body: FutureBuilder<List<Reporte>>(
        future: _cargarReportes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar reportes'));
          }

          final reportes = snapshot.data ?? [];

          if (reportes.isEmpty) {
            return const Center(
              child: Text('Aún no tienes reportes creados'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reportes.length,
            itemBuilder: (context, index) {
              final reporte = reportes[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  title: Text(reporte.titulo),
                  subtitle: Text(
                    '${reporte.categoria} • ${reporte.estado}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ReportDetailScreen(reporte: reporte),
                      ),
                    ).then((_) => setState(() {})); // 🔁 refresca
                  },
                ),
              );
            },
          );
        },
      ),

      // 🔽 ESTE ES EL BOTÓN +
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateReportScreen(),
            ),
          ).then((_) => setState(() {})); // 🔁 refresca
        },
      ),
    );
  }
}
