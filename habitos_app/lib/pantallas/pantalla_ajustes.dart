import 'package:flutter/material.dart';
import '../servicios/shared_preferences.dart';
import '../widgets/dialogo.dart';

// Ajustes: tema, tamaño de letra, ocultar completados y borrar datos.
class PantallaAjustes extends StatefulWidget {
  // Función de main.dart: la llamamos tras cada cambio para que se aplique
  final Future<void> Function() onCambio;

  const PantallaAjustes({super.key, required this.onCambio});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  final shared_preferences _servicio = shared_preferences();
  bool _cargando = true;
  bool _oscuro = false; // tema oscuro (bool)
  double _tamano = 16.0; // tamaño de letra (double)
  bool _ocultar = false; // ocultar completados (bool)

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  // Lee los ajustes guardados para mostrarlos en los controles
  Future<void> _cargar() async {
    final oscuro = await _servicio.getTemaOscuro();
    final tamano = await _servicio.getTamanoLetra();
    final ocultar = await _servicio.getOcultarCompletados();
    if (!mounted) return;
    setState(() {
      _oscuro = oscuro;
      _tamano = tamano;
      _ocultar = ocultar;
      _cargando = false;
    });
  }

  // Borra todos los datos y deja la app como recién instalada
  Future<void> _borrarDatos() async {
    // Pedimos confirmación antes de borrar
    final confirmado = await mostrarConfirmacion(
      context,
      'Borrar datos',
      'Se borrará todo y la app quedará como recién instalada. ¿Continuar?',
    );
    if (!confirmado) return;

    // Borra todo en SharedPreferences
    await _servicio.borrarTodo();
    if (!mounted) return;
    // Volvemos a la pantalla inicial y main.dart mostrará la bienvenida
    Navigator.popUntil(context, (route) => route.isFirst);
    await widget.onCambio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          // Interruptor de tema oscuro
          SwitchListTile(
            title: const Text('Tema oscuro'),
            value: _oscuro,
            onChanged: (valor) async {
              setState(() {
                _oscuro = valor;
              });
              // Guardamos el valor y avisamos a main.dart para cambiar el tema
              await _servicio.setTemaOscuro(valor);
              await widget.onCambio();
            },
          ),
          // Control deslizante del tamaño de letra (de 12 a 24)
          ListTile(
            title: Text('Tamaño de letra: ${_tamano.round()}'),
            subtitle: Slider(
              min: 12,
              max: 24,
              divisions: 12, // un paso por cada punto de tamaño
              value: _tamano,
              // Mientras se arrastra solo actualizamos la pantalla
              onChanged: (valor) {
                setState(() {
                  _tamano = valor;
                });
              },
              // Solo guardamos al soltar el control deslizante
              onChangeEnd: (valor) async {
                await _servicio.setTamanoLetra(valor);
                await widget.onCambio();
              },
            ),
          ),
          // Interruptor para ocultar los hábitos completados hoy
          SwitchListTile(
            title: const Text('Ocultar hábitos completados hoy'),
            value: _ocultar,
            onChanged: (valor) async {
              setState(() {
                _ocultar = valor;
              });
              await _servicio.setOcultarCompletados(valor);
              await widget.onCambio();
            },
          ),
          const Divider(),
          // Botón para borrar todos los datos
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _borrarDatos,
              child: const Text('Borrar todos los datos'),
            ),
          ),
        ],
      ),
    );
  }
}