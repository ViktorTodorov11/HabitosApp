import 'package:flutter/material.dart';
import '../modelos/habito.dart';
import '../servicios/shared_preferences.dart';

// Muestra rachas, total de días, nº de aperturas y última apertura.
class PantallaEstadisticas extends StatefulWidget {
  const PantallaEstadisticas({super.key});

  @override
  State<PantallaEstadisticas> createState() => _PantallaEstadisticasState();
}

class _PantallaEstadisticasState extends State<PantallaEstadisticas> {
  final shared_preferences _servicio = shared_preferences();
  bool _cargando = true; // true mientras se leen los datos
  List<Habito> _habitos = [];
  int _aperturas = 0; // veces que se ha abierto la app (int)
  String _ultimaApertura = ''; // fecha y hora de la última apertura (String)

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  // Lee de SharedPreferences todo lo que necesita esta pantalla
  Future<void> _cargar() async {
    final habitos = await _servicio.getHabitos();
    final aperturas = await _servicio.getNumeroAperturas();
    final ultima = await _servicio.getUltimaApertura();
    if (!mounted) return;
    setState(() {
      _habitos = habitos;
      _aperturas = aperturas;
      _ultimaApertura = ultima;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        centerTitle: true,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Datos generales de la app dentro de una tarjeta
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.phone_android),
                  title: const Text('Veces que se ha abierto la app'),
                  trailing: Text(
                    '$_aperturas',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Última apertura'),
                  subtitle: Text(_ultimaApertura),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Título de la sección de hábitos
          Text(
            'Tus hábitos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Mensaje si todavía no hay hábitos
          if (_habitos.isEmpty) const Text('Todavía no hay hábitos'),
          // Una tarjeta por cada hábito con su racha y su total
          ..._habitos.map((h) => Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(h.color),
                radius: 16,
              ),
              title: Text(
                h.nombre,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          size: 18, color: Colors.orange),
                      const SizedBox(width: 4),
                      // calcularRacha() está en la clase Habito
                      Text('Racha actual: ${h.calcularRacha()} días'),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.event_available,
                          size: 18, color: Colors.green),
                      const SizedBox(width: 4),
                      // Cada fecha de la lista es un día completado
                      Text(
                          'Total completados: ${h.fechasCompletadas.length} días'),
                    ],
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}
