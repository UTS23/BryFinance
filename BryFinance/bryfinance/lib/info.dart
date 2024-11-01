import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProfileScreen extends StatefulWidget {
  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ocupacionController = TextEditingController();
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _infoAdicionalController =
      TextEditingController();
  final TextEditingController _nacionalidadController = TextEditingController();

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    if (userId != null) {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('clientes')
          .where('usuario', isEqualTo: userId)
          .get();

      if (result.docs.isNotEmpty) {
        var data = result.docs.first.data() as Map<String, dynamic>;
        setState(() {
          _nombreController.text = data['nombre'] ?? '';
          _apellidosController.text = data['apellidos'] ?? '';
          _edadController.text = (data['edad'] ?? 0).toString();
          _emailController.text = data['email'] ?? '';
          _ocupacionController.text = data['ocupacion'] ?? '';
          _usuarioController.text = data['usuario'] ?? '';
          _cedulaController.text = data['cedula'] ?? '';
          _infoAdicionalController.text = data['infoAdicional'] ?? '';
          _nacionalidadController.text = data['nacionalidad'] ?? '';
        });
      } else {
        _showSnackBar(
            context, 'No se encontraron datos del usuario', Colors.red);
      }
    } else {
      _showSnackBar(context,
          'No se encontró el ID de usuario en el dispositivo', Colors.orange);
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isUpdating = true;
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      if (userId != null) {
        final QuerySnapshot result = await FirebaseFirestore.instance
            .collection('clientes')
            .where('usuario', isEqualTo: userId)
            .get();

        if (result.docs.isNotEmpty) {
          DocumentReference docRef = result.docs.first.reference;
          await docRef.update({
            'nombre': _nombreController.text.trim(),
            'apellidos': _apellidosController.text.trim(),
            'edad': int.tryParse(_edadController.text.trim()) ?? 0,
            'email': _emailController.text.trim(),
            'ocupacion': _ocupacionController.text.trim(),
            'cedula': _cedulaController.text.trim(),
            'infoAdicional': _infoAdicionalController.text.trim(),
            'nacionalidad': _nacionalidadController.text.trim(),
          });

          _showSnackBar(
              context, 'Perfil actualizado exitosamente', Colors.green);
        } else {
          _showSnackBar(
              context, 'No se encontraron datos del usuario', Colors.red);
        }
      } else {
        _showSnackBar(context,
            'No se encontró el ID de usuario en el dispositivo', Colors.orange);
      }

      setState(() {
        _isUpdating = false;
      });
    } else {
      _showSnackBar(context,
          'Por favor, completa todos los campos obligatorios', Colors.red);
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _edadController.dispose();
    _emailController.dispose();
    _ocupacionController.dispose();
    _usuarioController.dispose();
    _cedulaController.dispose();
    _infoAdicionalController.dispose();
    _nacionalidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualizar Perfil'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Perfil de Usuario',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildUserInfoCard(),
              const SizedBox(height: 30),
              _buildAdditionalInfoCard(),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isUpdating ? null : _updateUserData,
                  icon: _isUpdating
                      ? CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        )
                      : Icon(Icons.update),
                  label: Text(
                    _isUpdating ? 'Actualizando...' : 'Actualizar Perfil',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEditableTextField(_nombreController, 'Nombre', Icons.person),
            const SizedBox(height: 10),
            _buildEditableTextField(
                _apellidosController, 'Apellidos', Icons.person_outline),
            const SizedBox(height: 10),
            _buildEditableTextField(
                _edadController, 'Edad', Icons.calendar_today,
                keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            _buildEditableTextField(_emailController, 'Email', Icons.email),
            const SizedBox(height: 10),
            _buildEditableTextField(
                _ocupacionController, 'Ocupación', Icons.work),
            const SizedBox(height: 10),
            _buildEditableTextField(
                _usuarioController, 'Usuario', Icons.account_circle,
                readOnly: true),
            const SizedBox(height: 10),
            _buildEditableTextField(
                _cedulaController, 'Cédula', Icons.confirmation_number,
                keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            _buildEditableTextField(
                _nacionalidadController, 'Nacionalidad', Icons.flag),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Adicional',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade800,
              ),
            ),
            const SizedBox(height: 10),
            _buildEditableTextField(
                _infoAdicionalController, 'Información Adicional', Icons.info),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurple, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo no puede estar vacío';
        }
        return null;
      },
    );
  }
}
