import 'package:flutter/material.dart';
// Modelos y servicios
import '../modelos/habito.dart';
import '../servicios/shared_preferences.dart';
import '../widgets/dialogo.dart';
// Pantallas
import 'pantalla_editar_habito.dart';

/// Pantalla alternativa para la gestión completa de hábitos (Crear, Editar, Borrar)
class PantallaGestionHabitos extends StatefulWidget {
  const PantallaGestionHabitos({super.key});

  @override
  State<PantallaGestionHabitos> createState() => _PantallaGestionHabitosState();
}

class _PantallaGestionHabitosState extends State<PantallaGestionHabitos> {
  final shared_preferences _servicio = shared_preferences();
  List<Habito> _habitos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  /// Lee la lista de hábitos guardados en almacenamiento local
  Future<void> _cargar() async {
    final habitos = await _servicio.getHabitos();
    if (!mounted) return;
    setState(() {
      _habitos = habitos;
      _cargando = false;
    });
  }

  /// Abre la pantalla de formulario (habito null = nuevo hábito, habito != null = editar)
  Future<void> _abrirFormulario(Habito? habito) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaEditarHabito(habito: habito),
      ),
    );
    await _cargar();
  }

  /// Borra un hábito tras confirmación previa
  Future<void> _borrar(Habito habito) async {
    final confirmado = await mostrarConfirmacion(
      context,
      'Borrar hábito',
      '¿Seguro que quieres borrar "${habito.nombre}"?',
    );

    if (confirmado) {
      _habitos.remove(habito);
      await _servicio.guardarHabitos(_habitos);
      await _cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Hábitos')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _abrirFormulario(null),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _habitos.isEmpty
          ? const Center(child: Text('No hay hábitos. Pulsa + para añadir.'))
          : ListView.builder(
        itemCount: _habitos.length,
        itemBuilder: (context, i) {
          final habito = _habitos[i];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(habito.color),
            ),
            title: Text(habito.nombre),
            subtitle: Text('Días completado: ${habito.fechasCompletadas.length}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _abrirFormulario(habito),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _borrar(habito),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}