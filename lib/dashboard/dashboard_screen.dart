import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../map/map_general_screen.dart';
import '../reports/report_list_screen.dart';
import '../reports/create_report_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ReportListScreen(),
    MapGeneralScreen(),
    CreateReportScreen(),
  ];

  final List<String> _titles = const [
    'Mis Reportes',
    'Mapa de Reportes Generales',
    'Crear nuevo Reporte',
  ];

  void _logout() async {
    await Supabase.instance.client.auth.signOut();
    // AuthGate se encarga de volver al Login
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1e3a8a),
        elevation: 2,
        shadowColor: const Color(0xFF1e3a8a),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                _openProfile();
              } else if (value == 'logout') {
                _logout();
              }
            },
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
              size: 28,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: const [
                    Icon(
                      Icons.person_outline,
                      color: Color(0xFF1e3a8a),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Mi perfil',
                      style: TextStyle(
                        color: Color(0xFF1e3a8a),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 8),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: const [
                    Icon(
                      Icons.logout,
                      color: Color(0xFFdc2626),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        color: Color(0xFFdc2626),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1e3a8a),
        unselectedItemColor: const Color(0xFF94a3b8),
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
        ),
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Crear',
          ),
        ],
      ),
    );
  }
}
