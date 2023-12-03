import 'package:cloud_firestore/cloud_firestore.dart';

class Servicio {
  final String id_servicio; // Agregado para representar el ID del Servicio
  final String descripcion;
  final int costo;
  

  Servicio({
    required this.id_servicio,
    required this.descripcion,
    required this.costo,
    
  });

  factory Servicio.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw StateError('Los datos del documento son nulos.');
    }

    return Servicio(
      id_servicio: data['id_servicio'] ?? '',
      descripcion: data['descripcion'] ?? '',
      costo: data['costo'] ?? '',
     
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    final Map<String, dynamic> jsonData = {
      "id_servicio": id_servicio,
      "descripcion": descripcion,
      "costo": costo,  
    };

    if (includeId) {
      jsonData['id'] = id_servicio;
    }

    return jsonData;
  }
}
