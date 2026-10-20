import 'package:flutter/material.dart';

// Pantalla que se muestra mientras se leen los datos guardados.
// Es StatelessWidget porque no tiene nada que cambie: siempre se ve igual.
class PantallaCarga extends StatelessWidget {
  const PantallaCarga({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // Center pone el círculo de carga en el centro de la pantalla
      body: Center(child: CircularProgressIndicator()),
    );
  }
}