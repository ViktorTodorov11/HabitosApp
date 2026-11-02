import 'package:flutter/material.dart';

class TarjetaHabito extends StatelessWidget {
  final String nombre;
  final int color;
  final bool completadoHoy;
  final IconData icono;
  final Function(bool?) onComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TarjetaHabito({
    super.key,
    required this.nombre,
    required this.color,
    required this.completadoHoy,
    this.icono = Icons.check_circle_outline,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorHabito = Color(color);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: completadoHoy ? colorHabito : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorHabito,
          child: Icon(
            completadoHoy ? Icons.check : icono,
            color: Colors.white,
          ),
        ),
        title: Text(
          nombre,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: completadoHoy ? TextDecoration.lineThrough : null,
            color: completadoHoy ? Colors.grey : null,
          ),
        ),
        subtitle: Text(completadoHoy ? '¡Completado hoy!' : 'Pendiente'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: completadoHoy,
              activeColor: colorHabito,
              onChanged: onComplete,
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}