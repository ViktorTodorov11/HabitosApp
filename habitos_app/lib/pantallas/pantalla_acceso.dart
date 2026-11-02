import 'package:flutter/material.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';
import 'pantalla_registro.dart';
import 'pantalla_habitos.dart';
import 'pantalla_administracion.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usuarioCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _error = '';

  void _iniciarSesion() {
    final usuario = _usuarioCtrl.text.trim();
    final pass = _passwordCtrl.text.trim();

    if (usuario.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Por favor, rellena todos los campos');
      return;
    }

    // Acceso de prueba Administrador vs Usuario Estándar
    if (usuario == 'admin' && pass == '1234') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdministracionPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HabitosPage(nombreUsuario: usuario),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio de Sesión'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 20),
            CampoTextoApp(
              etiqueta: 'Usuario o Email',
              controlador: _usuarioCtrl,
              icono: Icons.person,
            ),
            CampoTextoApp(
              etiqueta: 'Contraseña',
              controlador: _passwordCtrl,
              ocultarTexto: true,
              icono: Icons.lock,
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_error, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            BotonPrincipal(
              texto: 'Iniciar Sesión',
              onPressed: _iniciarSesion,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegistroPage()),
                );
              },
              child: const Text('¿No tienes cuenta? Regístrate aquí'),
            )
          ],
        ),
      ),
    );
  }
}