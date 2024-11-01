import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailsScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const DetailsScreen({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Transacción'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem(
                  icon: Icons.description,
                  label: 'Descripción',
                  value: transaction['descripcion'] ?? 'Sin descripción',
                ),
                const SizedBox(height: 20),
                _buildDetailItem(
                  icon: Icons.attach_money,
                  label: 'Monto',
                  value:
                      '\$${transaction['monto']?.toStringAsFixed(2) ?? '0.00'}',
                ),
                const SizedBox(height: 20),
                _buildDetailItem(
                  icon: Icons.calendar_today,
                  label: 'Fecha',
                  value: _formatDate(transaction['fecha']),
                ),
                const SizedBox(height: 20),
                // Agregar aquí más detalles si es necesario
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      {required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.deepPurple, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Fecha desconocida';
    }
    DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
