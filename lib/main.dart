import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/login_screen.dart';
import 'auth/reset_password_screen.dart';
import 'splash/splash_screen.dart';

// Variable global para saber si el login fue manual
bool isManualLogin = false;

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

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showResetPassword = false;
  String? _confirmationMessage;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      
      if (event == AuthChangeEvent.passwordRecovery) {
        setState(() => _showResetPassword = true);
        return;
      }
      
      if (event == AuthChangeEvent.signedIn) {
        // Si NO fue login manual, viene de confirmacion de email
        if (!isManualLogin) {
          await Supabase.instance.client.auth.signOut();
          if (mounted) {
            setState(() {
              _confirmationMessage = 'Cuenta confirmada. Por favor inicia sesion.';
            });
          }
        }
        // Resetear la variable
        isManualLogin = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResetPassword) {
      return const ResetPasswordScreen();
    }

    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      return LoginScreen(confirmationMessage: _confirmationMessage);
    }

    return const DashboardScreen();
  }
}