import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../models/vehiculo.dart';
import '../widgets/app_colors.dart';
import '../widgets/reusable_widget.dart';
import '../services/vehiculos_firestore.dart';
import 'login_page.dart';
import 'dart:convert';

class VehiculosPage extends StatefulWidget {
  const VehiculosPage({Key? key});

  

  @override
  State<VehiculosPage> createState() => _VehiculosPageState();
}

class _VehiculosPageState extends State<VehiculosPage> {
  late TextEditingController searchController;
  List<QueryDocumentSnapshot>? documentSnapshots;
  List<QueryDocumentSnapshot>? filteredDocumentSnapshots;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    documentSnapshots = [];
    filteredDocumentSnapshots = [];
    fetchData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void fetchData() async {
    final snapshot =
        await FirebaseFirestore.instance.collection("vehiculos").get();
    setState(() {
      documentSnapshots = snapshot.docs;
      filteredDocumentSnapshots = snapshot.docs;
    });
  }

  void filterVehiculos(String searchTerm) {
    setState(() {
      filteredDocumentSnapshots = documentSnapshots?.where((document) {
        final vehiculo = Vehiculo(
          matricula_vehiculo: document["matricula_vehiculo"] ?? "",
          rut_cliente: document["rut_cliente"] ?? "",
          marca: document["marca"] ?? "",
          modelo: document["modelo"] ?? "",
          anio: document["anio"] ?? "",
          
        );

        final searchTermLowerCase = searchTerm.toLowerCase();

        return vehiculo.matricula_vehiculo.toLowerCase().contains(searchTermLowerCase) ||
            vehiculo.rut_cliente.toLowerCase().contains(searchTermLowerCase) ||
            vehiculo.marca.toLowerCase().contains(searchTermLowerCase) ||
            vehiculo.modelo.toLowerCase().contains(searchTermLowerCase) ||
            vehiculo.anio.toLowerCase().contains(searchTermLowerCase);
            
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xff008452),
        title: Text('Vehiculos', style: TextStyle(fontFamily: 'SpaceMonoNerdFont')),
      ),
      drawer: AppDrawer(
        onSignOut: () async {
          try {
            await FirebaseAuth.instance
                .signOut(); // Cierra la sesión de Firebase
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    LoginPage(), // Redirige a la página de inicio de sesión
              ),
            );
          } catch (e) {
            print("Error al cerrar sesión: $e"); // Maneja errores si los hay
          }
        },
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.colorClientePage,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            // Envuelve la columna con SingleChildScrollView
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  child: busquedaVehiculo(
                    searchController,
                    filterVehiculos,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("vehiculos")
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      final documentSnapshots = snapshot.data?.docs;
                      List<QueryDocumentSnapshot>? filteredData =
                          documentSnapshots;

                      // Aplicar filtro si hay un término de búsqueda
                      if (searchController.text.isNotEmpty) {
                        filteredData = documentSnapshots?.where((document) {
                          final vehiculo = Vehiculo(
                            matricula_vehiculo: document["matricula_vehiculo"] ?? "",
                            rut_cliente: document["rut_cliente"] ?? "",
                            marca: document["marca"] ?? "",
                            modelo: document["modelo"] ?? "",
                            anio: document["anio"] ?? "",
                            
                          );

                          final searchTermLowerCase =
                              searchController.text.toLowerCase();

                          return vehiculo.matricula_vehiculo
                                  .toLowerCase()
                                  .contains(searchTermLowerCase) ||
                              vehiculo.rut_cliente
                                  .toLowerCase()
                                  .contains(searchTermLowerCase) ||
                              vehiculo.marca
                                  .toLowerCase()
                                  .contains(searchTermLowerCase) ||
                              vehiculo.modelo
                                  .toLowerCase()
                                  .contains(searchTermLowerCase) ||
                              vehiculo.anio
                                  .toLowerCase()
                                  .contains(searchTermLowerCase);
                        }).toList();
                      }

                      return Center(
                        child: VehiculosDataTable(
                          documentSnapshots: filteredData,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'unique_hero_tag_for_floating_button',
            backgroundColor: Color(0XFF004B85),
            foregroundColor: Colors.white,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AgregarEditarVehiculoDialog();
                },
              );
            },
            child: Icon(Icons.add),
          ),
          SizedBox(width: 16), // Espacio entre los botones
          FloatingActionButton(
            backgroundColor: Color(0XFF004B85),
            foregroundColor: Colors.white,
            onPressed: () {
              // Llama a la función para agregar registros automáticamente
              agregarRegistrosAutomaticos();
            },
            child: Icon(Icons.add_box),
          ),
        ],
      ),
    );
  }

  void agregarRegistrosAutomaticos() async {
    final batch = FirebaseFirestore.instance.batch();
    final vehiculosCollection =
        FirebaseFirestore.instance.collection("vehiculos");

    try {
      // Lee el archivo JSON
      final String jsonString =
          await rootBundle.loadString('vehiculos.json');
      final List<Map<String, dynamic>> listaVehiculos =
          List<Map<String, dynamic>>.from(json.decode(jsonString));

      // Itera a través de la lista de Vehiculos y agrega cada uno al lote
      for (final vehiculoData in listaVehiculos) {
        final newVehiculoRef = vehiculosCollection.doc();
        batch.set(newVehiculoRef, vehiculoData);
      }

      await batch
          .commit(); // Ejecuta la operación de lote para agregar registros
      print("Se agregaron ${listaVehiculos.length} registros automáticamente.");
    } catch (e) {
      print("Error al agregar registros automáticamente: $e");
    }
  }
}
