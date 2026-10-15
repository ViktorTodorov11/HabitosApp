import 'package:flutter/material.dart';
import '../servicios/shared_preferences.dart';

// Pantalla de bienvenida: solo aparece la primera vez.
// Es StatefulWidget porque el mensaje de error cambia mientras el usuario escribe.
class PantallaBienvenida extends StatefulWidget {
  // Función que nos pasa main.dart para avisarle de que hemos terminado
  final Future<void> Function() onTerminar;

  const PantallaBienvenida({super.key, required this.onTerminar});

  @override
  State<PantallaBienvenida> createState() => _PantallaBienvenidaState();
}

class _PantallaBienvenidaState extends State<PantallaBienvenida> {
  // Servicio de persistencia (las pantallas nunca usan SharedPreferences directamente)
  final shared_preferences _servicio = shared_preferences();
  // Controladores para leer lo que el usuario escribe en cada campo
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _objetivoCtrl = TextEditingController();
  // Mensaje de error que se muestra si los datos no son válidos
  String _error = '';

  // Se ejecuta al pulsar el botón "Empezar"
  Future<void> _guardar() async {
    // trim() quita los espacios sobrantes al principio y al final
    final nombre = _nombreCtrl.text.trim();
    // tryParse devuelve null si el texto no es un número válido
    final objetivo = int.tryParse(_objetivoCtrl.text.trim());

    // Validación: nombre vacío, objetivo no numérico o menor o igual que 0
    if (nombre.isEmpty || objetivo == null || objetivo <= 0) {
      setState(() {
        _error = 'Escribe tu nombre y un objetivo mayor que 0';
      });
      return; // salimos sin guardar nada
    }

    // Guardamos los datos en SharedPreferences (a través del servicio)
    await _servicio.setNombre(nombre); // String
    await _servicio.setObjetivoDiario(objetivo); // int
    // Marcamos la bienvenida como hecha para no volver a mostrarla (bool)
    await _servicio.setBienvenidaCompletada(true);

    // Avisamos a main.dart para que pase a la pantalla principal
    await widget.onTerminar();
  }

  // dispose se ejecuta al cerrar la pantalla: liberamos los controladores
  @override
  void dispose() {
    _nombreCtrl.dispose();
    _objetivoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bienvenido a HabitosApp')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Campo de texto para el nombre
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Tu nombre'),
            ),
            const SizedBox(height: 16),
            // Campo para el objetivo: el teclado es numérico
            TextField(
              controller: _objetivoCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Objetivo diario de hábitos',
              ),
            ),
            const SizedBox(height: 16),
            // Solo mostramos el error si hay alguno
            if (_error.isNotEmpty)
              Text(_error, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            // Botón que guarda los datos
            ElevatedButton(
              onPressed: _guardar,
              child: const Text('Empezar'),
            ),
          ],
        ),
      ),
    );
  }
}