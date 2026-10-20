import 'package:flutter/material.dart';
import '../modelos/habito.dart';

class TituloHabito extends StatelessWidget {
  final Habito habito;
  final Function(bool?) onCheckChanged;

  const TituloHabito({
    super.key,
    required this.habito,
    required this.onCheckChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool hecho = habito.estaHechoHoy();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      // Esquinas redondeadas; si está hecho, el borde toma el color del hábito
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: hecho ? Color(habito.color) : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        // Círculo con el color del hábito (con un tick cuando está hecho)
        leading: CircleAvatar(
          backgroundColor: Color(habito.color),
          radius: 18,
          child: hecho ? const Icon(Icons.check, color: Colors.white) : null,
        ),
        title: Text(
          habito.nombre,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            // Si está hecho, el texto se ve más apagado
            color: hecho ? Colors.grey : null,
            decoration: hecho ? TextDecoration.lineThrough : null,
          ),
        ),
        // Icono de fuego junto a la racha
        subtitle: Row(
          children: [
            const Icon(Icons.local_fire_department,
                size: 18, color: Colors.orange),
            const SizedBox(width: 4),
            Text('Racha: ${habito.calcularRacha()} días'),
          ],
        ),
        trailing: Checkbox(
          value: hecho,
          activeColor: Color(habito.color),
          shape: const CircleBorder(), // casilla redonda
          onChanged: onCheckChanged,
        ),
      ),
    );
  }
}
