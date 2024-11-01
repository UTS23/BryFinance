import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PayScreen extends StatefulWidget {
  @override
  _PayScreenState createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  final TextEditingController _providerController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagar'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Realizar un Pago',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _providerController,
                decoration: InputDecoration(
                  labelText: 'Proveedor o Servicio',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Monto',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _processPayment();
                },
                child: const Text('Pagar'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    final String provider = _providerController.text;
    final String? amountText = _amountController.text;

    if (provider.isEmpty) {
      _showSnackbar('Por favor, ingresa un proveedor o servicio.');
      return;
    }

    if (amountText!.isEmpty) {
      _showSnackbar('Por favor, ingresa un monto válido.');
      return;
    }

    double amount = double.tryParse(amountText) ?? 0.0;

    if (amount <= 0) {
      _showSnackbar('El monto debe ser mayor a cero.');
      return;
    }

    // Obtener el ID del usuario desde SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId != null) {
      try {
        // Registrar el pago en la colección 'transacciones'
        await _firestore.collection('transacciones').add({
          'userId': userId,
          'descripcion': provider,
          'monto': -amount, // Negativo para indicar un gasto
          'fecha': FieldValue.serverTimestamp(), // Marca de tiempo del servidor
        });

        _showSnackbar(
            'Pago exitoso de \$${amount.toStringAsFixed(2)} para $provider.');
        _providerController.clear(); // Limpiar el campo de texto
        _amountController.clear(); // Limpiar el campo de texto
      } catch (e) {
        _showSnackbar('Error al realizar el pago: $e');
      }
    } else {
      _showSnackbar('Error al obtener el usuario.');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
