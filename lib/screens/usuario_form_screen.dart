import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/usuario_service.dart';

class UsuarioFormScreen extends StatefulWidget {
  const UsuarioFormScreen({super.key});

  @override
  State<UsuarioFormScreen> createState() => _UsuarioFormScreenState();
}

class _UsuarioFormScreenState extends State<UsuarioFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();

  final UsuarioService _usuarioService = UsuarioService();

  bool _guardando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _usuarioService.close();
    super.dispose();
  }

  String? _validarNombre(String? value) {
    final nombre = value?.trim() ?? '';

    if (nombre.isEmpty) {
      return 'Ingrese el nombre.';
    }

    if (nombre.length < 3) {
      return 'El nombre debe tener al menos 3 caracteres.';
    }

    if (nombre.length > 100) {
      return 'El nombre no puede superar 100 caracteres.';
    }

    return null;
  }

  String? _validarEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Ingrese el correo electrónico.';
    }

    final expresion = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!expresion.hasMatch(email)) {
      return 'Ingrese un correo electrónico válido.';
    }

    return null;
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _guardando = true;
    });

    final usuario = Usuario(
      nombre: _nombreController.text.trim(),
      email: _emailController.text.trim(),
    );

    try {
      final usuarioCreado = await _usuarioService.crearUsuario(usuario);

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Usuario registrado'),
            content: Text(
              'El usuario fue registrado correctamente.\n\n'
              'ID: ${usuarioCreado.id}\n'
              'Nombre: ${usuarioCreado.nombre}\n'
              'Correo: ${usuarioCreado.email}',
            ), 
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Aceptar'),
              ), 
            ],
          ); 
        },
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }

      String mensaje = e.message;

      if (e.statusCode == 409) {
        mensaje = 'Ese correo electrónico ya está registrado.';
      } else if (e.statusCode == 422) {
        mensaje = 'La API rechazó uno o más datos.\n${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
        ), // SnackBar
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ocurrió un error inesperado.\n$e',
          ), 
        ), 
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo usuario'),
      ), 
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Registrar usuario',
                style: Theme.of(context).textTheme.headlineSmall,
              ), 
              const SizedBox(height: 8),
              const Text(
                'Los datos se enviarán a FastAPI mediante una petición POST.',
              ), 
              const SizedBox(height: 24),
              TextFormField(
                controller: _nombreController,
                enabled: !_guardando,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ej. Ana Martínez',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ), 
                validator: _validarNombre,
                ), 
              const SizedBox(height: 18),
              TextFormField(
                controller: _emailController,
                enabled: !_guardando,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  hintText: 'Ej. ana@email.com',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ), 
                validator: _validarEmail,
                onFieldSubmitted: (_) {
                  if (!_guardando) {
                    _guardar();
                  }
                },
              ), 
              const SizedBox(height: 26),
              FilledButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ), 
                      ) 
                    : const Icon(Icons.save),
                label: Text(
                  _guardando ? 'Guardando...' : 'Guardar usuario',
                ),
              ), 
            ],
          ), 
        ), 
      ), 
    ); 
  }
}