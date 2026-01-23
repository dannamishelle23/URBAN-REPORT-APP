import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _loading = true;
  bool _editing = false;

  String? _email;
  String? _avatarUrl;
  File? _newAvatar;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      _email = data['email'];
      _avatarUrl = data['avatar_url'];
      _nameCtrl.text = data['full_name'] ?? '';
      _phoneCtrl.text = data['telefono'] ?? '';
    } catch (_) {
      _showError('Error al cargar perfil');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Wrap(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFe2e8f0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF1e3a8a)),
                title: const Text(
                  'Tomar foto',
                  style: TextStyle(color: Color(0xFF1e3a8a), fontWeight: FontWeight.w500),
                ),
                onTap: () async {
                  final picked = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 70,
                  );
                  if (picked != null) {
                    setState(() => _newAvatar = File(picked.path));
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo, color: Color(0xFF1e3a8a)),
                title: const Text(
                  'Elegir de galería',
                  style: TextStyle(color: Color(0xFF1e3a8a), fontWeight: FontWeight.w500),
                ),
                onTap: () async {
                  final picked = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 70,
                  );
                  if (picked != null) {
                    setState(() => _newAvatar = File(picked.path));
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _uploadAvatar(String userId) async {
    if (_newAvatar == null) return _avatarUrl;

    final supabase = Supabase.instance.client;
    final fileExt = _newAvatar!.path.split('.').last;
    final filePath = '$userId/avatar.$fileExt';

    await supabase.storage.from('avatars').upload(
          filePath,
          _newAvatar!,
          fileOptions: const FileOptions(upsert: true),
        );

    return supabase.storage.from('avatars').getPublicUrl(filePath);
  }

  Future<void> _saveProfile() async {
    try {
      setState(() => _loading = true);

      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final avatarUrl = await _uploadAvatar(user.id);

      await supabase.from('profiles').update({
        'full_name': _nameCtrl.text.trim(),
        'telefono': _phoneCtrl.text.trim(),
        'avatar_url': avatarUrl,
      }).eq('id', user.id);

      setState(() {
        _editing = false;
        _avatarUrl = avatarUrl;
        _newAvatar = null;
      });

      _showSuccess('Perfil actualizado');
    } catch (_) {
      _showError('Error al guardar cambios');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFdc2626),
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF10b981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1e3a8a),
        elevation: 2,
        shadowColor: const Color(0xFF1e3a8a),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _editing = !_editing);
            },
            child: Text(
              _editing ? 'Cancelar' : 'Editar',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          )
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF1e3a8a),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  // Avatar con efecto
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: _editing ? _pickImage : null,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1e3a8a).withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: const Color(0xFFe2e8f0),
                            backgroundImage: _newAvatar != null
                                ? FileImage(_newAvatar!)
                                : (_avatarUrl != null
                                    ? NetworkImage(_avatarUrl!)
                                    : null) as ImageProvider?,
                            child: (_avatarUrl == null && _newAvatar == null)
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Color(0xFF1e3a8a),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      if (_editing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF1e3a8a),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),

                  if (_editing)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Toca para cambiar foto',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94a3b8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Correo (no editable)
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        labelStyle: const TextStyle(
                          color: Color(0xFF1e3a8a),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        hintText: _email,
                        hintStyle: const TextStyle(
                          color: Color(0xFF94a3b8),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Color(0xFF3b82f6),
                          size: 22,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Nombre
                  Card(
                    elevation: _editing ? 2 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: _editing
                            ? const Color(0xFF3b82f6)
                            : const Color(0xFFe2e8f0),
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _nameCtrl,
                      enabled: _editing,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF1e3a8a),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Nombre completo',
                        labelStyle: const TextStyle(
                          color: Color(0xFF1e3a8a),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF3b82f6),
                          size: 22,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        filled: true,
                        fillColor: _editing
                            ? const Color(0xFFF8FAFC)
                            : const Color(0xFFf1f5f9),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Teléfono
                  Card(
                    elevation: _editing ? 2 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: _editing
                            ? const Color(0xFF3b82f6)
                            : const Color(0xFFe2e8f0),
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _phoneCtrl,
                      enabled: _editing,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF1e3a8a),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Teléfono',
                        labelStyle: const TextStyle(
                          color: Color(0xFF1e3a8a),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.phone,
                          color: Color(0xFF3b82f6),
                          size: 22,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        filled: true,
                        fillColor: _editing
                            ? const Color(0xFFF8FAFC)
                            : const Color(0xFFf1f5f9),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Botón Guardar
                  if (_editing)
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1e3a8a),
                              disabledBackgroundColor: const Color(0xFF94a3b8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 6,
                              shadowColor: const Color(0xFF1e3a8a),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    height: 28,
                                    width: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    '✓ Guardar cambios',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            setState(() => _editing = false);
                          },
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF94a3b8),
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() => _editing = true);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF1e3a8a),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(
                          Icons.edit,
                          color: Color(0xFF1e3a8a),
                          size: 20,
                        ),
                        label: const Text(
                          'Editar perfil',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1e3a8a),
                            letterSpacing: 0.3,
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
