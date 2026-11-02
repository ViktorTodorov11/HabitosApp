class Habito {
  String id;
  String nombre;
  int color;
  List<String> fechasCompletadas;
  // identifica al propietario del hábito.
  String? usuarioId;

  Habito({
    required this.id,
    required this.nombre,
    required this.color,
    required this.fechasCompletadas,
    this.usuarioId,
  });

  // Convertir a Map para guardar en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'color': color,
      'fechasCompletadas': fechasCompletadas,
      'usuarioId': usuarioId,
    };
  }

  // Crear desde un Map del JSON
  factory Habito.fromJson(Map<String, dynamic> json) {
    return Habito(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      color: json['color'] ?? 0xFF2196F3,
      fechasCompletadas: List<String>.from(json['fechasCompletadas'] ?? []),
      usuarioId: json['usuarioId'],
    );
  }

  // Comprobar si está hecho hoy
  bool estaHechoHoy() {
    String hoy = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD
    return fechasCompletadas.contains(hoy);
  }

  // Calcular días consecutivos en racha
  int calcularRacha() {
    int racha = 0;
    DateTime fecha = DateTime.now();

    // Si hoy no se ha marcado, comprobamos desde ayer
    String hoy = fecha.toString().split(' ')[0];
    if (!fechasCompletadas.contains(hoy)) {
      fecha = fecha.subtract(const Duration(days: 1));
    }

    while (true) {
      String fechaTexto = fecha.toString().split(' ')[0];
      if (fechasCompletadas.contains(fechaTexto)) {
        racha++;
        fecha = fecha.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return racha;
  }
}