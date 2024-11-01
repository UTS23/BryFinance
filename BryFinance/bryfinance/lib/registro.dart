import 'package:bryfinance/terminos.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _monthlyIncomeController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _termsAccepted = false;
  int _currentPage = 0;

  List<Map<String, dynamic>> _fields = [
    {"controller": "name", "label": "Nombre", "icon": Icons.person},
    {"controller": "surname", "label": "Apellidos", "icon": Icons.person},
    {"controller": "email", "label": "Correo Electrónico", "icon": Icons.email},
    {"controller": "username", "label": "Usuario", "icon": Icons.person},
    {"controller": "age", "label": "Edad", "icon": Icons.calendar_today},
    {"controller": "occupation", "label": "Ocupación", "icon": Icons.work},
    {
      "controller": "password",
      "label": "Contraseña (numérica)",
      "icon": Icons.lock
    },
    {
      "controller": "monthlyIncome",
      "label": "Ingresos Mensuales",
      "icon": Icons.money
    },
  ];

  List<String> _securityAdvice = [
    '1. La contraseña solo puede ser números.',
    '2. No compartas tu contraseña con nadie.',
    '3. Cambia tu contraseña regularmente.',
    '4. Verifica siempre la autenticidad de la aplicación antes de ingresar tu información personal.',
    '5. Mantén tu información financiera en privado.',
  ];

  Future<void> _register() async {
    if (_formKey.currentState!.validate() && _termsAccepted) {
      setState(() => _isLoading = true);

      try {
        final username = _usernameController.text;
        final QuerySnapshot result = await FirebaseFirestore.instance
            .collection('clientes')
            .where('usuario', isEqualTo: username)
            .get();

        if (result.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('El nombre de usuario ya está en uso')),
          );
          return;
        }

        await FirebaseFirestore.instance.collection('clientes').add({
          'nombre': _nameController.text,
          'apellidos': _surnameController.text,
          'email': _emailController.text,
          'usuario': username,
          'edad': int.parse(_ageController.text),
          'ocupacion': _occupationController.text,
          'contrasena': _passwordController.text,
          'ingresos_mensuales':
              double.tryParse(_monthlyIncomeController.text) ?? 0.0,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario registrado exitosamente')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar el usuario: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } else if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, acepta los términos y condiciones')),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _fields.length - 1) {
      setState(() => _currentPage++);
    } else {
      _register();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro"),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.teal.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                Expanded(
                  child: Center(
                    child: Lottie.asset(
                      'assets/images/register.json',
                      width: 200,
                      height: 200,
                    ),
                  ),
                )
              else ...[
                Expanded(
                  child: Center(
                    child: _buildField(
                      _fields[_currentPage]["label"],
                      _fields[_currentPage]["icon"],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildProgressIndicator(),
                const SizedBox(height: 20),
                _buildSecurityAdvice(),
                const SizedBox(height: 20),
                if (_currentPage < _fields.length - 1)
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      backgroundColor: Colors.black,
                      elevation: 3,
                    ),
                    child: const Text("Continuar"),
                  )
                else
                  Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _termsAccepted,
                            activeColor: Colors.deepPurple,
                            onChanged: (value) =>
                                setState(() => _termsAccepted = value!),
                          ),
                          const Expanded(
                            child: Text(
                              "Acepto los términos y condiciones",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TermsAndConditionsScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Ver Términos",
                              style: TextStyle(color: Colors.deepPurple),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          backgroundColor: Colors.deepPurple,
                          elevation: 3,
                        ),
                        child: const Text("Registrarse"),
                      ),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, IconData icon) {
    TextEditingController controller;

    switch (label) {
      case "Nombre":
        controller = _nameController;
        break;
      case "Apellidos":
        controller = _surnameController;
        break;
      case "Correo Electrónico":
        controller = _emailController;
        break;
      case "Usuario":
        controller = _usernameController;
        break;
      case "Edad":
        controller = _ageController;
        break;
      case "Ocupación":
        controller = _occupationController;
        break;
      case "Contraseña (numérica)":
        controller = _passwordController;
        break;
      case "Ingresos Mensuales":
        controller = _monthlyIncomeController;
        break;
      default:
        controller = TextEditingController();
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          controller: controller,
          obscureText: label == "Contraseña (numérica)",
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            prefixIcon: Icon(icon, color: Colors.deepPurple),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal, width: 2.0),
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, completa este campo';
            }

            if (label == "Correo Electrónico") {
              final emailRegex =
                  RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Por favor, introduce un correo electrónico válido';
              }
            }

            if (label == "Contraseña (numérica)") {
              if (!RegExp(r'^\d{1,4}$').hasMatch(value)) {
                return 'La contraseña debe ser numérica y tener hasta 4 dígitos';
              }
            }

            return null; // Válido
          },
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    double progress = (_currentPage + 1) / _fields.length;

    return LinearProgressIndicator(
      value: progress,
      backgroundColor: Colors.grey.shade300,
      color: Colors.deepPurple,
    );
  }

  Widget _buildSecurityAdvice() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consejo de Seguridad:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 10),
            Text(
              _securityAdvice[_currentPage % _securityAdvice.length],
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
