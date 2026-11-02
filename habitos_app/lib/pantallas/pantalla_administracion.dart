import 'package:flutter/material.dart';
import '../modelos/habito.dart';
import '../servicios/shared_preferences.dart';
import '../widgets/dialogo.dart';
import 'pantalla_acceso.dart';

/// Panel de control para el usuario Administrador
class PantallaAdministracion extends StatefulWidget {
  const PantallaAdministracion({super.key});

  @override
  State<PantallaAdministracion> createState() => _PantallaAdministracionState();
}

class _PantallaAdministracionState extends State<PantallaAdministracion> {
  final shared_preferences _servicio = shared_preferences();
  List<Habito> _todosLosHabitos = [];
  int _totalAperturas = 0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosGlobales();
  }

  /// Carga datos globales de la app (hábitos de todos y contador de aperturas)
  Future<void> _cargarDatosGlobales() async {
    final habitos = await _servicio.getHabitos();
    final aperturas = await _servicio.getNumeroAperturas();
    if (!mounted) return;
    setState(() {
      _todosLosHabitos = habitos;
      _totalAperturas = aperturas;
      _cargando = false;
    });
  }

  /// Elimina cualquier hábito con privilegios de administrador
  Future<void> _eliminarCualquierHabito(Habito habito) async {
    final confirmado = await mostrarConfirmacion(
      context,
      'Eliminar como Admin',
      '¿Deseas forzar la eliminación del hábito "${habito.nombre}"?',
    );

    if (confirmado) {
      _todosLosHabitos.remove(habito);
      await _servicio.guardarHabitos(_todosLosHabitos);
      _cargarDatosGlobales();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hábito "${habito.nombre}" eliminado por el Administrador')),
      );
    }
  }

  /// Restablece completamente los datos guardados en el dispositivo
  Future<void> _restablecerSistema() async {
    final confirmado = await mostrarConfirmacion(
      context,
      'Restablecer Sistema',
      '¿Seguro que deseas borrar absolutamente todos los datos guardados en la app?',
    );

    if (confirmado) {
      await _servicio.borrarTodo();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PantallaAcceso()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
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
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tarjeta de métricas globales del sistema
          Card(
            color: Colors.deepPurple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Métricas del Sistema',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Total de hábitos en el sistema: ${_todosLosHabitos.length}'),
                  Text('Aperturas totales de la aplicación: $_totalAperturas'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Gestión Global de Hábitos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Lista de todos los hábitos creados
          if (_todosLosHabitos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text('No hay hábitos registrados en el sistema.'),
            )
          else
            ..._todosLosHabitos.map(
                  (habito) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(habito.color),
                    child: const Icon(Icons.article, color: Colors.white),
                  ),
                  title: Text(habito.nombre),
                  subtitle: Text('Días completados: ${habito.fechasCompletadas.length}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: () => _eliminarCualquierHabito(habito),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 30),

          // Botón de restablecimiento general para el Administrador
          ElevatedButton.icon(
            onPressed: _restablecerSistema,
            icon: const Icon(Icons.warning, color: Colors.white),
            label: const Text('Restablecer todos los datos del sistema'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}