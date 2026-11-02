import 'package:flutter/material.dart';
import '../servicios/shared_preferences.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';
import 'pantalla_registro.dart';
import 'pantalla_habitos.dart';
import 'pantalla_administracion.dart';

/// Pantalla de inicio de sesión para los usuarios y el administrador
class PantallaAcceso extends StatefulWidget {
  const PantallaAcceso({super.key});

  @override
  State<PantallaAcceso> createState() => _PantallaAccesoState();
}

class _PantallaAccesoState extends State<PantallaAcceso> {
  // Controladores para leer el texto de los campos de entrada
  final TextEditingController _usuarioCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  // Variable para almacenar y mostrar mensajes de error
  String _error = '';

  /// Método para validar las credenciales e iniciar sesión
  void _iniciarSesion() {
    final usuario = _usuarioCtrl.text.trim();
    final pass = _passwordCtrl.text.trim();

    // Validación de campos vacíos
    if (usuario.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Por favor, rellena todos los campos');
      return;
    }

    // Comprobación de acceso Administrador vs Usuario Estándar
    if (usuario == 'admin' && pass == '1234') {
      // Redirige al panel de administración
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PantallaAdministracion()),
      );
    } else {
      // Redirige a la pantalla principal de hábitos del usuario
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PantallaHabitos(nombreUsuario: usuario),
        ),
      );
    }
  }
  @override
  void initState() {
    super.initState();
    _registrarApertura();
  }

  Future<void> _registrarApertura() async {
    final servicio = shared_preferences();
    await servicio.getNumeroAperturas();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de Sesión'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 20),

            // Campo de entrada de usuario o email
            CampoTextoApp(
              etiqueta: 'Usuario o Email',
              controlador: _usuarioCtrl,
              icono: Icons.person,
            ),

            // Campo de entrada de contraseña
            CampoTextoApp(
              etiqueta: 'Contraseña',
              controlador: _passwordCtrl,
              ocultarTexto: true,
              icono: Icons.lock,
            ),

            // Muestra mensaje de error si existe
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_error, style: const TextStyle(color: Colors.red)),
            ],

            const SizedBox(height: 20),

            // Botón principal de login
            BotonPrincipal(
              texto: 'Iniciar Sesión',
              onPressed: _iniciarSesion,
            ),

            // Enlace para ir a la pantalla de registro
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