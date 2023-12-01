import 'package:cloud_firestore/cloud_firestore.dart';

class Cliente {
  final String id; // Agregado para representar el ID del cliente
  final String rut_cliente;
  final String nom_cliente;
  final String ape_cliente;
  final String dir_cliente;
  final String tel_cliente;
  final String email_cliente;

  Cliente({
    required this.id,
    required this.rut_cliente,
    required this.nom_cliente,
    required this.ape_cliente,
    required this.dir_cliente,
    required this.tel_cliente,
    required this.email_cliente,
  });

  factory Cliente.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw StateError('Los datos del documento son nulos.');
    }

    return Cliente(
      id: doc.id,
      rut_cliente: data['rut_cliente'] ?? '',
      nom_cliente: data['nom_cliente'] ?? '',
      ape_cliente: data['ape_cliente'] ?? '',
      dir_cliente: data['dir_cliente'] ?? '',
      tel_cliente: data['tel_cliente'] ?? '',
      email_cliente: data['email_cliente'] ?? '',
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    final Map<String, dynamic> jsonData = {
      "rut_cliente": rut_cliente,
      "nom_cliente": nom_cliente,
      "ape_cliente": ape_cliente,
      "dir_cliente": dir_cliente,
      "tel_cliente": tel_cliente,
      "email_cliente": email_cliente,
    };

    if (includeId) {
      jsonData['id'] = id;
    }

    return jsonData;
  }
}
