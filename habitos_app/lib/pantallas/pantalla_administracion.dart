import 'package:flutter/material.dart';
import 'pantalla_acceso.dart';

class AdministracionPage extends StatelessWidget {
  const AdministracionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Gestión Global de Usuarios'),
            subtitle: Text('Consulta, edición y eliminación de usuarios'),
          ),
          ListTile(
            leading: Icon(Icons.storage),
            title: Text('Gestión Global de Hábitos'),
            subtitle: Text('Supervisión de hábitos de la plataforma'),
          ),
        ],
      ),
    );
  }
}