import 'package:flutter/material.dart';

Future<bool> mostrarConfirmacion(BuildContext context, String titulo, String mensaje) async {
  bool? resultado = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        // Icono de aviso encima del título
        icon: const Icon(Icons.warning_amber_rounded, size: 36),
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Aceptar'),
          ),
        ],
      );
    },
  );
  return resultado ?? false;
}
