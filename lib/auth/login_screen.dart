import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'register_screen.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_input.dart';
import 'widgets/auth_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _loading = true);
      await _authService.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_emailCtrl.text.isEmpty) {
      _showError('Ingrese su correo');
      return;
    }

    await _authService.resetPassword(_emailCtrl.text.trim());
    _showMessage('Correo de recuperación enviado');
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Iniciar Sesión',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AuthInput(
              controller: _emailCtrl,
              label: 'Correo electrónico',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese su correo';
                }
                if (!value.contains('@')) {
                  return 'Correo no válido';
                }
                return null;
              },
            ),
            AuthInput(
              controller: _passwordCtrl,
              label: 'Contraseña',
              obscureText: true,
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Mínimo 6 caracteres';
                }
                return null;
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _resetPassword,
                child: const Text('¿Olvidaste tu contraseña?'),
              ),
            ),
            const SizedBox(height: 16),
            AuthButton(
              text: 'Ingresar',
              loading: _loading,
              onPressed: _login,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterScreen(),
                  ),
                );
              },
              child: const Text('¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}
