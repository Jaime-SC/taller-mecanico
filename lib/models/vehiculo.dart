// vehiculo.dart
class Vehiculo {
  final String matricula_vehiculo;
  final String rut_cliente;
  final String marca;
  final String modelo;
  final String anio;
  // Agrega otras propiedades necesarias para un vehículo

  Vehiculo({
    required this.rut_cliente,
    required this.matricula_vehiculo,
    required this.marca,
    required this.modelo,
    required this.anio,    
    // Incluye otras propiedades del vehículo
  });

  Map<String, dynamic> toJson() {
    return {
      'rut_cliente': rut_cliente,
      'matricula_vehiculo': matricula_vehiculo,
      'marca': marca,
      'modelo': modelo,
      'anio': anio,

      // ... otras propiedades del vehículo
    };
  }

  
}
