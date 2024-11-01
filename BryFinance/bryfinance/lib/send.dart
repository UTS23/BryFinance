import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart'; // Importar Lottie para la animación

class SendScreen extends StatefulWidget {
  @override
  _SendScreenState createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  List<String> _recipients = []; // Lista de destinatarios encontrados
  List<String> _filteredRecipients = []; // Lista filtrada basada en la búsqueda
  double _currentBalance = 0.0; // Saldo actual del usuario

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchRecipients();
    _recipientController.addListener(_filterRecipients);
    _listenToCurrentBalance(); // Escuchar el saldo actual en tiempo real
  }

  void _listenToCurrentBalance() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId != null) {
      // Escuchar cambios en el saldo del usuario
      FirebaseFirestore.instance
          .collection('saldos')
          .doc(userId)
          .snapshots()
          .listen((documentSnapshot) {
        if (documentSnapshot.exists) {
          setState(() {
            _currentBalance =
                (documentSnapshot.data() as Map<String, dynamic>)['saldos'] ??
                    0.0;
          });
        }
      }, onError: (e) {
        print('Error al obtener saldo: $e'); // Manejar errores
      });
    }
  }

  Future<void> _fetchRecipients() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('clientes').get();
    setState(() {
      _recipients =
          querySnapshot.docs.map((doc) => doc['usuario'] as String).toList();
      _filteredRecipients = [];
    });
  }

  void _filterRecipients() {
    String query = _recipientController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredRecipients = [];
      });
      return;
    }

    setState(() {
      _filteredRecipients = _recipients
          .where((recipient) => recipient.toLowerCase().contains(query))
          .toList();
    });
  }

  void _setError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  Future<void> _sendMoney() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String recipient = _recipientController.text.trim();
    String amountText = _amountController.text.trim();

    if (recipient.isEmpty)
      return _setError('Por favor ingresa el destinatario.');
    if (amountText.isEmpty) return _setError('Por favor ingresa un monto.');

    double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0)
      return _setError('Ingresa un monto válido.');

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('saldos')
            .doc(userId)
            .get();

        if (!userDoc.exists) return _setError('Usuario no encontrado.');

        double currentBalance =
            (userDoc.data() as Map<String, dynamic>)['saldos'] ?? 0.0;

        if (currentBalance < amount) {
          return _setError(
              'Saldo insuficiente. Tu saldo: \$${currentBalance}, Monto a enviar: \$${amount}');
        }

        // Actualizar el saldo del remitente
        await FirebaseFirestore.instance
            .collection('saldos')
            .doc(userId)
            .update({'saldos': currentBalance - amount});

        // Actualizar el saldo del destinatario
        DocumentSnapshot recipientDoc = await FirebaseFirestore.instance
            .collection('saldos')
            .doc(recipient)
            .get();

        if (recipientDoc.exists) {
          double recipientCurrentBalance =
              (recipientDoc.data() as Map<String, dynamic>)['saldos'] ?? 0.0;

          await FirebaseFirestore.instance
              .collection('saldos')
              .doc(recipient)
              .update({'saldos': recipientCurrentBalance + amount});
        } else {
          return _setError('Destinatario no encontrado.');
        }

        // Registrar la transacción
        await FirebaseFirestore.instance.collection('transacciones').add({
          'destinatario': recipient,
          'monto': amount,
          'fecha': FieldValue.serverTimestamp(),
          'usuario_id': userId,
        });

        // Actualizar el saldo en la interfaz de usuario
        setState(() {
          _currentBalance -= amount; // Actualizar el saldo en la interfaz
          _isLoading = false;
          _recipientController.clear();
          _amountController.clear();
          _errorMessage = 'Dinero enviado exitosamente a $recipient.';
        });
      } catch (e) {
        _setError('Error al enviar dinero: $e');
      }
    } else {
      _setError('Error al obtener el ID del usuario.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Dinero'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Saldo actual: \$${_currentBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Enviar Dinero',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _recipientController,
                decoration: InputDecoration(
                  labelText: 'Destinatario',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              if (_filteredRecipients.isNotEmpty) ...[
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredRecipients.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_filteredRecipients[index]),
                        onTap: () {
                          _recipientController.text =
                              _filteredRecipients[index];
                          _filteredRecipients = [];
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 10),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Monto',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? Lottie.asset('assets/images/envio.json',
                      width: 150, height: 150)
                  : ElevatedButton(
                      onPressed: _isLoading ? null : _sendMoney,
                      child: const Text('Enviar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
