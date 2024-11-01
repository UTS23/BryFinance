import 'package:bryfinance/detalles.dart'; // Asegúrate de que la ruta sea correcta
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transacciones'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _getUserTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay transacciones recientes.'));
          }

          // Lista de transacciones
          final transactions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              var transaction =
                  transactions[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 15.0),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  title: Text(transaction['descripcion'] ?? 'Sin descripción'),
                  subtitle: Text(_formatDate(transaction['fecha'])),
                  trailing: Text(
                    '\$${transaction['monto']?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(color: Colors.greenAccent),
                  ),
                  onTap: () {
                    // Navegar a la pantalla de detalles
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailsScreen(transaction: transaction),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<QuerySnapshot> _getUserTransactions() async {
    // Obtener el ID del usuario desde SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId != null) {
      // Consulta las transacciones del usuario en Firestore
      return await _firestore
          .collection('transacciones')
          .where('usuario_id',
              isEqualTo: userId) // Asegúrate de que la clave sea correcta
          .get();
    } else {
      throw Exception("Usuario no encontrado");
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Fecha desconocida';
    }
    DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'; // Formato de fecha personalizado
  }
}
