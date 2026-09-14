import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/usuario.dart';

class ApiException implements Exception {
    final String message;
    final int? statusCode;
    
    const ApiException(
        this.message,{
        this.statusCode
    });
    
    @override
    String toString() => message;
}

class UsuarioService {
    final http.Client _client;
    
    UsuarioService({
        http.Client? client,
    }): _client = client ?? http.Client();
    
    Uri _uri(String endpoint){
        return Uri.parse('${ApiConfig.baseUrl}$endpoint');
    }
    
    String _extraerMensaje(http.Response response){
        try{
            final dynamic data = jsonDecode(response.body);
            
            if(data is Map<String, dynamic>){
                final detail = data['detail'];
                
                if(detail is String && detail.trim().isNotEmpty){
                    return detail;
                }
                if(detail is List && detail.isNotEmpty){
                    final first = detail.first;
                    
                    if(first is Map<String, dynamic>){
                        final msg = first['msg'];
                        final loc = first['loc'];
                        
                        if(msg is String){
                            if (loc is List && loc.isNotEmpty){
                                return '${loc.join('-->')}: $msg';
                            }
                            return msg;
                        }
                    }
                }
                
            }
        } catch(_){
            
        }
        return "Error HTTP ${response.statusCode}";
    }
    //get todos los usuarios
    Future<List<Usuario>> getUsuarios() async {
        try{
            final response = await  _client.get(
                _uri('/usuarios'),
                headers: const{'Accept': 'application/json'}
            );
            if(response.statusCode != 200){
                throw ApiException(
                    _extraerMensaje(response),
                    statusCode: response.statusCode
                );
                
            }
            final dynamic decoded = jsonDecode(response.body);
            
            if(decoded is! List){
                throw const ApiException(
                    'La api devolvió un formato inesperado'
                );
            }
            return decoded.map(
                (item) => Usuario.fromJson(
                    Map<String, dynamic>.from(item as Map),
                )
            ).toList();
        }on ApiException{
            rethrow;
        } catch (e) {
            throw ApiException('No se conecto a la api.\n$e');
        }
    }
    //get de un solo usuario por id
    Future<Usuario> getUsuario(int id) async {
        try{
            final response = await  _client.get(
                _uri('/usuarios/$id'),
                headers: const{'Accept': 'application/json'}
            );
            if(response.statusCode != 200){
                throw ApiException(
                    _extraerMensaje(response),
                    statusCode: response.statusCode
                );
                
            }
            final dynamic decoded = jsonDecode(response.body);
            
            if(decoded is! Map){
                throw const ApiException(
                    'La api devolvió un formato inesperado'
                );
            }
            return Usuario.fromJson(
                Map<String, dynamic>.from(decoded)
            );
        }on ApiException{
            rethrow;
        } catch (e) {
            throw ApiException('No fue posible consultar el usuario\n$e');
        }
    }
    //metodo post para crear un usuario
    Future<Usuario> crearUsuario(Usuario usuario) async {
        try{
            final response = await  _client.post(
                _uri('/usuarios'),
                headers: const{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'Accept': 'application/json'
                },
                body: jsonEncode(usuario.toJson())
            );
            if(response.statusCode != 201){
                throw ApiException(
                    _extraerMensaje(response),
                    statusCode: response.statusCode
                );
                
            }
            final dynamic decoded = jsonDecode(response.body);
            
            if(decoded is! Map){
                throw const ApiException(
                    'La api devolvió un formato inesperado'
                );
            }
            return Usuario.fromJson(
                Map<String, dynamic>.from(decoded)
            );
        }on ApiException{
            rethrow;
        } catch (e) {
            throw ApiException('No fue posible registrar el usuario\n$e');
        }
    }
    
    void close(){
        _client.close();
    }
}