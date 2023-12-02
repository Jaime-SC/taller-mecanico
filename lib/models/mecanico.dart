import 'package:cloud_firestore/cloud_firestore.dart';

class Mecanico {
  final String id; // Agregado para representar el ID del Mecanico
  final String rut_mecanico;
  final String nom_mecanico;
  final String ape_mecanico;
  final String email_mecanico;

  Mecanico({
    required this.id,
    required this.rut_mecanico,
    required this.nom_mecanico,
    required this.ape_mecanico,
    required this.email_mecanico,
    
  });

  factory Mecanico.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw StateError('Los datos del documento son nulos.');
    }

    return Mecanico(
      id: doc.id,
      rut_mecanico: data['rut_mecanico'] ?? '',
      nom_mecanico: data['nom_mecanico'] ?? '',
      ape_mecanico: data['ape_mecanico'] ?? '',
      email_mecanico: data['email_mecanico'] ?? '',
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    final Map<String, dynamic> jsonData = {
      "rut_mecanico": rut_mecanico,
      "nom_mecanico": nom_mecanico,
      "ape_mecanico": ape_mecanico,
      "email_mecanico": email_mecanico,
 
    };

    if (includeId) {
      jsonData['id'] = id;
    }

    return jsonData;
  }
}
