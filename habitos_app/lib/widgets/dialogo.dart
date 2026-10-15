import 'package:flutter/material.dart';

Future<bool> mostrarConfirmacion(BuildContext context, String titulo, String mensaje) async {
  bool? resultado = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
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
