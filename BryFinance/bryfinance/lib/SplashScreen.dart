import 'package:bryfinance/login.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;

  static const Duration animationDuration = Duration(seconds: 2);
  static const Duration delayDuration = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: animationDuration,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    Future.delayed(delayDuration, () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50), // Margen superior
                  // Animación Lottie
                  Lottie.asset(
                    'assets/images/bank.json',
                    width: 150,
                    height: 150,
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 250.0,
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black38,
                            offset: Offset(5.0, 5.0),
                          ),
                        ],
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          WavyAnimatedText(
                            'BryFinance',
                            speed: const Duration(milliseconds: 200),
                          ),
                        ],
                        isRepeatingAnimation: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Bienvenido a BryFinance',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Gestión de Finanzas al Alcance de Tu Mano',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 30), // Espacio adicional
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Derechos Reservados © BRAYAN MORENO',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
