import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';
import 'usuario_detalle.dart';
import 'usuario_form_screen.dart';

class UsuariosScreen extends StatefulWidget{
    const UsuariosScreen({super.key});
    
    @override
    State<UsuariosScreen> createState()=> _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen>{
    final UsuarioService _usuarioService = UsuarioService();
    
    late Future<List<Usuario>> _futureUsuarios;
    
    @override
    void initState(){
        super.initState();
        _futureUsuarios = _usuarioService.getUsuarios();
    }
    
    @override
    void dispose(){
        _usuarioService.close();
        super.dispose();
    }
    
    void _recargar(){
        setState(() {
           _futureUsuarios = _usuarioService.getUsuarios(); 
        });
    }
    
    Future<void> _abrirFormulario() async{
        final bool? creado = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
                builder: (_) => UsuarioFormScreen(),
            )
        );
        if(creado == true){
            _recargar();
        }
    }
    
    void _abrirDetalle(int id){
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_)=> UsuarioDetalleScreen(
                    usuarioId: id
                )
            )
        );
    }
    
    @override
    Widget build(context){
        return Scaffold(
            appBar: AppBar(
                title: const Text("Usuarios"),
                actions: [
                    IconButton(
                        tooltip: 'Recargar',
                        onPressed: _recargar,
                        icon: const Icon(Icons.refresh)
                    )
                ]    
            ),
            floatingActionButton: FloatingActionButton.extended(
                onPressed: _abrirFormulario,
                icon: const Icon(Icons.person_add),
                label: const Text("Nuevo usuario")
            ),
            body: RefreshIndicator(
                onRefresh: () async {
                    _recargar();
                    await _futureUsuarios;
                },
                child: FutureBuilder<List<Usuario>>(
                    future: _futureUsuarios,
                    builder: (context, snapshot){
                        if(snapshot.connectionState == ConnectionState.waiting){
                            return const Center(
                                child: CircularProgressIndicator()
                            );
                        }
                        
                        if(snapshot.hasError){
                            return ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                    const SizedBox(height: 130),
                                    Icon(
                                        Icons.cloud_off,
                                        size: 72,
                                        color: Theme.of(context).colorScheme.error
                                    ),
                                    const SizedBox(height: 18),
                                    Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 24),
                                        child: Text(
                                            'No fue posible obtener los usuarios.\n\n${snapshot.error}',
                                            textAlign: TextAlign.center,
                                        )
                                    ),
                                    const SizedBox(height: 20),
                                    Center(
                                       child: FilledButton.icon(
                                           onPressed: _recargar,
                                           icon: const Icon(Icons.refresh),
                                           label: const Text('Reintentar')
                                       )
                                    )
                                ]
                            );
                        }
                        final usuarios = snapshot.data?? [];
                        if(usuarios.isEmpty){
                            return ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: const[
                                   SizedBox(height: 150),
                                   Icon(Icons.people_outline, size: 72),
                                   SizedBox(height: 18),
                                   Center(
                                       child: Text(
                                           'No hay usuarios registrados'
                                       )
                                   )
                                ]
                            );
                        }
                        return ListView.separated(
                             physics: const AlwaysScrollableScrollPhysics(),
                             padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                             itemCount: usuarios.length,
                             separatorBuilder: (_, _)=> const SizedBox(
                                 height: 4),
                             itemBuilder: (contex, index){
                                 final usuario = usuarios[index];
                                 return Card(
                                     child: ListTile(
                                         leading: CircleAvatar(
                                             child: Text(
                                                 usuario.nombre.isNotEmpty? usuario.nombre[0].toUpperCase(): '?'
                                             ),
                                         ),
                                         title: Text(usuario.nombre),
                                         subtitle: Text(usuario.email),
                                         trailing: const Icon(Icons.chevron_right),
                                         onTap: usuario.id == null? null: ()=> _abrirDetalle(usuario.id!),
                                     )
                                 );
                             }
                        );
                    }
                )
            )
        );
    }
    
}
