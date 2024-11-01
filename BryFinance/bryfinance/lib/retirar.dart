import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WithdrawScreen extends StatefulWidget {
  @override
  _WithdrawScreenState createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _amountController = TextEditingController();
  String _message = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retirar Dinero'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade500,
              Colors.deepPurple.shade300,
              Colors.deepPurple.shade200,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Ingrese el monto a retirar:',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.attach_money,
                        color: Colors.deepPurple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    labelText: 'Monto',
                    labelStyle: const TextStyle(color: Colors.deepPurple),
                    hintText: 'Ejemplo: 50.00',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator(
                        color: Colors.white) // Indicador de carga
                    : ElevatedButton.icon(
                        onPressed: _withdrawMoney,
                        icon: const Icon(Icons.arrow_circle_up),
                        label: const Text('Retirar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                const SizedBox(height: 20),
                Text(
                  _message,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _withdrawMoney() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    String userId = await _getUserId();
    double? amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      setState(() {
        _message = 'Por favor ingrese un monto válido.';
        _isLoading = false;
      });
      return;
    }

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('saldos').doc(userId).get();
      if (userDoc.exists) {
        double currentBalance = userDoc['saldos'] ?? 0.0;

        if (currentBalance >= amount) {
          await _firestore.collection('saldos').doc(userId).update({
            'saldos': currentBalance - amount,
          });

          // Añadir transacción con manejo de errores
          await _firestore.collection('transacciones').add({
            'userId': userId,
            'amount': -amount,
            'date': FieldValue.serverTimestamp(),
            'type': 'retiro',
          }).then((_) {
            print("Transacción registrada exitosamente.");
          }).catchError((error) {
            print("Error al registrar la transacción: $error");
            setState(() {
              _message = 'Error al registrar la transacción.';
            });
          });

          setState(() {
            _message = 'Retiro exitoso de \$${amount.toStringAsFixed(2)}';
            _amountController.clear();
          });
        } else {
          setState(() {
            _message = 'Fondos insuficientes.';
          });
        }
      } else {
        setState(() {
          _message = 'Error: Usuario no encontrado.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error al procesar la transacción: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? '';
  }
}
