import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'login.dart'; // Asegúrate de importar tu pantalla de Login

class ByeAnimationScreen extends StatefulWidget {
  @override
  _ByeAnimationScreenState createState() => _ByeAnimationScreenState();
}

class _ByeAnimationScreenState extends State<ByeAnimationScreen> {
  @override
  void initState() {
    super.initState();
    // Redirigir a LoginScreen después de 4 segundos
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cargar la animación de despedida
              Lottie.asset('assets/images/bye.json', height: 200),
              const SizedBox(height: 30),
              const Text(
                '¡Gracias por usar BryFinance!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Esperamos verte de nuevo pronto.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 50),
              // Mensaje adicional o información de contacto
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Si necesitas ayuda, no dudes en contactarnos a través de nuestro soporte. ¡Hasta pronto!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white60,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
