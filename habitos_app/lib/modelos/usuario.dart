class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String password;
  final String fechaCreacion;
  final String rol; // 'usuario' o 'admin'

  const Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.password,
    required this.fechaCreacion,
    this.rol = 'usuario',
  });

  bool get esAdministrador => rol == 'admin';

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'email': email,
        'password': password,
        'fechaCreacion': fechaCreacion,
        'rol': rol,
      };

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'] ?? '',
        nombre: json['nombre'] ?? '',
        email: json['email'] ?? '',
        password: json['password'] ?? '',
        fechaCreacion: json['fechaCreacion'] ?? '',
        rol: json['rol'] ?? 'usuario',
      );
}
