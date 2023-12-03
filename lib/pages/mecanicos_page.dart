import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../models/cliente.dart';
import '../models/mecanico.dart';
import '../services/mecanicos_firestore.dart';
import '../widgets/app_colors.dart';
import '../widgets/reusable_widget.dart';
import '../services/clientes_firestore.dart';
import 'login_page.dart';
import 'dart:convert';

class MecanicosPage extends StatefulWidget {
  const MecanicosPage({Key? key});

  @override
  State<MecanicosPage> createState() => _MecanicosPageState();
}

class _MecanicosPageState extends State<MecanicosPage> {
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
        await FirebaseFirestore.instance.collection("mecanicos").get();
    setState(() {
      documentSnapshots = snapshot.docs; // Usar directamente los documentos
      filteredDocumentSnapshots = documentSnapshots;
    });
    print("Data fetched: ${documentSnapshots?.length} documents");
  }

  void filterMecanicos(String searchTerm) {
    setState(() {
      filteredDocumentSnapshots = documentSnapshots?.where((document) {
        final mecanico = Mecanico(
          id: document.id,
          rut_mecanico: document["rut_mecanico"] ?? "",
          nom_mecanico: document["nom_mecanico"] ?? "",
          ape_mecanico: document["ape_mecanico"] ?? "",
          email_mecanico: document["email_mecanico"] ?? "",
        );

        final searchTermLowerCase = searchTerm.toLowerCase();

        return mecanico.rut_mecanico
                .toLowerCase()
                .contains(searchTermLowerCase) ||
            mecanico.ape_mecanico.toLowerCase().contains(searchTermLowerCase) ||
            mecanico.ape_mecanico.toLowerCase().contains(searchTermLowerCase) ||
            mecanico.email_mecanico.toLowerCase().contains(searchTermLowerCase);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        title: Text('Mecanicos',
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
        imagePath: 'assets/images/fondo1.jpg',
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 60),
                child: busquedaMecanico(
                    searchController,
                    filterMecanicos,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("mecanicos")
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
                        return Mecanico.fromFirestore(document)
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
                      child: MecanicosDataTable(
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
                  return AgregarEditarMecanicoDialog();
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
    final mecanicosCollection =
        FirebaseFirestore.instance.collection("mecanicos");

    try {
      // Lee el archivo JSON
      final String jsonString = await rootBundle.loadString('mecanicos.json');
      final List<Map<String, dynamic>> listaMecanicos =
          List<Map<String, dynamic>>.from(json.decode(jsonString));

      // Itera a través de la lista de mecanicos y agrega cada uno al lote
      for (final mecanicoData in listaMecanicos) {
        final newMecanicoRef = mecanicosCollection.doc();
        batch.set(newMecanicoRef, mecanicoData);
      }

      await batch
          .commit(); // Ejecuta la operación de lote para agregar registros
      print("Se agregaron ${listaMecanicos.length} registros automáticamente.");
    } catch (e) {
      print("Error al agregar registros automáticamente: $e");
    }
  }
}
