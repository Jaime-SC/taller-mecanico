import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../models/servicio.dart';
import '../services/servicio_firestore.dart';
import '../widgets/app_colors.dart';
import '../widgets/reusable_widget.dart';

import 'login_page.dart';
import 'dart:convert';

class ServiciosPage extends StatefulWidget {
  const ServiciosPage({Key? key});

  @override
  State<ServiciosPage> createState() => _ServiciosPageState();
}

class _ServiciosPageState extends State<ServiciosPage> {
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
    print("Fetching data...");
    final snapshot =
        await FirebaseFirestore.instance.collection("servicios").get();
    setState(() {
      documentSnapshots = snapshot.docs; // Usar directamente los documentos
      filteredDocumentSnapshots = documentSnapshots;
    });
    print("Data fetched: ${documentSnapshots?.length} documents");
  }

  void filterServicios(String searchTerm) {
    setState(() {
      filteredDocumentSnapshots = documentSnapshots?.where((document) {
        final servicio = Servicio(
          id_servicio: document["id_servicio"] ?? "",
          descripcion: document["descripcion"] ?? "",
          costo: document["costo"] ?? "",
        );

        final searchTermLowerCase = searchTerm.toLowerCase();

        return servicio.id_servicio.toLowerCase().contains(searchTermLowerCase) ||
            servicio.descripcion.toLowerCase().contains(searchTermLowerCase) ||
            servicio.costo
                .toString()
                .toLowerCase()
                .contains(searchTermLowerCase);
        // Convert costo to String before calling toLowerCase
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        title: Text('Servicios',
            style: TextStyle(fontFamily: 'SpaceMonoNerdFont')),
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
      body: BackgroundImage(
        imagePath: 'assets/images/fondo5.png',
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 60),
                child: busquedaServicio(
                  searchController,
                  filterServicios,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("servicios")
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
                        return Servicio.fromFirestore(document)
                            .toJson()
                            .values
                            .any((value) => value
                                .toString()
                                .toLowerCase()
                                .contains(
                                    searchController.text.toLowerCase()));
                      }).toList();
                    }
                    return Center(
                      child: ServicioDataTable(
                        documentSnapshots: filteredData,
                      ),
                    );
                  },
                ),
              ),            
            ],
          ),
        ),
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
                  return AgregarEditarServicioDialog();
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
    final serviciosCollection =
        FirebaseFirestore.instance.collection("servicios");

    try {
      // Lee el archivo JSON
      final String jsonString = await rootBundle.loadString('servicios.json');
      final List<Map<String, dynamic>> listaServicios =
          List<Map<String, dynamic>>.from(json.decode(jsonString));

      // Itera a través de la lista de servicios y agrega cada uno al lote
      for (final servicioData in listaServicios) {
        final newServicioRef = serviciosCollection.doc();
        batch.set(newServicioRef, servicioData);
      }

      await batch
          .commit(); // Ejecuta la operación de lote para agregar registros
      print("Se agregaron ${listaServicios.length} registros automáticamente.");
    } catch (e) {
      print("Error al agregar registros automáticamente: $e");
    }
  }
}
