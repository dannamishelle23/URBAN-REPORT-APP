import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_input.dart';
import 'widgets/auth_layout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _authService = AuthService();

  double _passwordStrength = 0.0;
  bool _obscurePassword = true;
  bool _hasMinLength = false;
  bool _hasNumber = false;
  bool _hasSymbol = false;
  bool _showPasswordStrength = false;
  bool _loading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _passwordCtrl.addListener(() {
      _onPasswordChanged(_passwordCtrl.text);
    });
    _animController.forward();
  }

  void _onPasswordChanged(String value) {
  setState(() {
    _showPasswordStrength = value.isNotEmpty;
    _hasMinLength = value.length >= 6;
    _hasNumber = RegExp(r'\d').hasMatch(value);
    _hasSymbol = RegExp(r'[-_!@#$%^&*(),.?":{}|<>]').hasMatch(value);

    int score = 0;
    if (_hasMinLength) score++;
    if (_hasNumber) score++;
    if (_hasSymbol) score++;

    _passwordStrength = score / 3;
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String get _passwordStrengthText {
    if (_passwordStrength < 0.34) {
      return 'Débil';
    } else if (_passwordStrength < 0.67) {
      return 'Media';
    } else {
      return 'Fuerte';
    }
  }

    Color get _passwordStrengthColor {
      if (_passwordStrength < 0.34) {
        return const Color(0xFFdc2626);
      } else if (_passwordStrength < 0.67) {
        return const Color(0xFFf59e0b);
      } else {
        return const Color(0xFF10b981);
      }
    }

  Future<void> _register() async {
  if (_loading) return; 
  if (!_formKey.currentState!.validate()) return;

  try {
    setState(() => _loading = true);
    final email = _emailCtrl.text.trim().toLowerCase();
    await _authService.register(
      email: email,
      password: _passwordCtrl.text.trim(),
    );

    _showMessage(
      'Registro exitoso 🎉 Revisa tu correo para confirmar la cuenta',
    );

    Navigator.pop(context);
  } on AuthException catch (e) {
    _handleAuthError(e.message);
  } catch (e) {
    _showError('Error al registrar usuario');
  } finally {
    setState(() => _loading = false);
  }
}

  void _handleAuthError(String message) {
    if (message.contains('already registered')) {
      _showError('Este correo ya está registrado');
    } else if (message.contains('Password should be')) {
      _showError('La contraseña es muy débil');
    } else {
      _showError(message);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: '',
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(
                Icons.person_add_alt_1,
                size: 70,
                color: Color(0xFF1e3a8a),
              ),
              const SizedBox(height: 16),

              const Text(
                'Crear cuenta',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Regístrate para comenzar a reportar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 32),
              AuthInput(
                controller: _nameCtrl,
                label: 'Nombre completo',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo no puede quedar vacío.';
                  }
                  if (value.length < 3) {
                    return 'El nombre es muy corto.';
                  }
                  return null;
                },
              ),

              AuthInput(
                controller: _phoneCtrl,
                label: 'Teléfono',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo no puede ser vacío.';
                  }
                  if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                    return 'El teléfono debe tener 10 dígitos.';
                  }
                  return null;
                },
              ),
              
              AuthInput(
                autocorrect: false,
                enableSuggestions: false,
                textCapitalization: TextCapitalization.none,
                controller: _emailCtrl,
                label: 'Correo electrónico',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo no puede quedar vacío.';
                  }
                  final email = value.trim();
                  final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(email)) {
                    return 'Correo electrónico no válido.';
                  }
                  return null;
                },
              ),

              AuthInput(
                controller: _passwordCtrl,
                label: 'Contraseña',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo no puede quedar vacío.';
                  }
                  if (!(_hasMinLength && _hasNumber && _hasSymbol)) {
                    return 'La contraseña no cumple los requisitos';
                  }
                  return null;
                },
                keyboardType: TextInputType.visiblePassword,
              ),

              if (_showPasswordStrength) ...[
                const SizedBox(height: 6),
                Text(
                  _passwordStrengthText,
                  style: TextStyle(
                    color: _passwordStrengthColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
              ),

              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0,
                  end: _passwordStrength,
                ),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade300,
                    color: _passwordStrengthColor,
                  );
                },
              ),

              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PasswordCheck(
                      text: 'Mínimo 6 caracteres',
                      checked: _hasMinLength,
                    ),
                    _PasswordCheck(
                      text: 'Contiene un número',
                      checked: _hasNumber,
                    ),
                    _PasswordCheck(
                      text: 'Contiene un símbolo',
                      checked: _hasSymbol,
                    ),
                  ],
              ),
            ],

              AuthInput(
                controller: _confirmCtrl,
                label: 'Confirmar contraseña',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  if (value != _passwordCtrl.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              AuthButton(
                text: 'Registrarme',
                loading: _loading,
                onPressed: (_passwordStrength == 1.0 && !_loading)
                    ? _register
                    : null,
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('¿Ya tienes cuenta? Inicia sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordCheck extends StatelessWidget {
  final String text;
  final bool checked;

  const _PasswordCheck({
    required this.text,
    required this.checked,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          checked ? Icons.check_circle : Icons.radio_button_unchecked,
          color: checked ? Colors.green : Colors.grey,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: checked ? Colors.green : Colors.grey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}