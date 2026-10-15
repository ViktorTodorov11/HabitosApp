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
  final PreferenciasService _servicio = PreferenciasService();
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
      appBar: AppBar(title: const Text('Estadísticas')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Datos generales de la app
          Text('Veces que se ha abierto la app: $_aperturas'),
          const SizedBox(height: 8),
          Text('Última apertura: $_ultimaApertura'),
          const Divider(height: 32),
          // Mensaje si todavía no hay hábitos
          if (_habitos.isEmpty) const Text('Todavía no hay hábitos'),
          // Una fila por cada hábito con su racha y su total
          ..._habitos.map((h) => ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(h.color),
              radius: 12,
            ),
            title: Text(h.nombre),
            subtitle: Text(
              // calcularRacha() está en la clase Habito
              'Racha actual: ${h.calcularRacha()} días\n'
              // Cada fecha de la lista es un día completado
                  'Total completados: ${h.fechasCompletadas.length} días',
            ),
          )),
        ],
      ),
    );
  }
}