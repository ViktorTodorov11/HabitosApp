import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart' as preferencias;
import '../modelos/habito.dart';
import '../modelos/usuario.dart';
import 'claves.dart';

// Ajustes sencillos en SharedPreferences y datos principales en SQLite.
class shared_preferences {
  static Database? _database;
  static const String _claveUsuariosAntiguos = 'usuarios_registrados';

  Future<Database> get database async {
    if (_database != null) return _database!;
    final ruta = join(await getDatabasesPath(), 'habitos_app.db');
    _database = await openDatabase(
      ruta,
      version: 1,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE usuarios (
          id TEXT PRIMARY KEY,
          nombre TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          fecha_creacion TEXT NOT NULL,
          rol TEXT NOT NULL DEFAULT 'usuario'
        )''');
        await db.execute('''CREATE TABLE habitos (
          id TEXT PRIMARY KEY,
          nombre TEXT NOT NULL,
          color INTEGER NOT NULL,
          fechas_completadas TEXT NOT NULL,
          usuario_id TEXT NOT NULL,
          FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
        )''');
        await db.execute('''CREATE TABLE estadisticas (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          habito_id TEXT NOT NULL UNIQUE,
          usuario_id TEXT NOT NULL,
          racha_actual INTEGER NOT NULL DEFAULT 0,
          total_dias_completados INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (habito_id) REFERENCES habitos(id) ON DELETE CASCADE,
          FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
        )''');
      },
    );
    await _migrarDatosAntiguos(_database!);
    return _database!;
  }

  // Conserva los usuarios y hábitos que ya estaban guardados en SharedPreferences.
  Future<void> _migrarDatosAntiguos(Database db) async {
    final prefs = await preferencias.SharedPreferences.getInstance();
    final cantidad = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM usuarios')) ?? 0;
    if (cantidad > 0) return;

    final usuariosJson = prefs.getStringList(_claveUsuariosAntiguos) ?? [];
    final antiguos = usuariosJson
        .map((texto) => Usuario.fromJson(jsonDecode(texto)))
        .toList();
    if (antiguos.isEmpty) {
      antiguos.add(Usuario(
        id: 'admin', nombre: 'Admin', email: 'admin@habitos.app',
        password: 'admin123', fechaCreacion: DateTime.now().toString().split(' ')[0], rol: 'admin',
      ));
    }
    await db.transaction((txn) async {
      for (final usuario in antiguos) {
        await txn.insert('usuarios', _usuarioMap(usuario), conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      final habitosJson = prefs.getStringList(Claves.listaHabitos) ?? [];
      for (final texto in habitosJson) {
        final habito = Habito.fromJson(jsonDecode(texto));
        String? propietario = habito.usuarioId;
        if (propietario == null || propietario.isEmpty) {
          propietario = antiguos.firstWhere((u) => !u.esAdministrador, orElse: () => antiguos.first).id;
        }
        final existe = await txn.query('usuarios', where: 'id = ?', whereArgs: [propietario]);
        if (existe.isEmpty) continue;
        habito.usuarioId = propietario;
        await txn.insert('habitos', _habitoMap(habito), conflictAlgorithm: ConflictAlgorithm.replace);
        await _guardarEstadistica(txn, habito);
      }
    });
  }

  Map<String, Object?> _usuarioMap(Usuario u) => {
    'id': u.id, 'nombre': u.nombre, 'email': u.email,
    'password': u.password, 'fecha_creacion': u.fechaCreacion, 'rol': u.rol,
  };

  Usuario _usuarioDesdeFila(Map<String, Object?> fila) => Usuario(
    id: fila['id'] as String,
    nombre: fila['nombre'] as String,
    email: fila['email'] as String,
    password: fila['password'] as String,
    fechaCreacion: fila['fecha_creacion'] as String,
    rol: fila['rol'] as String,
  );

  Map<String, Object?> _habitoMap(Habito h) => {
    'id': h.id, 'nombre': h.nombre, 'color': h.color,
    'fechas_completadas': jsonEncode(h.fechasCompletadas),
    'usuario_id': h.usuarioId ?? '',
  };

  Habito _habitoDesdeFila(Map<String, Object?> fila) => Habito(
    id: fila['id'] as String,
    nombre: fila['nombre'] as String,
    color: fila['color'] as int,
    fechasCompletadas: List<String>.from(jsonDecode(fila['fechas_completadas'] as String)),
    usuarioId: fila['usuario_id'] as String,
  );

  Future<void> _guardarEstadistica(Transaction txn, Habito habito) async {
    await txn.insert('estadisticas', {
      'habito_id': habito.id,
      'usuario_id': habito.usuarioId ?? '',
      'racha_actual': habito.calcularRacha(),
      'total_dias_completados': habito.fechasCompletadas.length,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Nombre y preferencias de la aplicación: siguen en SharedPreferences.
  Future<String> getNombre() async { final p = await preferencias.SharedPreferences.getInstance(); return p.getString(Claves.nombre) ?? ''; }
  Future<void> setNombre(String v) async { final p = await preferencias.SharedPreferences.getInstance(); await p.setString(Claves.nombre, v); }
  Future<int> getObjetivoDiario() async { final p = await preferencias.SharedPreferences.getInstance(); return p.getInt(Claves.objetivoDiario) ?? 3; }
  Future<void> setObjetivoDiario(int v) async { final p = await preferencias.SharedPreferences.getInstance(); await p.setInt(Claves.objetivoDiario, v); }
  Future<int> getNumeroAperturas() async { final p = await preferencias.SharedPreferences.getInstance(); return p.getInt(Claves.numeroAperturas) ?? 0; }
  Future<String> getUltimaApertura() async { final p = await preferencias.SharedPreferences.getInstance(); return p.getString(Claves.ultimaApertura) ?? 'Nunca'; }
  Future<void> registrarApertura() async {
    final p = await preferencias.SharedPreferences.getInstance();
    await p.setInt(Claves.numeroAperturas, (p.getInt(Claves.numeroAperturas) ?? 0) + 1);
    await p.setString(Claves.ultimaApertura, DateTime.now().toString().split('.')[0]);
  }
  Future<bool> getTemaOscuro() async { final p = await preferencias.SharedPreferences.getInstance(); return p.getBool(Claves.temaOscuro) ?? false; }
  Future<void> setTemaOscuro(bool v) async { final p = await preferencias.SharedPreferences.getInstance(); await p.setBool(Claves.temaOscuro, v); }
  Future<bool> getOcultarCompletados() async { final p = await preferencias.SharedPreferences.getInstance(); return p.getBool(Claves.ocultarCompletados) ?? false; }
  Future<void> setOcultarCompletados(bool v) async { final p = await preferencias.SharedPreferences.getInstance(); await p.setBool(Claves.ocultarCompletados, v); }
  Future<bool> getBienvenidaCompletada() async { final p = await preferencias.SharedPreferences.getInstance(); return p.getBool(Claves.bienvenidaCompletada) ?? false; }
  Future<void> setBienvenidaCompletada(bool v) async { final p = await preferencias.SharedPreferences.getInstance(); await p.setBool(Claves.bienvenidaCompletada, v); }
  Future<double> getTamanoLetra() async { final p = await preferencias.SharedPreferences.getInstance(); return p.getDouble(Claves.tamanoLetra) ?? 16.0; }
  Future<void> setTamanoLetra(double v) async { final p = await preferencias.SharedPreferences.getInstance(); await p.setDouble(Claves.tamanoLetra, v); }

  // CRUD de usuarios.
  Future<List<Usuario>> getUsuarios() async {
    final db = await database;
    final filas = await db.query('usuarios', orderBy: 'nombre');
    return filas.map(_usuarioDesdeFila).toList();
  }
  Future<void> guardarUsuarios(List<Usuario> usuarios) async {
    final db = await database;
    await db.transaction((txn) async {
      for (final u in usuarios) {
        await txn.insert('usuarios', _usuarioMap(u), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }
  Future<void> crearAdministradorInicial() async {
    final db = await database;
    final existe = await db.query('usuarios', where: 'email = ?', whereArgs: ['admin@habitos.app']);
    if (existe.isEmpty) {
      await db.insert('usuarios', _usuarioMap(Usuario(
        id: 'admin', nombre: 'Admin', email: 'admin@habitos.app', password: 'admin123',
        fechaCreacion: DateTime.now().toString().split(' ')[0], rol: 'admin',
      )), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }
  Future<bool> registrarUsuario({required String nombre, required String email, required String password}) async {
    await crearAdministradorInicial();
    final db = await database;
    final existe = await db.query('usuarios', where: 'lower(email) = ?', whereArgs: [email.toLowerCase()]);
    if (existe.isNotEmpty) return false;
    await db.insert('usuarios', _usuarioMap(Usuario(
      id: DateTime.now().microsecondsSinceEpoch.toString(), nombre: nombre, email: email,
      password: password, fechaCreacion: DateTime.now().toString().split(' ')[0],
    )));
    return true;
  }
  Future<Usuario?> comprobarAcceso(String identificador, String password) async {
    await crearAdministradorInicial();
    final db = await database;
    final filas = await db.query('usuarios', where: '(lower(email) = ? OR lower(nombre) = ?) AND password = ?',
      whereArgs: [identificador.toLowerCase(), identificador.toLowerCase(), password], limit: 1);
    return filas.isEmpty ? null : _usuarioDesdeFila(filas.first);
  }
  Future<void> eliminarUsuario(String id) async {
    final db = await database;
    await db.delete('usuarios', where: 'id = ? AND rol != ?', whereArgs: [id, 'admin']);
  }

  // CRUD de hábitos.
  Future<List<Habito>> getHabitos() async {
    final db = await database;
    final filas = await db.query('habitos', orderBy: 'nombre');
    return filas.map(_habitoDesdeFila).toList();
  }
  Future<List<Habito>> getHabitosUsuario(String usuarioId) async {
    final db = await database;
    final filas = await db.query('habitos', where: 'usuario_id = ?', whereArgs: [usuarioId], orderBy: 'nombre');
    return filas.map(_habitoDesdeFila).toList();
  }
  Future<void> guardarHabitos(List<Habito> habitos) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('habitos');
      for (final h in habitos) {
        if (h.usuarioId == null || h.usuarioId!.isEmpty) continue;
        await txn.insert('habitos', _habitoMap(h), conflictAlgorithm: ConflictAlgorithm.replace);
        await _guardarEstadistica(txn, h);
      }
    });
  }
  Future<void> guardarHabitosUsuario(String usuarioId, List<Habito> habitosUsuario) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('habitos', where: 'usuario_id = ?', whereArgs: [usuarioId]);
      for (final h in habitosUsuario) {
        h.usuarioId = usuarioId;
        await txn.insert('habitos', _habitoMap(h), conflictAlgorithm: ConflictAlgorithm.replace);
        await _guardarEstadistica(txn, h);
      }
    });
  }
  Future<List<Map<String, Object?>>> getEstadisticas() async {
    final db = await database;
    return db.rawQuery('''SELECT estadisticas.*, habitos.nombre AS nombre_habito
      FROM estadisticas INNER JOIN habitos ON estadisticas.habito_id = habitos.id
      ORDER BY total_dias_completados DESC''');
  }

  Future<void> borrarTodo() async {
    final db = await database;
    await db.delete('estadisticas');
    await db.delete('habitos');
    await db.delete('usuarios');
    final p = await preferencias.SharedPreferences.getInstance();
    await p.clear();
    await crearAdministradorInicial();
  }

  Future<int> getnumeroAperturas() => getNumeroAperturas();
  Future<void> incrementarAperturas() => registrarApertura();
}
