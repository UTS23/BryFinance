import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      'pregunta': '¿Cómo cambiar mi contraseña?',
      'respuesta':
          'Para cambiar tu contraseña, ve a la sección de Ajustes y selecciona "Cambiar Contraseña".'
    },
    {
      'pregunta': '¿Cómo enviar dinero?',
      'respuesta':
          'Puedes enviar dinero desde la pantalla de "Enviar Dinero". Simplemente ingresa el destinatario y el monto.'
    },
    {
      'pregunta': '¿Qué hacer si olvidé mi contraseña?',
      'respuesta':
          'Si olvidaste tu contraseña, usa la opción "Olvidé mi contraseña" en la pantalla de inicio de sesión.'
    },
    {
      'pregunta': '¿Cómo contactar al soporte?',
      'respuesta':
          'Puedes contactar al soporte a través de la sección "Ayuda" y seleccionar "Contactar Soporte".'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: faqs.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ExpansionTile(
                title: Text(faqs[index]['pregunta']!),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(faqs[index]['respuesta']!),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
