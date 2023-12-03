import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../models/factura.dart';
import '../models/vehiculo.dart';
import '../services/facturas_firestore.dart';
import '../widgets/app_colors.dart';
import '../widgets/reusable_widget.dart';
import '../services/vehiculos_firestore.dart';
import 'login_page.dart';
import 'dart:convert';

class FacturasPage extends StatefulWidget {
  const FacturasPage({Key? key});

  @override
  State<FacturasPage> createState() => _FacturasPageState();
}

class _FacturasPageState extends State<FacturasPage> {
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
        .collection("facturas")
        .orderBy("matricula_factura")
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

  void filterFacturas(String searchTerm) {
    setState(() {
      filteredDocumentSnapshots = documentSnapshots?.where((document) {
        final factura = Factura(
          id_factura: document["id_factura"] ?? "",
          idOrdTrabajoReference: document["idOrdTrabajoReference"] ?? "",
          fecha_factura: document["fecha_factura"] as Timestamp,
          total: document["total"] ?? 0,
          estado: document["estado"] ?? "",
        );

        final searchTermLowerCase = searchTerm.toLowerCase();

        return factura.id_factura.toLowerCase().contains(searchTermLowerCase) ||
            factura.idOrdTrabajoReference
                .toString()
                .contains(searchTermLowerCase) ||
            factura.fecha_factura
                .toDate()
                .toString()
                .contains(searchTermLowerCase) ||
            factura.total.toString().contains(searchTermLowerCase) ||
            factura.estado.toLowerCase().contains(searchTermLowerCase);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xff008452),
        title:
            Text('Facturas', style: TextStyle(fontFamily: 'SpaceMonoNerdFont')),
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
                  child: busquedaFactura(
                    searchController,
                    filterFacturas,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("facturas")
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
                          final factura = Factura.fromFirestore(document);

                          final searchTermLowerCase =
                              searchController.text.toLowerCase();

                          return factura.id_factura
                                  .toLowerCase()
                                  .contains(searchTermLowerCase) ||
                              factura.idOrdTrabajoReference.id
                                  .contains(searchTermLowerCase) ||
                              factura.fecha_factura
                                  .toDate()
                                  .toString()
                                  .contains(searchTermLowerCase) ||
                              factura.total
                                  .toString()
                                  .contains(searchTermLowerCase) ||
                              factura.estado
                                  .toLowerCase()
                                  .contains(searchTermLowerCase);
                        }).toList();
                      }

                      return Center(
                        child: FacturasDataTable(
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
              return AgregarEditarFacturaDialog();
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
