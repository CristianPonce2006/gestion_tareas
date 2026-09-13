import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';

class UsuarioDetalleScreen extends StatefulWidget {
    final int usuarioId;
    const UsuarioDetalleScreen({
        super.key,
        required this.usuarioId
    });
    
    @override
    State<UsuarioDetalleScreen> createState() => _UsuarioDetalleScreenState();
}

class _UsuarioDetalleScreenState extends State<UsuarioDetalleScreen>{
    final UsuarioService _usuarioService = UsuarioService();
    
    late Future<Usuario> _futureUsuario;
    
    @override
    void initState(){
        super.initState();
        _futureUsuario = _usuarioService.getUsuario(widget.usuarioId);
    }
    
    @override
    void dispose(){
        _usuarioService.close();
        super.dispose();
    }
    void _recargar(){
        setState(() {
            _futureUsuario = _usuarioService.getUsuario(widget.usuarioId);
        });
    }
    
    @override
    Widget build(context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('Detalle del usuario'),
                actions: [
                    IconButton(
                        onPressed: _recargar,
                        tooltip: 'Recargar',
                        icon: const Icon(Icons.refresh)
                    )
                ]
            ),
            body: FutureBuilder<Usuario>(
                future: _futureUsuario,
                builder: (context, snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                        return const Center(
                            child: CircularProgressIndicator()
                        );
                    }
                    if(snapshot.hasError){
                        return Center(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                    Icon(
                                        Icons.error_outline,
                                        size: 64,
                                        color: Theme.of(context).colorScheme.error
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                        '${snapshot.error}',
                                        textAlign: TextAlign.center,
                                        
                                    ),
                                    const SizedBox(height: 16),
                                    FilledButton.icon(
                                        onPressed: _recargar,
                                        label: const Text('Reintentar'),
                                        icon: const Icon(Icons.refresh)
                                    ),
                                ]
                            )
                        );
                    }
                    final usuario = snapshot.data!;
                    
                    return ListView(
                        padding: EdgeInsets.all(20),
                        children: [
                            Center(
                                child: CircleAvatar(
                                    radius: 42,
                                    child: Text(
                                        usuario.nombre.isNotEmpty? usuario.nombre[0].toUpperCase(): '?',
                                        style: Theme.of(context).textTheme.headlineMedium,
                                    )
                                )
                            ),
                            const SizedBox(height: 24),
                            Card(
                                child: Column(
                                    children: [
                                        ListTile(
                                            leading: const Icon(Icons.badge_outlined),
                                            title: const Text('ID'),
                                            subtitle: Text('${usuario.id ?? '_'}'),
                                        ),
                                        const Divider(height: 1),
                                        ListTile(
                                            leading: const Icon(Icons.person_outlined),
                                            title: const Text('Nombre'),
                                            subtitle: Text(usuario.nombre)
                                        ),
                                        const Divider(height: 1),
                                        ListTile(
                                            leading: const Icon(Icons.email),
                                            title: const Text('Email'),
                                            subtitle: Text(usuario.email)
                                        ),
                                        
                                    ]
                                )
                            )
                        ]
                    );
                }
            )
        );
    }
    
}