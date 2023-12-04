import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehiculo.dart';
import '../widgets/app_colors.dart';
import '../widgets/reusable_widget.dart';
import '../services/vehiculos_firestore.dart';
import 'login_page.dart';


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
    // Define la cantidad de documentos a recuperar por página
    final int pageSize = 10;

    // Inicializa la consulta para obtener la primera página
    Query query = FirebaseFirestore.instance
        .collection("vehiculos")
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

  void filterVehiculos(String searchTerm) {
    setState(() {
      filteredDocumentSnapshots = documentSnapshots?.where((document) {
        final vehiculo = Vehiculo(
          matricula_vehiculo: document["matricula_vehiculo"] ?? "",
          clienteReference: document["clienteReference"] ?? "",
          marca: document["marca"] ?? "",
          modelo: document["modelo"] ?? "",
          anio: document["anio"] ?? "",
        );

        final searchTermLowerCase = searchTerm.toLowerCase();

        return vehiculo.matricula_vehiculo
                .toLowerCase()
                .contains(searchTermLowerCase) ||
            vehiculo.clienteReference
                .toString()
                .contains(searchTermLowerCase) ||
            vehiculo.marca.toLowerCase().contains(searchTermLowerCase) ||
            vehiculo.modelo.toLowerCase().contains(searchTermLowerCase) ||
            vehiculo.anio.toLowerCase().contains(searchTermLowerCase);
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
        title: Text('Vehiculos',
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
        imagePath: 'assets/images/fondo4.jpg',
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 60),
                child: busquedaCliente(
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
                        documentSnapshots;// Aplicar filtro si hay un término de búsqueda
                    if (searchController.text.isNotEmpty) {
                      filteredData = documentSnapshots?.where((document) {
                        final vehiculo = Vehiculo.fromFirestore(
                            document); // Utiliza el constructor adecuado
                        final searchTermLowerCase =
                            searchController.text.toLowerCase();
                        return vehiculo.matricula_vehiculo
                                .toLowerCase()
                                .contains(searchTermLowerCase) ||
                            vehiculo.clienteReference.id
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
      ),
      floatingActionButton: FloatingActionButton(
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
    );
  }
}
