import 'package:flutter/material.dart';

class SelectorColor extends StatelessWidget {
  final int colorSeleccionado;
  final Function(int) onColorCambiado;

  const SelectorColor({
    super.key,
    required this.colorSeleccionado,
    required this.onColorCambiado,
  });

  @override
  Widget build(BuildContext context) {
    List<Color> colores = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: colores.map((color) {
        bool esIgual = colorSeleccionado == color.value;
        return GestureDetector(
          onTap: () => onColorCambiado(color.value),
          child: CircleAvatar(
            backgroundColor: color,
            radius: 18,
            child: esIgual ? const Icon(Icons.check, color: Colors.white) : null,
          ),
        );
      }).toList(),
    );
  }
}
