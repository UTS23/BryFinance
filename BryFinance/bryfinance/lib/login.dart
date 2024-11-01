import 'package:bryfinance/admin.dart';
import 'package:bryfinance/home.dart';
import 'package:bryfinance/registro.dart';
import 'package:bryfinance/reset.dart';
import 'package:bryfinance/usuario.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart'; // Importa la nueva dependencia

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _areButtonsVisible = false;

  Future<void> _login() async {
    String userId = _userController.text.trim();
    String password = _passwordController.text.trim();

    if (userId.isEmpty && password == "9410") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminScreen()),
      );
      return;
    }

    if (userId.isEmpty || password.isEmpty) {
      _showDialog('Por favor, ingresa usuario y contraseña');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool locationExists = await _checkLocationExists(userId);

    if (locationExists) {
      _attemptLogin(userId, password);
    } else {
      await _attemptLogin(userId, password);
    }
  }

  Future<bool> _checkLocationExists(String userId) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('ubicaciones')
        .where('userId', isEqualTo: userId)
        .get();
    return result.docs.isNotEmpty;
  }

  Future<void> _attemptLogin(String userId, String password) async {
    try {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('clientes')
          .where('usuario', isEqualTo: userId)
          .where('contrasena', isEqualTo: password)
          .get();

      setState(() {
        _isLoading = false;
      });

      if (result.docs.isNotEmpty) {
        _showDialog('Bienvenido de nuevo, $userId');

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', userId);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        _showDialog('Usuario o contraseña incorrectos');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showDialog('Error al iniciar sesión: $e');
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Información',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
    );
  }

  void _forgotUsername() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotUsernameScreen()),
    );
  }

  void _toggleButtons() {
    setState(() {
      _areButtonsVisible = !_areButtonsVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            elevation: 12.0,
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/images/secury.json', // Asegúrate de que la ruta sea correcta
                    width: 100,
                    height: 100,
                  ),
                  Text(
                    "Bienvenido a BryFinance",
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(_userController, "Usuario", Icons.person),
                  const SizedBox(height: 20),
                  _buildTextField(
                    _passwordController,
                    "Contraseña",
                    Icons.lock,
                    obscureText: !_isPasswordVisible,
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: const Text(
                            "Iniciar Sesión",
                            style:
                                TextStyle(fontSize: 18.0, color: Colors.white),
                          ),
                        ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterScreen()),
                      );
                    },
                    child: const Text(
                      "¿No tienes cuenta? Regístrate aquí",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Inicia sesión para acceder a todas las funcionalidades",
                    style: TextStyle(color: Colors.black, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          AnimatedOpacity(
            opacity: _areButtonsVisible ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  onPressed: _forgotUsername,
                  tooltip: 'Olvidaste tu usuario',
                  child: Icon(Icons.person_off),
                  backgroundColor: Colors.deepPurple,
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _resetPassword,
                  tooltip: 'Restablecer Contraseña',
                  child: Icon(Icons.lock_reset),
                  backgroundColor: Colors.deepPurple,
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          FloatingActionButton(
            onPressed: _toggleButtons,
            tooltip: 'Más Opciones',
            child: Lottie.asset(
              'assets/images/mas.json', // Asegúrate de que la ruta sea correcta
              width: 24,
              height: 24,
            ),
            backgroundColor: Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.black),
        ),
        prefixIcon: Icon(icon, color: Colors.black),
        suffixIcon: obscureText
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }
}
