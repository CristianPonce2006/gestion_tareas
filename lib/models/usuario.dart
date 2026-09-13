class Usuario {
    final int? id;
    final String nombre;
    final String email;
    
    const Usuario({
        this.id,
        required this.nombre,
        required this.email
    });
    
    factory Usuario.frorJson(Map<String, dynamic> json){
        return Usuario(
            id: json['id'] as int?,
            nombre: json['nombre'] as String? ?? '',
            email: json['email'] as String? ?? ''
        );
    }
    
    Map<String, dynamic> toJson(){
        return {
            'nombre': nombre,
            'email': email
        };
    } 
}