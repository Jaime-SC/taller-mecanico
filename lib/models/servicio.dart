import 'package:cloud_firestore/cloud_firestore.dart';

class Servicio {
  final String id; // Agregado para representar el ID del Servicio
  final String descripcion;
  final int costo;
  

  Servicio({
    required this.id,
    required this.descripcion,
    required this.costo,
    
  });

  factory Servicio.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw StateError('Los datos del documento son nulos.');
    }

    return Servicio(
      id: doc.id,
      descripcion: data['descripcion'] ?? '',
      costo: data['costo'] ?? '',
     
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    final Map<String, dynamic> jsonData = {
      "descripcion": descripcion,
      "costo": costo,  
    };

    if (includeId) {
      jsonData['id'] = id;
    }

    return jsonData;
  }
}
