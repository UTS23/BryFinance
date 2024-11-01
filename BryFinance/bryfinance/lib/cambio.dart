import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;
  bool _isNewPasswordValid = true; // Control de validación en tiempo real

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String currentPassword = _currentPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // Validaciones de campos vacíos y de confirmación
    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor completa todos los campos.';
        _isLoading = false;
      });
      return;
    }

    // Validación de contraseña numérica de 4 dígitos
    final passwordRegex = RegExp(r'^\d{4}$');
    if (!passwordRegex.hasMatch(newPassword)) {
      setState(() {
        _errorMessage =
            'La nueva contraseña debe ser numérica y tener 4 dígitos.';
        _isLoading = false;
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'Las contraseñas no coinciden.';
        _isLoading = false;
      });
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('clientes')
            .doc(userId)
            .get();

        if (!userDoc.exists || userDoc['password'] != currentPassword) {
          setState(() {
            _errorMessage = 'Contraseña actual incorrecta.';
            _isLoading = false;
          });
          return;
        }

        await FirebaseFirestore.instance
            .collection('clientes')
            .doc(userId)
            .update({
          'password': newPassword,
        });

        setState(() {
          _isLoading = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña cambiada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al cambiar la contraseña';
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al obtener el ID del usuario.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
        backgroundColor: const Color(0xFF4A10AD),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                'Actualizar Contraseña',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade800,
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildPasswordField(
              controller: _currentPasswordController,
              label: 'Contraseña Actual',
              errorText: _errorMessage,
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              controller: _newPasswordController,
              label: 'Nueva Contraseña (4 dígitos numéricos)',
              errorText:
                  _isNewPasswordValid ? null : 'Debe ser numérica de 4 dígitos',
              onChanged: (value) {
                setState(() {
                  _isNewPasswordValid = RegExp(r'^\d{4}$').hasMatch(value);
                });
              },
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'Confirmar Nueva Contraseña',
              errorText: _errorMessage,
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _changePassword,
                icon: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.lock_reset),
                label: Text(
                  _isLoading ? 'Cambiando...' : 'Cambiar Contraseña',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9F9AA8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 15),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    String? errorText,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: !_isPasswordVisible,
      keyboardType: TextInputType.number,
      maxLength: 4,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.deepPurple),
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(color: Colors.deepPurple),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.deepPurple,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );
  }
}
