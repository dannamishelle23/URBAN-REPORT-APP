import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_input.dart';
import 'widgets/auth_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _loading = true);
      await _authService.register(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa tu correo para confirmar la cuenta'),
        ),
      );
      Navigator.pop(context);
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
    return AuthLayout(
      title: 'Crear Cuenta',
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
                  return 'La contraseña debe contener mínimo 6 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            AuthButton(
              text: 'Registrarse',
              loading: _loading,
              onPressed: _register,
            ),
          ],
        ),
      ),
    );
  }
}
