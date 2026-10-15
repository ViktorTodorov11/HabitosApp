import 'package:flutter/material.dart';
import 'servicios/shared_preferences.dart';
import 'pantallas/pantalla_carga.dart';
import 'pantallas/pantalla_bienvenida.dart';
import 'pantallas/pantalla_principal.dart';

void main() {
  runApp(const MyApp());
}

// StatefulWidget porque el tema, el tamaño de letra y la pantalla inicial
// cambian según los datos guardados.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final shared_preferences _servicio = shared_preferences();

  bool _cargando = true;
  bool _bienvenidaHecha = false;
  bool _oscuro = false;
  double _tamanoLetra = 16.0;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  // Se ejecuta una sola vez al abrir la app: cuenta la apertura y lee los ajustes.
  Future<void> _iniciar() async {
    await _servicio.registrarApertura();
    await _cargarDatos();
  }

  // Lee los datos guardados. Las pantallas llaman a esta función
  // cuando cambian los ajustes, se termina la bienvenida o se borran los datos.
  Future<void> _cargarDatos() async {
    final bienvenida = await _servicio.getBienvenidaCompletada();
    final oscuro = await _servicio.getTemaOscuro();
    final tamano = await _servicio.getTamanoLetra();
    setState(() {
      _bienvenidaHecha = bienvenida;
      _oscuro = oscuro;
      _tamanoLetra = tamano;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget inicio;
    if (_cargando) {
      inicio = const PantallaCarga();
    } else if (_bienvenidaHecha) {
      inicio = PantallaPrincipal(onAjustesCambiados: _cargarDatos);
    } else {
      inicio = PantallaBienvenida(onTerminar: _cargarDatos);
    }

    return MaterialApp(
      title: 'HabitosApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: _oscuro ? Brightness.dark : Brightness.light,
        ),
      ),
      // El tamaño de letra se aplica a toda la app escalando el texto.
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(_tamanoLetra / 16.0),
          ),
          child: child!,
        );
      },
      home: inicio,
    );
  }
}
