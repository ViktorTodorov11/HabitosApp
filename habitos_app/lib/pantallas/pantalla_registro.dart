import 'package:flutter/material.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';
import '../servicios/shared_preferences.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final shared_preferences _servicio = shared_preferences();
  String _mensaje = '';
  bool _cargando false;

  Future<void> _registrar() async {
    final nombre = _nombreCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (nombre.isEmpty || email.isEmpty || pass.isEmpty) {
      setState(() => _mensaje = 'Rellena todos los campos');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _mensaje = 'Escribe un correo electrónico válido');
      return;
    }
    if (pass.length < 4) {
      setState(() => _mensaje = 'La contraseña debe tener al menos 4 caracteres');
      return;
    }

    setState(() { _cargando = true; _mensaje = ''; });
    final correcto = await _servicio.registrarUsuario(
      nombre: nombre,
      email: email,
      password: pass,
    );
    if (!mounted) return;
    setState(() => _cargando = false);

    if (!correcto) {
      setState(() => _mensaje = 'Ya existe una cuenta con ese correo');
      return;
    }

    final fechaCreacion = DateTime.now().toString().split(' ')[0];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Usuario registrado el $fechaCreacion')),
    );
    Navigator.pop(context);
  }

  // 🟨 NUEVO ACT02: liberar los controladores.
  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
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
            BotonPrincipal(texto: _cargando ? 'Registrando...' : 'Registrarse', onPressed: _cargando ? () {} : _registrar),
          ],
        ),
      ),
    );
  }
}