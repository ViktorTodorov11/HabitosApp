import 'package:flutter/material.dart';
import '../models/habito.dart';

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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(habito.color),
          radius: 12,
        ),
        title: Text(
          habito.nombre,
          style: TextStyle(
            decoration: hecho ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text('Racha: ${habito.calcularRacha()} días'),
        trailing: Checkbox(
          value: hecho,
          onChanged: onCheckChanged,
        ),
      ),
    );
  }
}