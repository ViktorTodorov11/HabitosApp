import 'package:flutter/material.dart';
import '../modelos/habito.dart';
import '../servicios/shared_preferences.dart';
import '../widgets/dato_estadistica.dart';

class EstadisticasPage extends StatefulWidget {
  // permite mostrar las estadísticas del usuario conectado.
  final String usuarioId;
  const EstadisticasPage({super.key, this.usuarioId = ''});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  final shared_preferences _servicio = shared_preferences();
  List<Habito> _habitos = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    // filtra por propietario cuando se conoce el usuario.
    final habitos = widget.usuarioId.isEmpty ? await _servicio.getHabitos() : await _servicio.getHabitosUsuario(widget.usuarioId);
    if (!mounted) return;
    setState(() => _habitos = habitos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: _habitos.isEmpty
          ? const Center(child: Text('Todavía no hay hábitos para mostrar'))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: _habitos.map((h) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                h.nombre,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DatoEstadistica(
                etiqueta: 'Racha actual',
                valor: '${h.calcularRacha()} días',
                icono: Icons.local_fire_department,
                color: Colors.orange,
              ),
              DatoEstadistica(
                etiqueta: 'Días completados',
                valor: '${h.fechasCompletadas.length} días',
                icono: Icons.check_circle,
                color: Colors.green,
              ),
              const Divider(),
            ],
          );
        }).toList(),
      ),
    );
  }
}