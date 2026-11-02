import 'package:flutter/material.dart';

/// Componente reutilizable para los campos de texto con diseño unificado
class CampoTextoApp extends StatelessWidget {
  final String etiqueta;
  final TextEditingController controlador;
  final bool ocultarTexto;
  final IconData? icono;
  final TextInputType? tipoTeclado;

  const CampoTextoApp({
    super.key,
    required this.etiqueta,
    required this.controlador,
    this.ocultarTexto = false,
    this.icono,
    this.tipoTeclado,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Configuración correcta de márgenes simétricos
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controlador,
        obscureText: ocultarTexto,
        keyboardType: tipoTeclado,
        decoration: InputDecoration(
          labelText: etiqueta,
          prefixIcon: icono != null ? Icon(icono) : null,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );
  }
}