import 'package:flutter/material.dart';
import '../servicios/shared_preferences.dart';
import '../widgets/dialogo.dart';

/// Pantalla de configuración y ajustes de la aplicación para el usuario
class PantallaAjustes extends StatefulWidget {
  final VoidCallback? onCambio;
  // id para que los ajustes solo afecten a la cuenta conectada.
  final String usuarioId;

  const PantallaAjustes({super.key, this.onCambio, this.usuarioId = ''});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  final shared_preferences _servicio = shared_preferences();
  int _aperturas = 0;

  @override
  void initState() {
    super.initState();
    _cargarAperturas();
  }

  /// Consulta el número de aperturas desde SharedPreferences
  Future<void> _cargarAperturas() async {
    final num = await _servicio.getNumeroAperturas();
    if (!mounted) return;
    setState(() => _aperturas = num);
  }

  /// Borra todos los hábitos guardados por el usuario
  Future<void> _limpiarHabitos() async {
    final confirmado = await mostrarConfirmacion(
      context,
      'Borrar todos los hábitos',
      '¿Deseas eliminar todos tus hábitos guardados? Esta acción no se puede deshacer.',
    );

    if (confirmado) {
      //borrar solo los hábitos del usuario actual.
      if (widget.usuarioId.isEmpty) {
        await _servicio.guardarHabitos([]);
      } else {
        await _servicio.guardarHabitosUsuario(widget.usuarioId, []);
      }
      if (widget.onCambio != null) widget.onCambio!();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los hábitos han sido eliminados')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes de la Aplicación')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Información de uso de la app
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.deepPurple),
            title: const Text('Veces que has abierto la app'),
            subtitle: Text('Total de aperturas: $_aperturas'),
          ),
          const Divider(),

          // Opción para resetear los hábitos locales
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.red),
            title: const Text('Borrar todos mis hábitos'),
            subtitle: const Text('Limpia la lista de hábitos guardados localmente'),
            onTap: _limpiarHabitos,
          ),
        ],
      ),
    );
  }
}