import 'package:flutter/material.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _mensaje = '';

  void _registrar() {
    if (_nombreCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _mensaje = 'Rellena todos los campos');
      return;
    }

    final fechaCreacion = DateTime.now().toString().split(' ')[0];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Usuario registrado el $fechaCreacion')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Usuario')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CampoTextoApp(etiqueta: 'Nombre completo', controlador: _nombreCtrl, icono: Icons.person),
            CampoTextoApp(etiqueta: 'Correo electrónico', controlador: _emailCtrl, icono: Icons.email),
            CampoTextoApp(etiqueta: 'Contraseña', controlador: _passCtrl, ocultarTexto: true, icono: Icons.lock),
            if (_mensaje.isNotEmpty) Text(_mensaje, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            BotonPrincipal(texto: 'Registrarse', onPressed: _registrar),
          ],
        ),
      ),
    );
  }
}