import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart'; // Importar el paquete Lottie

class ForgotUsernameScreen extends StatefulWidget {
  @override
  _ForgotUsernameScreenState createState() => _ForgotUsernameScreenState();
}

class _ForgotUsernameScreenState extends State<ForgotUsernameScreen> {
  final TextEditingController _cedulaController = TextEditingController();
  bool _isLoading = false; // Estado de carga

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recuperar Usuario'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Agregar la animación Lottie
              Lottie.asset(
                'assets/images/bank.json',
                height: 150,
              ),
              const SizedBox(height: 20),
              _buildCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // Bordes más redondeados
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Ingresa tu número de cédula",
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _cedulaController,
              decoration: InputDecoration(
                labelText: 'Número de Cédula',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                prefixIcon: Icon(Icons.person, color: Colors.deepPurple),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      _retrieveUsername(context);
                    },
                    child: Text('Enviar Información del Usuario'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _retrieveUsername(BuildContext context) async {
    String cedula = _cedulaController.text.trim();

    if (cedula.isEmpty) {
      _showDialog(context, 'Por favor, ingresa tu número de cédula',
          'assets/images/privacy.json');
      return;
    }

    setState(() {
      _isLoading = true; // Activar el estado de carga
    });

    try {
      // Consultar Firestore para ver si la cédula existe
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('clientes')
          .where('cedula', isEqualTo: cedula)
          .get();

      if (result.docs.isNotEmpty) {
        // Si se encuentra la cédula, mostrar el nombre de usuario
        String username = result.docs.first['usuario'];
        _showDialog(context, 'Tu nombre de usuario es: $username',
            'assets/images/privacy.json');
      } else {
        // Si no se encuentra la cédula
        _showDialog(context, 'Número de cédula no encontrado.',
            'assets/images/privacy.json');
      }
    } catch (e) {
      _showDialog(context, 'Error al recuperar el usuario: $e',
          'assets/images/privacy.json');
    } finally {
      setState(() {
        _isLoading = false; // Desactivar el estado de carga
      });
    }
  }

  void _showDialog(BuildContext context, String message, String animationPath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Bordes redondeados
          ),
          title: Text('Información',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(animationPath,
                  height: 100), // Agregar animación Lottie al diálogo
              const SizedBox(height: 10),
              Text(message, textAlign: TextAlign.center), // Alinear el texto
            ],
          ),
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
}
