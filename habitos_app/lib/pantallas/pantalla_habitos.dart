import 'package:flutter/material.dart';
import '../modelos/habito.dart';
import '../servicios/shared_preferences.dart';
import '../widgets/tarjeta_habito.dart';
import '../widgets/dialogo.dart';
import 'editar_habito_page.dart';
import 'estadisticas_page.dart';
import 'pantalla_acceso.dart';

class HabitosPage extends StatefulWidget {
  final String nombreUsuario;

  const HabitosPage({super.key, required this.nombreUsuario});

  @override
  State<HabitosPage> createState() => _HabitosPageState();
}

class _HabitosPageState extends State<HabitosPage> {
  final shared_preferences _servicio = shared_preferences();
  List<Habito> _habitos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarHabitos();
  }

  Future<void> _cargarHabitos() async {
    final habitos = await _servicio.getHabitos();
    setState(() {
      _habitos = habitos;
      _cargando = false;
    });
  }

  Future<void> _eliminarHabito(Habito habito) async {
    final confirmado = await mostrarConfirmacion(
      context,
      'Eliminar Hábito',
      '¿Seguro que deseas eliminar "${habito.nombre}"?',
    );

    if (confirmado) {
      _habitos.remove(habito);
      await _servicio.guardarHabitos(_habitos);
      _cargarHabitos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hábitos de ${widget.nombreUsuario}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EstadisticasPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditarHabitoPage()),
          );
          _cargarHabitos();
        },
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _habitos.isEmpty
          ? const Center(child: Text('Aún no tienes hábitos registrados.'))
          : ListView.builder(
        itemCount: _habitos.length,
        itemBuilder: (context, i) {
          final h = _habitos[i];
          return TarjetaHabito(
            nombre: h.nombre,
            color: h.color,
            completadoHoy: h.estaHechoHoy(),
            onComplete: (val) async {
              final hoy = DateTime.now().toString().split(' ')[0];
              if (val == true) {
                h.fechasCompletadas.add(hoy);
              } else {
                h.fechasCompletadas.remove(hoy);
              }
              await _servicio.guardarHabitos(_habitos);
              setState(() {});
            },
            onEdit: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditarHabitoPage(habito: h)),
              );
              _cargarHabitos();
            },
            onDelete: () => _eliminarHabito(h),
          );
        },
      ),
    );
  }
}