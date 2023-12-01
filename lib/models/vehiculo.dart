import 'package:cloud_firestore/cloud_firestore.dart';

class Vehiculo {
  final String matricula_vehiculo;
  final DocumentReference<Object?> clienteReference;
 // Tipo DocumentReference directamente
  final String marca;
  final String modelo;
  final String anio;

  Vehiculo({
    required this.matricula_vehiculo,
    required this.clienteReference,
    required this.marca,
    required this.modelo,
    required this.anio,
  });

  factory Vehiculo.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw StateError('Los datos del documento son nulos.');
    }

    DocumentReference? clienteRef = data['clienteReference'];

    if (clienteRef == null) {
      throw StateError('El campo clienteReference no está presente en el documento.');
    }

    return Vehiculo(
      clienteReference: clienteRef,
      matricula_vehiculo: data['matricula_vehiculo'] ?? '',
      marca: data['marca'] ?? '',
      modelo: data['modelo'] ?? '',
      anio: data['anio'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clienteReference': clienteReference,
      'matricula_vehiculo': matricula_vehiculo,
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
    };
  }
}
