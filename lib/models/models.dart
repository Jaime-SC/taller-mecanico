class Cliente {
  final String rut_cliente;
  final String nom_cliente;
  final String ape_cliente;
  final String dir_cliente;
  final String tel_cliente;
  final String email_cliente;

  Cliente({
    required this.rut_cliente,
    required this.nom_cliente,
    required this.ape_cliente,
    required this.dir_cliente,
    required this.tel_cliente,
    required this.email_cliente,
  });

  // Método para convertir un mapa en una instancia de Cliente
  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      rut_cliente: map['rut_cliente'],
      nom_cliente: map['nom_cliente'],
      ape_cliente: map['ape_cliente'],
      dir_cliente: map['dir_cliente'],
      tel_cliente: map['tel_cliente'],
      email_cliente: map['email_cliente'],
    );
  }

  // Método para convertir una instancia de Cliente en un mapa
  Map<String, dynamic> toMap() {
    return {
      'rut_cliente': rut_cliente,
      'nom_cliente': nom_cliente,
      'ape_cliente': ape_cliente,
      'dir_cliente': dir_cliente,
      'tel_cliente': tel_cliente,
      'email_cliente': email_cliente,
    };
  }
}
