import 'package:cloud_firestore/cloud_firestore.dart';

class OrdenTrabajo {
  //final String id_ord_trabajo;
  final DocumentReference<Object?> rutReference;
  final DocumentReference<Object?> matriculaVehiculoReference;
  final Timestamp fecha_inicio;
  final Timestamp fecha_termino;
  final String estado;

  OrdenTrabajo({
    //required this.id_ord_trabajo,
    required this.rutReference,
    required this.matriculaVehiculoReference,
    required this.fecha_inicio,
    required this.fecha_termino,
    required this.estado,
  });

  factory OrdenTrabajo.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw StateError('Los datos del documento son nulos.');
    }

    DocumentReference? clienteRef = data['rutReference'];
    DocumentReference? matriculaVehiculoRef = data['matriculaVehiculoReference'];

    if (clienteRef == null) {
      throw StateError('El campo rutReference no está presente en el documento.');
    }

    if (matriculaVehiculoRef == null) {
      throw StateError('El campo matriculaVehiculoRef no está presente en el documento.');
    }

    return OrdenTrabajo(
      //id_ord_trabajo: doc.id,
      rutReference: clienteRef,
      matriculaVehiculoReference: matriculaVehiculoRef,
      fecha_inicio: data['fecha_inicio'] as Timestamp,
      fecha_termino: data['fecha_termino'] as Timestamp,
      estado: data['estado'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      //'id_ord_trabajo': id_ord_trabajo,
      'rutReference': rutReference,
      'matriculaVehiculoReference': matriculaVehiculoReference,
      'fecha_inicio': fecha_inicio,
      'fecha_termino': fecha_termino,
      'estado': estado,
    };
  }
}
