import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSectionTitle('Clientes'),
            _buildCollectionList('clientes', context),
            _buildSectionTitle('Saldos'),
            _buildCollectionList('saldos', context),
            _buildSectionTitle('Transacciones'),
            _buildCollectionList('transacciones', context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddClientDialog(context);
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple),
      ),
    );
  }

  Widget _buildCollectionList(String collectionName, BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection(collectionName).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('No hay datos en $collectionName'),
          );
        }

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            return _buildDocumentCard(doc, collectionName, context);
          },
        );
      },
    );
  }

  Widget _buildDocumentCard(
      QueryDocumentSnapshot doc, String collectionName, BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 5,
      shadowColor: Colors.grey.withOpacity(0.3),
      child: ListTile(
        title:
            Text(doc.id, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(doc.data().toString(),
            style: const TextStyle(color: Colors.black54)),
        onTap: () {
          if (collectionName == 'clientes') {
            _showEditClientDialog(
                context, doc.id, doc.data() as Map<String, dynamic>);
          } else if (collectionName == 'saldos') {
            _showBalanceDialog(context, doc.id);
          }
        },
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () =>
              _confirmDeleteDocument(context, collectionName, doc.id),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteDocument(
      BuildContext context, String collectionName, String docId) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content:
            const Text('¿Estás seguro de que deseas eliminar este documento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _deleteDocument(collectionName, docId);
    }
  }

  Future<void> _deleteDocument(String collectionName, String docId) async {
    try {
      await _firestore.collection(collectionName).doc(docId).delete();
      print('Documento eliminado: $docId de la colección $collectionName');
    } catch (e) {
      print('Error al eliminar documento: $e');
    }
  }

  void _showBalanceDialog(BuildContext context, String docId) {
    final TextEditingController amountController = TextEditingController();
    String operation = 'increment'; // 'increment' o 'decrement'

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modificar Saldo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  hintText: 'Ingrese la cantidad a agregar o restar',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      operation = 'increment';
                      Navigator.of(context).pop();
                      _modifyBalance(docId, operation,
                          double.tryParse(amountController.text) ?? 0);
                    },
                    child: const Text('Agregar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      operation = 'decrement';
                      Navigator.of(context).pop();
                      _modifyBalance(docId, operation,
                          double.tryParse(amountController.text) ?? 0);
                    },
                    child: const Text('Restar'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _modifyBalance(
      String docId, String operation, double amount) async {
    if (amount <= 0) {
      print('La cantidad debe ser mayor que cero.');
      return; // No modificar el saldo si la cantidad es cero o negativa
    }

    try {
      final adjustment = operation == 'increment' ? amount : -amount;
      await _firestore.collection('saldos').doc(docId).update({
        'saldos': FieldValue.increment(adjustment),
      });
      print(
          'Saldo modificado: $operation \$${amount.toString()} para el cliente $docId');
    } catch (e) {
      print('Error al modificar saldo: $e');
    }
  }

  void _showAddClientDialog(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController idController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController occupationController = TextEditingController();
    final TextEditingController incomeController = TextEditingController();
    final TextEditingController ageController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Nuevo Cliente'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(usernameController, 'Nombre de Usuario',
                    'Ingrese el nombre de usuario', Icons.person),
                _buildTextField(nameController, 'Nombre',
                    'Ingrese el nombre del cliente', Icons.person),
                _buildTextField(lastNameController, 'Apellidos',
                    'Ingrese los apellidos del cliente', Icons.person),
                _buildTextField(idController, 'Cédula',
                    'Ingrese la cédula del cliente', Icons.credit_card),
                _buildTextField(emailController, 'Correo Electrónico',
                    'Ingrese el correo del cliente', Icons.email),
                _buildTextField(occupationController, 'Ocupación',
                    'Ingrese la ocupación del cliente', Icons.work),
                _buildTextField(
                    incomeController,
                    'Ingresos Mensuales',
                    'Ingrese los ingresos mensuales',
                    Icons.monetization_on,
                    TextInputType.number),
                _buildTextField(
                    ageController,
                    'Edad',
                    'Ingrese la edad del cliente',
                    Icons.calendar_today,
                    TextInputType.number),
                _buildTextField(
                    passwordController,
                    'Contraseña',
                    'Ingrese la contraseña',
                    Icons.lock,
                    TextInputType.visiblePassword),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _addClient(
                  usernameController.text,
                  nameController.text,
                  lastNameController.text,
                  idController.text,
                  emailController.text,
                  occupationController.text,
                  double.tryParse(incomeController.text) ?? 0,
                  int.tryParse(ageController.text) ?? 0,
                  passwordController.text, // Agregar contraseña
                );
                Navigator.of(context).pop();
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _showEditClientDialog(
      BuildContext context, String docId, Map<String, dynamic> clientData) {
    final TextEditingController usernameController =
        TextEditingController(text: clientData['username']);
    final TextEditingController nameController =
        TextEditingController(text: clientData['nombre']);
    final TextEditingController lastNameController =
        TextEditingController(text: clientData['apellidos']);
    final TextEditingController idController =
        TextEditingController(text: clientData['cedula']);
    final TextEditingController emailController =
        TextEditingController(text: clientData['correo']);
    final TextEditingController occupationController =
        TextEditingController(text: clientData['ocupacion']);
    final TextEditingController incomeController = TextEditingController(
        text: clientData['ingresos_mensuales'].toString());
    final TextEditingController ageController =
        TextEditingController(text: clientData['edad'].toString());
    // Nota: la contraseña no se edita por razones de seguridad

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Cliente'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(usernameController, 'Nombre de Usuario',
                    'Ingrese el nombre de usuario', Icons.person),
                _buildTextField(nameController, 'Nombre',
                    'Ingrese el nombre del cliente', Icons.person),
                _buildTextField(lastNameController, 'Apellidos',
                    'Ingrese los apellidos del cliente', Icons.person),
                _buildTextField(idController, 'Cédula',
                    'Ingrese la cédula del cliente', Icons.credit_card),
                _buildTextField(emailController, 'Correo Electrónico',
                    'Ingrese el correo del cliente', Icons.email),
                _buildTextField(occupationController, 'Ocupación',
                    'Ingrese la ocupación del cliente', Icons.work),
                _buildTextField(
                    incomeController,
                    'Ingresos Mensuales',
                    'Ingrese los ingresos mensuales',
                    Icons.monetization_on,
                    TextInputType.number),
                _buildTextField(
                    ageController,
                    'Edad',
                    'Ingrese la edad del cliente',
                    Icons.calendar_today,
                    TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _editClient(
                  docId,
                  usernameController.text,
                  nameController.text,
                  lastNameController.text,
                  idController.text,
                  emailController.text,
                  occupationController.text,
                  double.tryParse(incomeController.text) ?? 0,
                  int.tryParse(ageController.text) ?? 0,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editClient(
      String docId,
      String username,
      String name,
      String lastName,
      String id,
      String email,
      String occupation,
      double income,
      int age) async {
    try {
      await _firestore.collection('clientes').doc(docId).update({
        'username': username,
        'nombre': name,
        'apellidos': lastName,
        'cedula': id,
        'correo': email,
        'ocupacion': occupation,
        'ingresos_mensuales': income,
        'edad': age,
        // La contraseña no se actualiza
      });
      print(
          'Cliente actualizado: $username $name $lastName con cédula $id y correo $email');
    } catch (e) {
      print('Error al actualizar cliente: $e');
    }
  }

  Widget _buildTextField(TextEditingController controller, String label,
      String hint, IconData icon,
      [TextInputType keyboardType = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        obscureText:
            label == 'Contraseña', // Ocultar texto para el campo de contraseña
      ),
    );
  }

  Future<void> _addClient(
      String username,
      String name,
      String lastName,
      String id,
      String email,
      String occupation,
      double income,
      int age,
      String password) async {
    try {
      await _firestore.collection('clientes').add({
        'username': username,
        'nombre': name,
        'apellidos': lastName,
        'cedula': id,
        'correo': email,
        'ocupacion': occupation,
        'ingresos_mensuales': income,
        'edad': age,
        'contraseña': password, // Almacenar contraseña
      });
      print(
          'Cliente agregado: $username $name $lastName con cédula $id y correo $email');
    } catch (e) {
      print('Error al agregar cliente: $e');
    }
  }
}
