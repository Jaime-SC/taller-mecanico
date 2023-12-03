import 'package:cloud_firestore/cloud_firestore.dart';

class Factura {
  final String id_factura;
  final DocumentReference<Object?> idOrdTrabajoReference;  
  final Timestamp fecha_factura;
  final int total;
  final String estado;

  Factura({
    required this.id_factura,
    required this.idOrdTrabajoReference,
    required this.fecha_factura,
    required this.total,
    required this.estado,
  });

  factory Factura.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw StateError('Los datos del documento son nulos.');
    }

    DocumentReference? idOrdTrabajoRef = data['idOrdTrabajoReference'];

    if (idOrdTrabajoRef == null) {
      throw StateError(
          'El campo idOrdTrabajoReference no está presente en el documento.');
    }

    return Factura(
      id_factura: data['id_factura'] ?? '',
      idOrdTrabajoReference: idOrdTrabajoRef,
      fecha_factura: data['fecha_factura'] as Timestamp,
      total: data['total'] ?? '',
      estado: data['estado'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_factura': id_factura,
      'idOrdTrabajoReference': idOrdTrabajoReference,
      'fecha_factura': fecha_factura,
      'total': total,
      'estado': estado,
    };
  }
}
