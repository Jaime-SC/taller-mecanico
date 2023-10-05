import 'dart:convert';
import 'package:flutter/services.dart';

Future<List<Map<String, dynamic>>> loadClientesData() async {
  try {
    final String jsonString = await rootBundle.loadString('assets/clientes.json');
    final List<Map<String, dynamic>> jsonData = json.decode(jsonString).cast<Map<String, dynamic>>();
    return jsonData;
  } catch (e) {
    throw Exception('Error al cargar datos desde JSON: $e');
  }
}
