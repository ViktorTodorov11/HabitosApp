import 'package:flutter/material.dart';
import 'servicios/shared_preferences.dart';
import 'pantallas/pantalla_acceso.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final shared_preferences _servicio = shared_preferences();
  bool _modoOscuro = false;

  @override
  void initState() {
    super.initState();
    _cargarTema();
  }

  Future<void> _cargarTema() async {
    final modoOscuro = await _servicio.getTemaOscuro();
    setState(() {
      _modoOscuro = modoOscuro;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HábitosApp',
      themeMode: _modoOscuro ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const PantallaAcceso(),
    );
  }
}