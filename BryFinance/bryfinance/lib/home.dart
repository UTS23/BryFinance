import 'dart:async'; // Importar la biblioteca de temporizador
import 'package:bryfinance/by.dart';
import 'package:bryfinance/confi.dart';
import 'package:bryfinance/perfil.dart';
import 'package:bryfinance/retirar.dart';
import 'package:bryfinance/transaciones.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'recharge.dart'; // Importar la pantalla de recarga
import 'send.dart'; // Importar la pantalla de enviar
import 'pay.dart'; // Importar la pantalla de pagar

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _currentIndex = 0; // Variable para manejar la pestaña actual
  Timer? _timer; // Variable para el temporizador
  double _saldo = 0.0; // Variable para almacenar el saldo
  String _userId = ""; // Variable para almacenar el ID de usuario
  bool _isSaldoVisible = true; // Controla la visibilidad del saldo

  @override
  void initState() {
    super.initState();
    _fetchUserBalance(); // Inicializar el saldo al cargar la pantalla
    // Iniciar el temporizador
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _fetchUserBalance(); // Actualizar el saldo cada 10 segundos
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancelar el temporizador al destruir el widget
    super.dispose();
  }

  Future<void> _fetchUserBalance() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id') ?? ""; // Obtener el ID de usuario

    try {
      DocumentSnapshot documentSnapshot = await _getUserBalance();
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _saldo = data['saldos'] ?? 0.0; // Obtener y actualizar el saldo
        });
      }
    } catch (e) {
      print('Error al obtener saldo: $e'); // Manejar errores
    }
  }

  Future<DocumentSnapshot> _getUserBalance() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId != null) {
      // Consulta el saldo del usuario en Firestore
      return await _firestore.collection('saldos').doc(userId).get();
    } else {
      throw Exception("Usuario no encontrado");
    }
  }

  void _logout() async {
    // Eliminar el ID de usuario de SharedPreferences al cerrar sesión
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');

    // Navegar de vuelta a la pantalla de inicio de sesión
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ByeAnimationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BryFinance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle), // Ícono de perfil
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ProfileScreen()), // Pantalla de perfil
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout, // Manejar el cierre de sesión
          ),
        ],
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade400,
              Colors.deepPurple.shade200,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¡Bienvenido a BryFinance!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  'Usuario: $_userId', // Mostrar el ID de usuario
                  key: ValueKey<String>(_userId),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Aquí puedes gestionar tus finanzas de manera fácil y segura.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Saldo Actual',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _isSaldoVisible
                            ? Text(
                                '\$${_saldo.toStringAsFixed(2)}', // Mostrar saldo
                                key: ValueKey<double>(_saldo),
                                style: const TextStyle(
                                  fontSize: 36,
                                  color: Colors.greenAccent,
                                ),
                              )
                            : const Text(
                                '****', // Ocultar saldo
                                style: TextStyle(
                                  fontSize: 36,
                                  color: Colors.redAccent,
                                ),
                              ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isSaldoVisible =
                                !_isSaldoVisible; // Alternar visibilidad
                          });
                        },
                        child: Text(
                          _isSaldoVisible ? 'Ocultar Saldo' : 'Mostrar Saldo',
                          style: TextStyle(color: Colors.deepPurple),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Últimos Movimientos:',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('1. Depósito - \$0.00'),
                      const Text('2. Retiro - \$0.00'),
                      const Text('3. Transferencia - \$0.00'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionCard(context, Icons.add, 'Recargar', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RechargeScreen()),
                    );
                  }),
                  _buildActionCard(context, Icons.send, 'Enviar', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SendScreen()),
                    );
                  }),
                  _buildActionCard(context, Icons.money_off, 'Retirar', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WithdrawScreen()),
                    );
                  }),
                  _buildActionCard(context, Icons.payment, 'Pagar', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PayScreen()),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Text(
                'Navegación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Recargar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RechargeScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.send),
              title: Text('Enviar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SendScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.money_off),
              title: Text('Retirar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WithdrawScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('Pagar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PayScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Transacciones'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TransactionsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Cerrar Sesión'),
              onTap: _logout, // Manejar el cierre de sesión
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
      BuildContext context, IconData icon, String title, Function() onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: SizedBox(
          width: 80,
          height: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.deepPurple),
              const SizedBox(height: 5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
