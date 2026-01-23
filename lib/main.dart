import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_dotenv/flutter_dotenv.dart';
// ignore: depend_on_referenced_packages
import 'package:supabase_flutter/supabase_flutter.dart';
// Auth
import 'auth/login_screen.dart';
import 'auth/reset_password_screen.dart';
// Splash
import 'splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
    debug: false,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UrbanReport',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueAccent,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
      home: SplashScreen(nextScreen: const AuthGate()),
    );
  }
}

//Decide que pantalla mostrar segun el inicio de sesion
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showResetPassword = false;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        setState(() => _showResetPassword = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResetPassword) {
      return const ResetPasswordScreen();
    }

    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;

        // Mientras carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Si NO hay sesion -> Login
        if (session == null) {
          return const LoginScreen();
        }

        // Si hay sesion -> Enviar al dashboard principal
        return const DashboardScreen();
      },
    );
  }
}

class HomeTemp extends StatelessWidget {
  const HomeTemp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UrbanReport'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          )
        ],
      ),
      body: const Center(
        child: Text(
          'Sesión iniciada correctamente 🚀',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

