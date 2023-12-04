import 'package:cloud_firestore/cloud_firestore.dart';

class DetalleOrdenTrabajo {
  final DocumentReference<Object?> idOrdTrabajoReference;
  final DocumentReference<Object?> idServicioReference;
  final DocumentReference<Object?> rutMecanicoReference;
  final Timestamp fecha_inicio;
  final Timestamp fecha_termino;
  final String estado;
  final int costo;

  DetalleOrdenTrabajo({
    required this.idOrdTrabajoReference,
    required this.idServicioReference,
    required this.rutMecanicoReference,
    required this.fecha_inicio,
    required this.fecha_termino,
    required this.estado,
    required this.costo
  });

  factory DetalleOrdenTrabajo.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw StateError('Los datos del documento son nulos.');
    }

    DocumentReference? idOrdTrabajoRef = data['idOrdTrabajoReference'];
    DocumentReference? idServicioRef = data['idServicioReference'];
    DocumentReference? rutMecanicoRef = data['rutMecanicoReference'];

    if (idOrdTrabajoRef == null) {
      throw StateError('El campo idOrdTrabajoReference no está presente en el documento.');
    }

    if (idServicioRef == null) {
      throw StateError('El campo idServicioReference no está presente en el documento.');
    }

    if (rutMecanicoRef == null) {
      throw StateError('El campo rutMecanicoReference no está presente en el documento.');
    }

    return DetalleOrdenTrabajo(
      idOrdTrabajoReference: idOrdTrabajoRef,
      idServicioReference: idServicioRef,
      rutMecanicoReference: rutMecanicoRef,
      fecha_inicio: data['fecha_inicio'] as Timestamp,
      fecha_termino: data['fecha_termino'] as Timestamp,
      estado: data['estado'] ?? '',
      costo: (data['costo'] ?? 0) as int,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      //'id_ord_trabajo': id_ord_trabajo,
      'idOrdTrabajoReference': idOrdTrabajoReference,
      'idServicioReference': idServicioReference,
      'rutMecanicoReference': rutMecanicoReference,
      'fecha_inicio': fecha_inicio,
      'fecha_termino': fecha_termino,
      'estado': estado,
      'costo': costo
    };
  }
}