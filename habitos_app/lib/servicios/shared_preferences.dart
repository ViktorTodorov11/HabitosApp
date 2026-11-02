import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/habito.dart';
import '../modelos/usuario.dart';
import 'claves.dart';

// Servicio centralizado. Las pantallas nunca llaman directamente a SharedPreferences.
class shared_preferences {


  // 1. TIPO STRING: Nombre del usuario (Default: '')
  Future<String> getNombre() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Claves.nombre) ?? '';
  }

  Future<void> setNombre(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Claves.nombre, nombre);
  }

  // 2. TIPO INT: Objetivo diario de hábitos (Default: 3)
  Future<int> getObjetivoDiario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(Claves.objetivoDiario) ?? 3;
  }

  Future<void> setObjetivoDiario(int objetivo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(Claves.objetivoDiario, objetivo);
  }

  // TIPO INT: Número de aperturas de la app (Default: 0)
  Future<int> getNumeroAperturas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(Claves.numeroAperturas) ?? 0;
  }

  // TIPO STRING: Fecha de última apertura (Default: 'Nunca')
  Future<String> getUltimaApertura() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Claves.ultimaApertura) ?? 'Nunca';
  }

  // Registra la apertura incrementando contador y guardando fecha/hora actual
  Future<void> registrarApertura() async {
    final prefs = await SharedPreferences.getInstance();
    int aperturas = (prefs.getInt(Claves.numeroAperturas) ?? 0) + 1;
    await prefs.setInt(Claves.numeroAperturas, aperturas);

    DateTime ahora = DateTime.now();
    String fechaFormateada = ahora.toString().split('.')[0]; // YYYY-MM-DD HH:MM:SS
    await prefs.setString(Claves.ultimaApertura, fechaFormateada);
  }

  // 3. TIPO BOOL: Tema oscuro, ocultar completados y estado de bienvenida (Default: false)
  Future<bool> getTemaOscuro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(Claves.temaOscuro) ?? false;
  }

  Future<void> setTemaOscuro(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Claves.temaOscuro, valor);
  }

  Future<bool> getOcultarCompletados() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(Claves.ocultarCompletados) ?? false;
  }

  Future<void> setOcultarCompletados(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Claves.ocultarCompletados, valor);
  }

  Future<bool> getBienvenidaCompletada() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(Claves.bienvenidaCompletada) ?? false;
  }

  Future<void> setBienvenidaCompletada(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Claves.bienvenidaCompletada, valor);
  }

  // 4. TIPO DOUBLE: Tamaño de letra (Default: 16.0)
  Future<double> getTamanoLetra() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(Claves.tamanoLetra) ?? 16.0;
  }

  Future<void> setTamanoLetra(double tamano) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(Claves.tamanoLetra, tamano);
  }

  // 5. TIPO LIST<STRING>: Serialización y deserialización JSON de objetos Habito
  Future<List<Habito>> getHabitos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? listaJson = prefs.getStringList(Claves.listaHabitos);
    if (listaJson == null) return [];

    return listaJson.map((texto) {
      Map<String, dynamic> mapa = jsonDecode(texto);
      return Habito.fromJson(mapa);
    }).toList();
  }

  Future<void> guardarHabitos(List<Habito> habitos) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listaJson = habitos.map((h) => jsonEncode(h.toJson())).toList();
    await prefs.setStringList(Claves.listaHabitos, listaJson);
  }

  static const String _claveUsuarios = 'usuarios_registrados';

  Future<List<Usuario>> getUsuarios() async {
    final prefs = await SharedPreferences.getInstance();
    final datos = prefs.getStringList(_claveUsuarios) ?? [];
    return datos.map((texto) => Usuario.fromJson(jsonDecode(texto))).toList();
  }

  // guarda la lista completa de usuarios.
  Future<void> guardarUsuarios(List<Usuario> usuarios) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _claveUsuarios,
      usuarios.map((u) => jsonEncode(u.toJson())).toList(),
    );
  }

  //  crea el administrador inicial si todavía no existe.
  Future<void> crearAdministradorInicial() async {
    final usuarios = await getUsuarios();
    if (usuarios.any((u) => u.email.toLowerCase() == 'admin@habitos.app')) return;
    usuarios.add(Usuario(
      id: 'admin',
      nombre: 'Administrador',
      email: 'admin@habitos.app',
      password: 'admin123',
      fechaCreacion: DateTime.now().toString().split(' ')[0],
      rol: 'admin',
    ));
    await guardarUsuarios(usuarios);
  }

  //  registra un usuario. Devuelve false si el correo ya existe.
  Future<bool> registrarUsuario({
    required String nombre,
    required String email,
    required String password,
  }) async {
    await crearAdministradorInicial();
    final usuarios = await getUsuarios();
    if (usuarios.any((u) => u.email.toLowerCase() == email.toLowerCase())) return false;
    usuarios.add(Usuario(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      nombre: nombre,
      email: email,
      password: password,
      fechaCreacion: DateTime.now().toString().split(' ')[0],
    ));
    await guardarUsuarios(usuarios);
    return true;
  }

  // comprueba email/nombre y contraseña.
  Future<Usuario?> comprobarAcceso(String identificador, String password) async {
    await crearAdministradorInicial();
    final usuarios = await getUsuarios();
    for (final usuario in usuarios) {
      if ((usuario.email.toLowerCase() == identificador.toLowerCase() ||
          usuario.nombre.toLowerCase() == identificador.toLowerCase()) &&
          usuario.password == password) {
        return usuario;
      }
    }
    return null;
  }

  // elimina un usuario por su identificador (no elimina admin).
  Future<void> eliminarUsuario(String id) async {
    final usuarios = await getUsuarios();
    usuarios.removeWhere((u) => u.id == id && !u.esAdministrador);
    await guardarUsuarios(usuarios);
  }

  // devuelve solo los hábitos de un usuario.
  Future<List<Habito>> getHabitosUsuario(String usuarioId) async {
    final todos = await getHabitos();
    // los hábitos antiguos sin propietario se asignan al primer usuario que entra.
    bool hayCambios = false;
    for (final habito in todos) {
      if (habito.usuarioId == null) {
        habito.usuarioId = usuarioId;
        hayCambios = true;
      }
    }
    if (hayCambios) await guardarHabitos(todos);
    return todos.where((h) => h.usuarioId == usuarioId).toList();
  }

  // guarda hábitos de un usuario sin borrar los de los demás.
  Future<void> guardarHabitosUsuario(String usuarioId, List<Habito> habitosUsuario) async {
    final todos = await getHabitos();
    todos.removeWhere((h) => h.usuarioId == usuarioId);
    for (final habito in habitosUsuario) {
      habito.usuarioId ??= usuarioId;
      todos.add(habito);
    }
    await guardarHabitos(todos);
  }



  // Borrar todas las preferencias guardadas
  Future<void> borrarTodo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // --- CONTADOR DE APERTURAS ---
  Future<int> getnumeroAperturas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(Claves.numeroAperturas) ?? 0;
  }

  Future<void> incrementarAperturas() async {
    final prefs = await SharedPreferences.getInstance();
    int actual = prefs.getInt(Claves.numeroAperturas) ?? 0;
    await prefs.setInt(Claves.numeroAperturas, actual + 1);
  }
}