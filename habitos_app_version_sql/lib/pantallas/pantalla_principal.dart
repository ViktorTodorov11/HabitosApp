import 'package:flutter/material.dart';
import '../modelos/habito.dart';
import '../servicios/shared_preferences.dart';
import '../widgets/titulo_habito.dart';
import 'panatalla_gestionhabitos.dart';
import 'pantalla_estadisticas.dart';
import 'pantalla_ajustes.dart';

// Pantalla principal: saluda, muestra el progreso y lista los hábitos.
class PantallaPrincipal extends StatefulWidget {
  // Función de main.dart que se llama cuando cambian los ajustes
  final Future<void> Function() onAjustesCambiados;

  const PantallaPrincipal({super.key, required this.onAjustesCambiados});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  // Servicio de persistencia
  final shared_preferences _servicio = shared_preferences();

  bool _cargando = true; // true mientras se leen los datos
  String _nombre = ''; // nombre del usuario (String)
  int _objetivo = 3; // objetivo diario (int)
  bool _ocultarCompletados = false; // ajuste de ocultar (bool)
  List<Habito> _habitos = []; // lista de hábitos (List<String> en JSON)

  @override
  void initState() {
    super.initState();
    _cargar(); // al abrir la pantalla leemos los datos
  }

  // Lee todos los datos necesarios de SharedPreferences
  Future<void> _cargar() async {
    final nombre = await _servicio.getNombre();
    final objetivo = await _servicio.getObjetivoDiario();
    final ocultar = await _servicio.getOcultarCompletados();
    final habitos = await _servicio.getHabitos();
    // Si la pantalla ya se cerró mientras esperábamos, no hacemos nada
    if (!mounted) return;
    setState(() {
      _nombre = nombre;
      _objetivo = objetivo;
      _ocultarCompletados = ocultar;
      _habitos = habitos;
      _cargando = false;
    });
  }

  // Marca o desmarca un hábito como hecho hoy y lo guarda
  Future<void> _marcar(Habito habito, bool? valor) async {
    // Fecha de hoy en formato YYYY-MM-DD
    final hoy = DateTime.now().toString().split(' ')[0];
    if (valor == true) {
      // Casilla marcada: añadimos hoy si no estaba ya
      if (!habito.fechasCompletadas.contains(hoy)) {
        habito.fechasCompletadas.add(hoy);
      }
    } else {
      // Casilla desmarcada: quitamos la fecha de hoy
      habito.fechasCompletadas.remove(hoy);
    }
    // Guardamos la lista completa (se serializa a JSON en el servicio)
    await _servicio.guardarHabitos(_habitos);
    setState(() {}); // redibujamos para actualizar el progreso
  }

  // Abre otra pantalla y, al volver, recarga los datos
  Future<void> _ir(Widget pantalla) async {
    // Navigator.push apila la nueva pantalla encima de esta
    // await espera hasta que el usuario vuelva atrás
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => pantalla),
    );
    // Al volver, releemos los datos por si han cambiado
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    // Mientras se leen los datos mostramos el indicador de carga
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Número de hábitos completados hoy
    final hechos = _habitos.where((h) => h.estaHechoHoy()).length;
    // Si el ajuste está activo, ocultamos los que ya están hechos hoy
    final visibles = _ocultarCompletados
        ? _habitos.where((h) => !h.estaHechoHoy()).toList()
        : _habitos;
    // Colores del tema para la tarjeta de cabecera
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('HabitosApp'),
        centerTitle: true,
        // Botones de navegación a las otras pantallas
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Gestionar hábitos',
            onPressed: () => _ir(const PantallaGestionHabitos()),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Estadísticas',
            onPressed: () => _ir(const PantallaEstadisticas()),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Ajustes',
            onPressed: () => _ir(
              PantallaAjustes(onCambio: widget.onAjustesCambiados),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Cabecera: tarjeta de color con el saludo y el progreso del día
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colores.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, $_nombre!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colores.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                // Ejemplo: "2 de 5 hábitos". Si se llega al objetivo, mensaje de ánimo
                Text(
                  hechos >= _objetivo
                      ? '¡Objetivo cumplido! 🎉 ($hechos de $_objetivo)'
                      : '$hechos de $_objetivo hábitos hoy',
                  style: TextStyle(color: colores.onPrimaryContainer),
                ),
                const SizedBox(height: 12),
                // Barra de progreso con bordes redondeados;
                // clamp limita el valor entre 0 y 1
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (hechos / _objetivo).clamp(0.0, 1.0),
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          ),
          // Expanded hace que la lista ocupe el resto de la pantalla
          Expanded(
            child: visibles.isEmpty
            // Si no hay hábitos que mostrar, icono + mensaje informativo
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 64, color: Colors.grey.shade500),
                  const SizedBox(height: 8),
                  const Text('No hay hábitos para mostrar'),
                ],
              ),
            )
            // ListView.builder crea los elementos de la lista uno a uno
                : ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: visibles.length,
              itemBuilder: (context, i) {
                final habito = visibles[i];
                // Widget propio con la casilla de cada hábito
                return TituloHabito(
                  habito: habito,
                  onCheckChanged: (valor) => _marcar(habito, valor),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
