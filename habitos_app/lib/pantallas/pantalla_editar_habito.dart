import 'package:flutter/material.dart';
import '../modelos/habito.dart';
import '../servicios/shared_preferences.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';
import '../widgets/selector_color.dart';

class PantallaEditarHabito extends StatefulWidget {
  final Habito? habito;

  const PantallaEditarHabito({super.key, this.habito});

  @override
  State<PantallaEditarHabito> createState() => _PantallaEditarHabitoState();
}

class PantallaEditarHabitoState extends State<PantallaEditarHabito> {
  final shared_preferences _servicio = shared_preferences();
  final _nombreCtrl = TextEditingController();
  int _colorSeleccionado = 0xFF2196F3;

  @override
  void initState() {
    super.initState();
    if (widget.habito != null) {
      _nombreCtrl.text = widget.habito!.nombre;
      _colorSeleccionado = widget.habito!.color;
    }
  }

  Future<void> _guardar() async {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) return;

    final habitos = await _servicio.getHabitos();

    if (widget.habito == null) {
      habitos.add(Habito(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: nombre,
        color: _colorSeleccionado,
        fechasCompletadas: [],
      ));
    } else {
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
            CampoTextoApp(
              etiqueta: 'Nombre del hábito',
              controlador: _nombreCtrl,
              icono: Icons.edit,
            ),
            const SizedBox(height: 16),
            SelectorColor(
              colorSeleccionado: _colorSeleccionado,
              onColorCambiado: (color) => setState(() => _colorSeleccionado = color),
            ),
            const SizedBox(height: 24),
            BotonPrincipal(
              texto: 'Guardar Hábito',
              onPressed: _guardar,
            ),
          ],
        ),
      ),
    );
  }
}