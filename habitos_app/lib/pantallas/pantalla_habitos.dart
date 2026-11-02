import 'package:flutter/material.dart';
import '../modelos/habito.dart';
import '../servicios/shared_preferences.dart';
import '../widgets/tarjeta_habito.dart';
import '../widgets/dialogo.dart';
import 'pantalla_editar_habito.dart';
import 'pantalla_estadisticas.dart';
import 'pantalla_ajustes.dart';
import 'pantalla_acceso.dart';

/// Pantalla principal que muestra el listado de hábitos del usuario
class PantallaHabitos extends StatefulWidget {
  final String nombreUsuario;
  // id para separar los hábitos de cada cuenta.
  final String usuarioId;

  const PantallaHabitos({super.key, required this.nombreUsuario, this.usuarioId = ''});

  @override
  State<PantallaHabitos> createState() => _PantallaHabitosState();
}

class _PantallaHabitosState extends State<PantallaHabitos> {
  // Instancia del servicio de almacenamiento local
  final shared_preferences _servicio = shared_preferences();
  List<Habito> _habitos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarHabitos();
  }

  /// Carga la lista de hábitos desde SharedPreferences
  Future<void> _cargarHabitos() async {
    // se cargan solo los hábitos del usuario conectado.
    final habitos = widget.usuarioId.isEmpty ? await _servicio.getHabitos() : await _servicio.getHabitosUsuario(widget.usuarioId);
    if (!mounted) return;
    setState(() {
      _habitos = habitos;
      _cargando = false;
    });
  }

  /// Muestra un diálogo de confirmación y elimina un hábito
  Future<void> _eliminarHabito(Habito habito) async {
    final confirmado = await mostrarConfirmacion(
      context,
      'Eliminar Hábito',
      '¿Seguro que deseas eliminar "${habito.nombre}"?',
    );

    if (confirmado) {
      _habitos.remove(habito);
      // guarda sin modificar los hábitos de otras cuentas.
      if (widget.usuarioId.isEmpty) { await _servicio.guardarHabitos(_habitos); } else { await _servicio.guardarHabitosUsuario(widget.usuarioId, _habitos); }
      _cargarHabitos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hábitos de ${widget.nombreUsuario}'),
        actions: [
          // Botón para acceder a las estadísticas
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Estadísticas',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EstadisticasPage(usuarioId: widget.usuarioId)),
            ),
          ),
          // Botón para acceder a la configuración / ajustes
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Ajustes',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PantallaAjustes(
                    usuarioId: widget.usuarioId,
                    onCambio: () async {
                      await _cargarHabitos();
                    },
                  ),
                ),
              );
              _cargarHabitos();
            },
          ),
          // Botón para cerrar sesión y volver a la pantalla de acceso
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PantallaAcceso()),
            ),
          )
        ],
      ),
      // Botón flotante para crear un nuevo hábito
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PantallaEditarHabito(usuarioId: widget.usuarioId),
            ),
          );
          _cargarHabitos();
        },
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _habitos.isEmpty
          ? const Center(child: Text('Aún no tienes hábitos registrados.'))
          : ListView.builder(
        itemCount: _habitos.length,
        itemBuilder: (context, i) {
          final habito = _habitos[i];
          return TarjetaHabito(
            nombre: habito.nombre,
            color: habito.color,
            completadoHoy: habito.estaHechoHoy(),
            // Marcar o desmarcar hábito para el día de hoy
            onComplete: (val) async {
              final hoy = DateTime.now().toString().split(' ')[0];
              if (val == true) {
                if (!habito.fechasCompletadas.contains(hoy)) {
                  habito.fechasCompletadas.add(hoy);
                }
              } else {
                habito.fechasCompletadas.remove(hoy);
              }
              // guarda sin modificar los hábitos de otras cuentas.
      if (widget.usuarioId.isEmpty) { await _servicio.guardarHabitos(_habitos); } else { await _servicio.guardarHabitosUsuario(widget.usuarioId, _habitos); }
              setState(() {});
            },
            // Abrir formulario para editar el hábito
            onEdit: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PantallaEditarHabito(habito: habito, usuarioId: widget.usuarioId),
                ),
              );
              _cargarHabitos();
            },
            // Eliminar el hábito actual
            onDelete: () => _eliminarHabito(habito),
          );
        },
      ),
    );
  }
}