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

  Map<String, dynamic> toJson() {
    return {
      "rut_cliente": rut_cliente,
      "nom_cliente": nom_cliente,
      "ape_cliente": ape_cliente,
      "dir_cliente": dir_cliente,
      "tel_cliente": tel_cliente,
      "email_cliente": email_cliente,
    };
  }
}
