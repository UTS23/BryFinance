import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos y Condiciones de BryFinance'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Términos y Condiciones',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('1. Aceptación de Términos'),
              const Text(
                'Al utilizar los servicios de BryFinance, usted acepta cumplir con estos términos y condiciones. Si no está de acuerdo con estos términos, no deberá utilizar nuestros servicios.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('2. Uso del Servicio'),
              const Text(
                'Usted se compromete a utilizar BryFinance únicamente para fines legales y de acuerdo con todas las leyes y regulaciones aplicables. No podrá utilizar el servicio para actividades fraudulentas o ilegales.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('3. Registro de Cuenta'),
              const Text(
                'Para utilizar ciertos servicios, es posible que deba registrarse y crear una cuenta. Usted es responsable de mantener la confidencialidad de sus credenciales y de todas las actividades que ocurran en su cuenta.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('4. Protección de Datos'),
              const Text(
                'Su privacidad es importante para nosotros. Los datos que recopilamos se utilizarán de acuerdo con nuestra política de privacidad. Al utilizar nuestros servicios, usted consiente la recopilación y el uso de su información personal.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('5. Modificaciones a los Términos'),
              const Text(
                'BryFinance se reserva el derecho de modificar estos términos en cualquier momento. Cualquier cambio será efectivo inmediatamente después de su publicación. Le recomendamos revisar periódicamente esta página.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('6. Limitación de Responsabilidad'),
              const Text(
                'BryFinance no será responsable por daños indirectos, incidentales, especiales o consecuentes que resulten del uso o la imposibilidad de uso de nuestros servicios.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('7. Ley Aplicable'),
              const Text(
                'Estos términos se regirán e interpretarán de acuerdo con las leyes del país en el que se encuentre BryFinance, sin tener en cuenta los principios de conflicto de leyes.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('8. Contacto'),
              const Text(
                'Si tiene preguntas sobre estos términos, contáctenos a través de nuestro servicio de atención al cliente en [correo@bryfinance.com].',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
