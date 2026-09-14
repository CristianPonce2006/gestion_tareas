import 'package:flutter/material.dart';

import 'screens/usuarios_screen.dart';

void main() {
  runApp(const GestorUsuariosApp());
}

class GestorUsuariosApp extends StatelessWidget {
  const GestorUsuariosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestor de Usuarios',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ), 
        useMaterial3: true,
      ), 
      home: const UsuariosScreen(),
    );
  }
}