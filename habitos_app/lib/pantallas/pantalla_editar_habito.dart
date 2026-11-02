import 'package:flutter/material.dart';
import '../modelos/habito.dart';
import '../servicios/shared_preferences.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';
import '../widgets/selector_color.dart';

/// Formulario para crear un hábito nuevo o editar uno existente
class PantallaEditarHabito extends StatefulWidget {
  final Habito? habito;
  // propietario del hábito nuevo.
  final String usuarioId;

  const PantallaEditarHabito({super.key, this.habito, this.usuarioId = ''});

  @override
  State<PantallaEditarHabito> createState() => _PantallaEditarHabitoState();
}

class _PantallaEditarHabitoState extends State<PantallaEditarHabito> {
  final shared_preferences _servicio = shared_preferences();
  final TextEditingController _nombreCtrl = TextEditingController();
  int _colorSeleccionado = 0xFF2196F3; // Color predeterminado (Azul)

  @override
  void initState() {
    super.initState();
    // Si viene un hábito por parámetro, cargamos sus datos actuales
    if (widget.habito != null) {
      _nombreCtrl.text = widget.habito!.nombre;
      _colorSeleccionado = widget.habito!.color;
    }
  }

  /// Guarda los cambios en el almacenamiento y regresa a la pantalla anterior
  Future<void> _guardar() async {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) return;

    final habitos = await _servicio.getHabitos();

    if (widget.habito == null) {
      // Creación de nuevo hábito
      habitos.add(Habito(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: nombre,
        color: _colorSeleccionado,
        fechasCompletadas: [],
        usuarioId: widget.usuarioId.isEmpty ? null : widget.usuarioId,
      ));
    } else {
      // Edición de hábito existente
      final item = habitos.firstWhere((h) => h.id == widget.habito!.id);
      item.nombre = nombre;
      item.color = _colorSeleccionado;
    }

    await _servicio.guardarHabitos(habitos);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habito == null ? 'Nuevo Hábito' : 'Editar Hábito'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Campo de texto para el nombre del hábito
            CampoTextoApp(
              etiqueta: 'Nombre del hábito',
              controlador: _nombreCtrl,
              icono: Icons.edit,
            ),
            const SizedBox(height: 16),

            // Componente para seleccionar color
            SelectorColor(
              colorSeleccionado: _colorSeleccionado,
              onColorCambiado: (color) => setState(() => _colorSeleccionado = color),
            ),
            const SizedBox(height: 24),

            // Botón de acción para guardar
            BotonPrincipal(
              texto: 'Guardar Hábito',
              onPressed: _guardar,
            ),
            // cancelar vuelve sin guardar los cambios.
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}