import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/detalleOrdenTrabajo.dart';
import '../models/ordenTrabajo.dart';
import '../services/detalleOrdenTrabajo_firestore.dart';
import '../services/ordenTrabajo_firestore.dart';
import '../widgets/app_colors.dart';
import '../widgets/reusable_widget.dart';
import 'login_page.dart';

class DetallesOrdenesTrabajosPage extends StatefulWidget {
  const DetallesOrdenesTrabajosPage({Key? key});

  @override
  State<DetallesOrdenesTrabajosPage> createState() =>
      _DetallesOrdenesTrabajosPageState();
}

class _DetallesOrdenesTrabajosPageState
    extends State<DetallesOrdenesTrabajosPage> {
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
        .collection("detallesOrdenesTrabajos")
        .orderBy("id_ord_trabajo")
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

  void filterDetallesOrdenesTrabajos(String searchTerm) {
    setState(() {
      filteredDocumentSnapshots = documentSnapshots?.where((document) {
        final detalleOrdenTrabajo = DetalleOrdenTrabajo(
          idOrdTrabajoReference: document['idOrdTrabajoReference'],
          idServicioReference: document['idServicioReference'],
          rutMecanicoReference: document['rutMecanicoReference'],
          fecha_inicio: document['fecha_inicio'] as Timestamp,
          fecha_termino: document['fecha_termino'] as Timestamp,
          estado: document['estado'] ?? '',
          costo: document['costo'] ?? 0,
        );

        final searchTermLowerCase = searchTerm.toLowerCase();

        return detalleOrdenTrabajo.fecha_inicio
                .toString()
                .contains(searchTermLowerCase) ||
            detalleOrdenTrabajo.fecha_termino
                .toString()
                .contains(searchTermLowerCase) ||
            detalleOrdenTrabajo.estado
                .toLowerCase()
                .contains(searchTermLowerCase);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xff008452),
        title: Text('Detalles OrdenesTrabajos',
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
                  child: busquedaOrdenTrabajo(
                    searchController,
                    filterDetallesOrdenesTrabajos,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("detallesOrdenesTrabajos")
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
                          final detalleOrdenTrabajo =
                              DetalleOrdenTrabajo.fromFirestore(document);

                          final searchTermLowerCase =
                              searchController.text.toLowerCase();

                          return detalleOrdenTrabajo.idOrdTrabajoReference.id
                                  .toLowerCase()
                                  .contains(searchTermLowerCase) ||
                              detalleOrdenTrabajo.idServicioReference.id
                                  .toLowerCase()
                                  .contains(searchTermLowerCase) ||
                              detalleOrdenTrabajo.rutMecanicoReference.id
                                  .toLowerCase()
                                  .contains(searchTermLowerCase) ||
                              detalleOrdenTrabajo.fecha_inicio
                                  .toString()
                                  .contains(searchTermLowerCase) ||
                              detalleOrdenTrabajo.fecha_termino
                                  .toString()
                                  .contains(searchTermLowerCase) ||
                              detalleOrdenTrabajo.estado
                                  .toLowerCase()
                                  .contains(searchTermLowerCase);
                        }).toList();
                      }

                      return Center(
                        child: DetallesOrdenesTrabajosDataTable(
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'unique_hero_tag_for_floating_button',
        backgroundColor: Color(0XFF004B85),
        foregroundColor: Colors.white,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AgregarEditarDetalleOrdenTrabajoDialog();
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
