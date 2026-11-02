import 'package:flutter/material.dart';
import '../modelos/habito.dart';
import '../servicios/shared_preferences.dart';
import '../widgets/dialogo.dart';
import 'pantalla_editar_habito.dart';

// Pantalla para crear, editar y borrar hábitos.
class PantallaGestionHabitos extends StatefulWidget {
  const PantallaGestionHabitos({super.key});

  @override
  State<PantallaGestionHabitos> createState() => _PantallaGestionHabitosState();
}

class _PantallaGestionHabitosState extends State<PantallaGestionHabitos> {
  final shared_preferences _servicio = shared_preferences();
  List<Habito> _habitos = []; // hábitos leídos de SharedPreferences
  bool _cargando = true; // true mientras se leen los datos

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  // Lee la lista de hábitos guardada
  Future<void> _cargar() async {
    final habitos = await _servicio.getHabitos();
    if (!mounted) return;
    setState(() {
      _habitos = habitos;
      _cargando = false;
    });
  }

  // Abre el formulario (habito null = crear nuevo) y recarga al volver
  Future<void> _abrirFormulario(Habito? habito) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaEditarHabito(habito: habito),
      ),
    );
    // Al volver, releemos la lista para ver los cambios
    await _cargar();
  }

  // Borra un hábito después de pedir confirmación
  Future<void> _borrar(Habito habito) async {
    // Diálogo de confirmación (devuelve true si el usuario acepta)
    final confirmado = await mostrarConfirmacion(
      context,
      'Borrar hábito',
      '¿Seguro que quieres borrar "${habito.nombre}"?',
    );
    if (!confirmado) return; // el usuario canceló
    _habitos.remove(habito); // lo quitamos de la lista
    // Guardamos la lista ya sin ese hábito
    await _servicio.guardarHabitos(_habitos);
    setState(() {}); // redibujamos
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de hábitos'),
        centerTitle: true,
      ),
      // Botón flotante "+" para crear un hábito nuevo
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(null),
        child: const Icon(Icons.add),
      ),
      // Según el estado mostramos: carga, lista vacía o la lista
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _habitos.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.playlist_add,
                size: 64, color: Colors.grey.shade500),
            const SizedBox(height: 8),
            const Text('Todavía no hay hábitos'),
          ],
        ),
      )
          : ListView.builder(
        // Espacio abajo para que el botón flotante no tape el último
        padding: const EdgeInsets.only(top: 8, bottom: 88),
        itemCount: _habitos.length,
        itemBuilder: (context, i) {
          final habito = _habitos[i];
          // Cada hábito va dentro de una tarjeta
          return Card(
            margin:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              // Círculo con el color del hábito
              leading: CircleAvatar(
                backgroundColor: Color(habito.color),
                radius: 16,
              ),
              title: Text(
                habito.nombre,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              // Botones de editar y borrar a la derecha
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _abrirFormulario(habito),
                  ),
                  // El de borrar en rojo para que se distinga
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () => _borrar(habito),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}