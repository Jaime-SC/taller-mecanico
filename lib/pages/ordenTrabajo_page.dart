import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../models/ordenTrabajo.dart';
import '../models/vehiculo.dart';
import '../services/ordenTrabajo_firestore.dart';
import '../widgets/app_colors.dart';
import '../widgets/reusable_widget.dart';
import '../services/vehiculos_firestore.dart';
import 'login_page.dart';
import 'dart:convert';

class OrdenesTrabajosPage extends StatefulWidget {
  const OrdenesTrabajosPage({Key? key});

  @override
  State<OrdenesTrabajosPage> createState() => _OrdenesTrabajosPageState();
}

class _OrdenesTrabajosPageState extends State<OrdenesTrabajosPage> {
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
    // Define la cantidad de documentos a recuperar por página
    final int pageSize = 10;

    // Inicializa la consulta para obtener la primera página
    Query query = FirebaseFirestore.instance
        .collection("ordenesTrabajos")
        .orderBy("matricula_vehiculo")
        .limit(pageSize);

    // Si ya hay documentos cargados, ajusta la consulta para comenzar después del último documento cargado
    if (documentSnapshots != null && documentSnapshots!.isNotEmpty) {
      query = query.startAfter([documentSnapshots!.last]);
    }

    final snapshot = await query.get();

    setState(() {
      documentSnapshots = snapshot.docs;
      filteredDocumentSnapshots = snapshot.docs;
    });
  }

  void filterOrdenesTrabajos(String searchTerm) {
    setState(() {
      filteredDocumentSnapshots = documentSnapshots?.where((document) {
        final ordenTrabajo = OrdenTrabajo(
          //id_ord_trabajo: document["id_ord_trabajo"] ?? "",
          rutReference: document["rutReference"],
          matriculaVehiculoReference: document["matriculaVehiculoReference"],
          fecha_inicio: document["fecha_inicio"] ?? "",
          fecha_termino: document["fecha_termino"] ?? "",
          estado: document["estado"] ?? "",
        );

        final searchTermLowerCase = searchTerm.toLowerCase();

        return ordenTrabajo.rutReference
                .toString()
                .contains(searchTermLowerCase) ||
            ordenTrabajo.matriculaVehiculoReference
                .toString()
                .contains(searchTermLowerCase) ||
            ordenTrabajo.fecha_inicio
                .toString()
                .contains(searchTermLowerCase) ||
            ordenTrabajo.fecha_termino
                .toString()
                .contains(searchTermLowerCase) ||
            ordenTrabajo.estado.toLowerCase().contains(searchTermLowerCase);
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
        title: Text('OrdenesTrabajos',
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
        imagePath: 'assets/images/fondo.jpg',
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 60),
                child: busquedaOrdenTrabajo(
                  searchController,
                  filterOrdenesTrabajos,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("ordenesTrabajos")
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
                        documentSnapshots;// Aplicar filtro si hay un término de búsqueda
                    if (searchController.text.isNotEmpty) {
                      filteredData = documentSnapshots?.where((document) {
                        final ordenTrabajo = OrdenTrabajo.fromFirestore(
                            document); // Utiliza el constructor adecuado
                        final searchTermLowerCase =
                            searchController.text.toLowerCase();
                        return ordenTrabajo.rutReference.id
                                .toLowerCase()
                                .contains(searchTermLowerCase) ||
                            ordenTrabajo.matriculaVehiculoReference.id
                                .toLowerCase()
                                .contains(searchTermLowerCase) ||
                            ordenTrabajo.fecha_inicio
                                .toString()
                                .contains(searchTermLowerCase) ||
                            ordenTrabajo.fecha_termino
                                .toString()
                                .contains(searchTermLowerCase) ||
                            ordenTrabajo.estado
                                .toLowerCase()
                                .contains(searchTermLowerCase);
                      }).toList();
                    }
                    return Center(
                      child: OrdenesTrabajosDataTable(
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'unique_hero_tag_for_floating_button',
        backgroundColor: Color(0XFF004B85),
        foregroundColor: Colors.white,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AgregarEditarOrdenTrabajoDialog();
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
