import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RechargeScreen extends StatefulWidget {
  @override
  _RechargeScreenState createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  final TextEditingController _amountController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false; // Estado de carga

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recargar'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: isLoading // Verificar si está cargando
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ) // Mostrar el cargador
                : SingleChildScrollView(
                    // Agregar desplazamiento
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿Cuánto deseas recargar?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Monto',
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            filled: true, // Fondo blanco
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.deepPurple, width: 2.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed:
                              _confirmRecharge, // Llamar directamente a la función
                          child: const Text('Confirmar Recarga'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.deepPurple,
                            backgroundColor: Colors.white, // Color del texto
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.deepPurple),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '¡Recarga tu saldo de manera fácil y rápida!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRecharge() async {
    final String? amountText = _amountController.text;
    if (amountText!.isEmpty) {
      _showSnackbar('Por favor, ingresa un monto válido.');
      return;
    }

    double amount = double.tryParse(amountText) ?? 0.0;

    if (amount <= 0) {
      _showSnackbar('El monto debe ser mayor a cero.');
      return;
    }

    // Cambiar el estado de carga a true
    setState(() {
      isLoading = true;
    });

    // Obtener el ID del usuario desde SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId != null) {
      try {
        // Insertar o actualizar el saldo en Firestore
        await _firestore.collection('saldos').doc(userId).set(
          {
            'saldos': FieldValue.increment(amount),
          },
          SetOptions(merge: true), // Usar merge para insertar o actualizar
        );

        // Registrar la transacción en la colección 'transacciones'
        await _firestore.collection('transacciones').add({
          'userId': userId,
          'monto': amount,
          'fecha': FieldValue.serverTimestamp(), // Marca de tiempo del servidor
        });

        _showSnackbar('Recarga exitosa de \$${amount.toStringAsFixed(2)}');
        _amountController.clear(); // Limpiar el campo de texto
      } catch (e) {
        _showSnackbar('Error al realizar la recarga: $e');
      }
    } else {
      _showSnackbar('Error al obtener el usuario.');
    }

    // Cambiar el estado de carga a false
    setState(() {
      isLoading = false;
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
