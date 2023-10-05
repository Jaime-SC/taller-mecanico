class Cliente {
  final String rut;
  final String nombre;
  final String apellido;
  final String direccion;
  final String telefono;
  final String email;

  Cliente({
    required this.rut,
    required this.nombre,
    required this.apellido,
    required this.direccion,
    required this.telefono,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      "rut_cliente": rut,
      "nom_cliente": nombre,
      "ape_cliente": apellido,
      "dir_cliente": direccion,
      "tel_cliente": telefono,
      "email_cliente": email,
    };
  }
}
