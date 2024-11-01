import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _userId = "";
  Map<String, dynamic>? _userData; // Para almacenar la información del usuario
  String? _errorMessage; // Mensaje de error

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Cargar datos del usuario al iniciar
  }

  Future<void> _fetchUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id') ?? ""; // Obtener el ID de usuario

    if (_userId.isNotEmpty) {
      try {
        // Recuperar información del usuario de la colección 'clientes'
        DocumentSnapshot userSnapshot =
            await _firestore.collection('clientes').doc(_userId).get();

        if (userSnapshot.exists) {
          // Inicializar el mapa para almacenar la información del usuario
          _userData = userSnapshot.data() as Map<String, dynamic>;

          // Recuperar el saldo del usuario
          DocumentSnapshot balanceSnapshot =
              await _firestore.collection('saldos').doc(_userId).get();

          // Verificar si el documento de saldo existe
          if (balanceSnapshot.exists) {
            // Agregar saldo a la información del usuario
            _userData?['saldo'] =
                (balanceSnapshot.data() as Map<String, dynamic>)['saldos'] ??
                    0.0;
          } else {
            _userData?['saldo'] = 0.0; // Si no hay saldo, establecer a 0.0
          }

          setState(() {}); // Actualizar el estado
        } else {
          setState(() {
            _errorMessage = "No se encontraron datos del usuario.";
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = "Error al cargar los datos: $e";
        });
      }
    } else {
      setState(() {
        _errorMessage = "No se ha encontrado el ID de usuario.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _errorMessage != null
          ? Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 20, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            )
          : _userData == null
              ? const Center(
                  child: CircularProgressIndicator(), // Indicador de carga
                )
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView(
                    children: [
                      _buildProfileTile(Icons.person, 'Nombre',
                          '${_userData!['nombre']} ${_userData!['apellidos']}'),
                      _buildProfileTile(
                          Icons.cake, 'Edad', '${_userData!['edad']}'),
                      _buildProfileTile(
                          Icons.email, 'Email', '${_userData!['email']}'),
                      _buildProfileTile(Icons.work, 'Ocupación',
                          '${_userData!['ocupacion']}'),
                      _buildProfileTile(Icons.person_outline, 'Usuario',
                          '${_userData!['usuario']}'),
                      _buildProfileTile(Icons.flag, 'Nacionalidad',
                          '${_userData!['nacionalidad']}'),
                      _buildProfileTile(Icons.credit_card, 'Cédula',
                          '${_userData!['cedula']}'),
                      _buildProfileTile(Icons.account_balance_wallet, 'Saldo',
                          '\$${_userData!['saldo'].toStringAsFixed(2)}'),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 5,
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
