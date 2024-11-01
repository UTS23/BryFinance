import 'package:bryfinance/by.dart';
import 'package:bryfinance/cambio.dart';
import 'package:bryfinance/info.dart';
import 'package:bryfinance/login.dart';
import 'package:bryfinance/ayuda.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajustes',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 8.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Tarjeta de Configuración
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 4,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        context,
                        title: 'Cambiar Contraseña',
                        icon: Icons.lock_outline,
                        onTap: () =>
                            _navigateToScreen(context, ChangePasswordScreen()),
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        context,
                        title: 'Actualizar Perfil',
                        icon: Icons.person_outline,
                        onTap: () =>
                            _navigateToScreen(context, UpdateProfileScreen()),
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        context,
                        title: 'Notificaciones',
                        icon: Icons.notifications_none,
                        onTap: () => _showSnackbar(
                            context, 'Funcionalidad de notificaciones'),
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        context,
                        title: 'Ayuda',
                        icon: Icons.help_outline,
                        onTap: () => _navigateToScreen(context, HelpScreen()),
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        context,
                        title: 'Cerrar Sesión',
                        icon: Icons.logout,
                        color: Colors.redAccent,
                        onTap: () => _showLogoutDialog(context),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // Footer animado con nombre y año
              FadeTransition(
                opacity: AlwaysStoppedAnimation(1.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'BryFinance © Brayan Moreno, 2024',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Elemento de configuración con efecto visual
  Widget _buildSettingsTile(BuildContext context,
      {required String title,
      required IconData icon,
      required void Function()? onTap,
      Color color = Colors.deepPurple}) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.deepPurple.shade900,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios,
          color: Colors.deepPurple.shade300, size: 16),
      onTap: onTap,
      tileColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
    );
  }

  // Transición y animación para navegación
  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  // Confirmación de cierre de sesión
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Cerrar Sesión', style: TextStyle(color: Colors.deepPurple)),
            ],
          ),
          content: Text(
            '¿Estás seguro de que quieres cerrar sesión?',
            style: TextStyle(color: Colors.grey[700]),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Cerrar Sesión'),
              onPressed: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.remove('user_id');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ByeAnimationScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Divisor estilizado
  Divider _buildDivider() {
    return Divider(
      thickness: 0.8,
      color: Colors.grey.shade300,
      height: 10,
    );
  }

  // Snackbar con ícono y estilo moderno
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: Colors.deepPurple.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(15),
      ),
    );
  }
}
