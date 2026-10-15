import 'package:flutter/material.dart';
import '../modelos/habito.dart';
import '../servicios/shared_preferences.dart';
import '../widgets/selector_color.dart';

// Formulario para crear un hábito nuevo o editar uno existente.
class PantallaFormulario extends StatefulWidget {
  final Habito? habito; // null = crear nuevo, con valor = editar

  const PantallaFormulario({super.key, this.habito});

  @override
  State<PantallaFormulario> createState() => _PantallaFormularioState();
}

class _PantallaFormularioState extends State<PantallaFormulario> {
  final shared_preferences _servicio = shared_preferences();
  // Controlador del campo de texto del nombre
  final TextEditingController _nombreCtrl = TextEditingController();
  int _color = 0xFF2196F3; // azul por defecto
  String _error = ''; // mensaje de error de validación

  @override
  void initState() {
    super.initState();
    // Si estamos editando, rellenamos los campos con los datos del hábito
    if (widget.habito != null) {
      _nombreCtrl.text = widget.habito!.nombre;
      _color = widget.habito!.color;
    }
  }

  // Guarda el hábito (nuevo o editado) en SharedPreferences
  Future<void> _guardar() async {
    final nombre = _nombreCtrl.text.trim();
    // Validación: el nombre no puede estar vacío
    if (nombre.isEmpty) {
      setState(() {
        _error = 'Escribe un nombre';
      });
      return;
    }

    // Leemos la lista actual de hábitos guardados
    final habitos = await _servicio.getHabitos();

    if (widget.habito == null) {
      // Crear: el id es la fecha y hora actual en milisegundos (único)
      habitos.add(Habito(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: nombre,
        color: _color,
        fechasCompletadas: [], // un hábito nuevo no tiene días completados
      ));
    } else {
      // Editar: buscamos el hábito por id y cambiamos nombre y color
      final existente = habitos.firstWhere((h) => h.id == widget.habito!.id);
      existente.nombre = nombre;
      existente.color = _color;
    }

    // Guardamos la lista completa (el servicio la convierte a JSON)
    await _servicio.guardarHabitos(habitos);
    // Comprobamos que la pantalla sigue abierta antes de usar el context
    if (!mounted) return;
    Navigator.pop(context); // volvemos a la pantalla anterior
  }

  // Liberamos el controlador al cerrar la pantalla
  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // El título cambia según estemos creando o editando
        title: Text(widget.habito == null ? 'Nuevo hábito' : 'Editar hábito'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Campo para el nombre del hábito
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre del hábito'),
            ),
            const SizedBox(height: 24),
            // Widget propio para elegir el color
            SelectorColor(
              colorSeleccionado: _color,
              onColorCambiado: (c) {
                setState(() {
                  _color = c;
                });
              },
            ),
            const SizedBox(height: 16),
            // Mostramos el error solo si existe
            if (_error.isNotEmpty)
              Text(_error, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _guardar,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}