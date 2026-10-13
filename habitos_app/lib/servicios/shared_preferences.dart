import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/habito.dart';
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

  // Borrar todas las preferencias guardadas
  Future<void> borrarTodo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}