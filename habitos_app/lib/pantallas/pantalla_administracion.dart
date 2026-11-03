import 'package:flutter/material.dart';
import '../modelos/habito.dart';
import '../modelos/usuario.dart';
import '../servicios/shared_preferences.dart';
import '../widgets/dialogo.dart';
import 'pantalla_acceso.dart';
import 'pantalla_editar_habito.dart';

/// Panel de control para el usuario Administrador
class PantallaAdministracion extends StatefulWidget {
  const PantallaAdministracion({super.key});

  @override
  State<PantallaAdministracion> createState() => _PantallaAdministracionState();
}

class _PantallaAdministracionState extends State<PantallaAdministracion> {
  final shared_preferences _servicio = shared_preferences();
  List<Habito> _todosLosHabitos = [];
  List<Usuario> _usuarios = [];
  List<Map<String, Object?>> _estadisticas = [];
  int _totalAperturas = 0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosGlobales();
  }

  /// Carga datos globales de la app (hábitos de todos y contador de aperturas)
  Future<void> _cargarDatosGlobales() async {
    final habitos = await _servicio.getHabitos();
    final aperturas = await _servicio.getNumeroAperturas();
    final usuarios = await _servicio.getUsuarios();
    final estadisticas = await _servicio.getEstadisticas();
    if (!mounted) return;
    setState(() {
      _todosLosHabitos = habitos;
      _totalAperturas = aperturas;
      _usuarios = usuarios;
      _estadisticas = estadisticas;
      _cargando = false;
    });
  }

  /// Elimina cualquier hábito con privilegios de administrador
  Future<void> _eliminarCualquierHabito(Habito habito) async {
    final confirmado = await mostrarConfirmacion(
      context,
      'Eliminar como Admin',
      '¿Deseas forzar la eliminación del hábito "${habito.nombre}"?',
    );

    if (confirmado) {
      _todosLosHabitos.remove(habito);
      await _servicio.guardarHabitos(_todosLosHabitos);
      await _cargarDatosGlobales();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hábito "${habito.nombre}" eliminado por el Administrador')),
      );
    }
  }

  Future<void> _editarHabito(Habito? habito) async {
    String? usuarioId = habito?.usuarioId;
    if (habito == null) {
      String? seleccionado = _usuarios.where((u) => !u.esAdministrador).isEmpty
          ? null : _usuarios.firstWhere((u) => !u.esAdministrador).id;
      usuarioId = await showDialog<String>(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, actualizar) => AlertDialog(
            title: const Text('Seleccionar usuario'),
            content: DropdownButtonFormField<String>(
              value: seleccionado,
              items: _usuarios.where((u) => !u.esAdministrador).map((u) => DropdownMenuItem(
                value: u.id, child: Text(u.nombre),
              )).toList(),
              onChanged: (valor) => actualizar(() => seleccionado = valor),
              decoration: const InputDecoration(labelText: 'Propietario'),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              ElevatedButton(onPressed: seleccionado == null ? null : () => Navigator.pop(context, seleccionado), child: const Text('Continuar')),
            ],
          ));
        },
      );
      if (usuarioId == null) return;
    }
    await Navigator.push(context, MaterialPageRoute(
      builder: (context) => PantallaEditarHabito(habito: habito, usuarioId: usuarioId!),
    ));
    await _cargarDatosGlobales();
  }

  Future<void> _editarUsuario(Usuario? usuario) async {
    final nombre = TextEditingController(text: usuario?.nombre ?? '');
    final email = TextEditingController(text: usuario?.email ?? '');
    final password = TextEditingController(text: usuario?.password ?? '');
    final confirmado = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: Text(usuario == null ? 'Nuevo usuario' : 'Editar usuario'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nombre, decoration: const InputDecoration(labelText: 'Nombre')),
        TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
        TextField(controller: password, decoration: const InputDecoration(labelText: 'Contraseña')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
      ],
    ));
    if (confirmado == true && nombre.text.trim().isNotEmpty && email.text.trim().isNotEmpty && password.text.isNotEmpty) {
      final usuarios = await _servicio.getUsuarios();
      if (usuario == null) {
        usuarios.add(Usuario(
          id: DateTime.now().microsecondsSinceEpoch.toString(), nombre: nombre.text.trim(),
          email: email.text.trim(), password: password.text,
          fechaCreacion: DateTime.now().toString().split(' ')[0],
        ));
      } else {
        final indice = usuarios.indexWhere((u) => u.id == usuario.id);
        usuarios[indice] = Usuario(
          id: usuario.id, nombre: nombre.text.trim(), email: email.text.trim(),
          password: password.text, fechaCreacion: usuario.fechaCreacion, rol: usuario.rol,
        );
      }
      await _servicio.guardarUsuarios(usuarios);
      await _cargarDatosGlobales();
    }
    nombre.dispose();
    email.dispose();
    password.dispose();
  }

  Future<void> _eliminarUsuario(Usuario usuario) async {
    final confirmado = await mostrarConfirmacion(
      context,
      'Eliminar usuario',
      '¿Quieres eliminar la cuenta de ${usuario.nombre}?',
    );
    if (!confirmado) return;
    await _servicio.eliminarUsuario(usuario.id);
    final habitos = await _servicio.getHabitos();
    habitos.removeWhere((h) => h.usuarioId == usuario.id);
    await _servicio.guardarHabitos(habitos);
    await _cargarDatosGlobales();
  }

  /// Restablece completamente los datos guardados en el dispositivo
  Future<void> _restablecerSistema() async {
    final confirmado = await mostrarConfirmacion(
      context,
      'Restablecer Sistema',
      '¿Seguro que deseas borrar absolutamente todos los datos guardados en la app?',
    );

    if (confirmado) {
      await _servicio.borrarTodo();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PantallaAcceso()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PantallaAcceso()),
            ),
          )
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tarjeta de métricas globales del sistema
          Card(
            color: Colors.deepPurple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Métricas del Sistema', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Total de hábitos en el sistema: ${_todosLosHabitos.length}'),
                  Text('Aperturas totales de la aplicación: $_totalAperturas'),
                  Text('Usuarios registrados: ${_usuarios.where((u) => !u.esAdministrador).length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Gestión de usuarios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(onPressed: () => _editarUsuario(null), icon: const Icon(Icons.person_add)),
          ]),
          const SizedBox(height: 8),
          if (_usuarios.isEmpty)
            const Text('No hay usuarios registrados.')
          else
            ..._usuarios.map((usuario) => Card(
              child: ListTile(
                leading: Icon(usuario.esAdministrador ? Icons.admin_panel_settings : Icons.person),
                title: Text(usuario.nombre),
                subtitle: Text('${usuario.email} · ${usuario.rol}'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (usuario.esAdministrador) const Text('Admin'),
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => _editarUsuario(usuario)),
                  if (!usuario.esAdministrador) IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _eliminarUsuario(usuario)),
                ]),
              ),
            )),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Gestión Global de Hábitos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(onPressed: () => _editarHabito(null), icon: const Icon(Icons.add)),
          ]),
          const SizedBox(height: 8),
          // Lista de todos los hábitos creados
          if (_todosLosHabitos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text('No hay hábitos registrados en el sistema.'),
            )
          else
            ..._todosLosHabitos.map((habito) => Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Color(habito.color), child: const Icon(Icons.article, color: Colors.white)),
                title: Text(habito.nombre),
                subtitle: Text('Días completados: ${habito.fechasCompletadas.length}'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => _editarHabito(habito)),
                  IconButton(icon: const Icon(Icons.delete_forever, color: Colors.red), onPressed: () => _eliminarCualquierHabito(habito)),
                ]),
              ),
            )),
          const SizedBox(height: 20),
          const Text('Estadísticas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_estadisticas.isEmpty) const Text('Todavía no hay estadísticas.')
          else ..._estadisticas.map((dato) => ListTile(
            title: Text('Hábito: ${dato['nombre_habito']}'),
            subtitle: Text('Racha: ${dato['racha_actual']} días · Total: ${dato['total_dias_completados']} días'),
          )),
          const SizedBox(height: 30),
          // Botón de restablecimiento general para el Administrador
          ElevatedButton.icon(
            onPressed: _restablecerSistema,
            icon: const Icon(Icons.warning, color: Colors.white),
            label: const Text('Restablecer todos los datos del sistema'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
        ],
      ),
    );
  }
}
