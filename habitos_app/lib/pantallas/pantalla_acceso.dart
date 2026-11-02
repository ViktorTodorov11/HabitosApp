
import 'package:flutter/material.dart';
import '../servicios/shared_preferences.dart';
import '../modelos/usuario.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';
import 'pantalla_registro.dart';
import 'pantalla_habitos.dart';
import 'pantalla_administracion.dart';

// Pantalla de inicio de sesión para los usuarios y el administrador
class PantallaAcceso extends StatefulWidget {
  const PantallaAcceso({super.key});

  @override
  State<PantallaAcceso> createState() => _PantallaAccesoState();
}

class _PantallaAccesoState extends State<PantallaAcceso> {

  // Controladores para leer el texto de los campos de entrada
  final TextEditingController _usuarioCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  final shared_preferences _servicio = shared_preferences();

  // Variables para almacenar y mostrar mensajes de error
  String _error = '';
  bool _cargando = false;

  // Método para validar las credenciales e iniciar sesión
  Future<void> _iniciarSesion() async {
    final usuario = _usuarioCtrl.text.trim();
    final pass = _passwordCtrl.text.trim();

    // Validación de campos vacíos
    if (usuario.isEmpty || pass.isEmpty) {
      setState(() {
        _error = 'Por favor, rellena todos los campos';
      });
      return;
    }

    setState(() {
      _cargando = true;
      _error = '';
    });

    final Usuario? cuenta =
    await _servicio.comprobarAcceso(usuario, pass);

    if (!mounted) return;

    setState(() {
      _cargando = false;
    });

    // Comprobamos si el usuario existe
    if (cuenta == null) {
      setState(() {
        _error = 'Usuario o contraseña incorrectos';
      });
      return;
    }

    // Comprobación de acceso de administrador o usuario
    if (cuenta.esAdministrador) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PantallaAdministracion(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PantallaHabitos(
            nombreUsuario: cuenta.nombre,
            usuarioId: cuenta.id,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _registrarApertura();
  }

  // Registra cada apertura de la aplicación
  Future<void> _registrarApertura() async {
    await _servicio.registrarApertura();
  }

  // Liberamos los controladores al cerrar la pantalla
  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
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
            const Icon(
              Icons.lock_outline,
              size: 80,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 20),

            // Campo de usuario o email
            CampoTextoApp(
              etiqueta: 'Usuario o Email',
              controlador: _usuarioCtrl,
              icono: Icons.person,
            ),

            // Campo de contraseña
            CampoTextoApp(
              etiqueta: 'Contraseña',
              controlador: _passwordCtrl,
              ocultarTexto: true,
              icono: Icons.lock,
            ),

            if (_error.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _error,
                style: const TextStyle(color: Colors.red),
              ),
            ],

            const SizedBox(height: 20),

            // Botón para iniciar sesión
            BotonPrincipal(
              texto: _cargando ? 'Comprobando...' : 'Iniciar Sesión',
              onPressed: _cargando ? () {} : _iniciarSesion,
            ),

            // Enlace para ir al registro
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegistroPage(),
                  ),
                );
              },
              child: const Text('¿No tienes cuenta? Regístrate aquí'),
            ),
          ],
        ),
      ),
    );
  }
}
