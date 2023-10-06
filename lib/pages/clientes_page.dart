import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cliente.dart';
import '../widgets/app_colors.dart';
import '../widgets/reusable_widget.dart';
import '../services/clientes_firestore.dart';
import 'login_page.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
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
        await FirebaseFirestore.instance.collection("clientes").get();
    setState(() {
      documentSnapshots = snapshot.docs;
      filteredDocumentSnapshots = snapshot.docs;
    });
  }

  void filterClientes(String searchTerm) {
    setState(() {
      filteredDocumentSnapshots = documentSnapshots?.where((document) {
        final cliente = Cliente(
          rut: document["rut_cliente"] ?? "",
          nombre: document["nom_cliente"] ?? "",
          apellido: document["ape_cliente"] ?? "",
          direccion: document["dir_cliente"] ?? "",
          telefono: document["tel_cliente"] ?? "",
          email: document["email_cliente"] ?? "",
        );

        final searchTermLowerCase = searchTerm.toLowerCase();

        return cliente.rut.toLowerCase().contains(searchTermLowerCase) ||
            cliente.nombre.toLowerCase().contains(searchTermLowerCase) ||
            cliente.apellido.toLowerCase().contains(searchTermLowerCase) ||
            cliente.direccion.toLowerCase().contains(searchTermLowerCase) ||
            cliente.telefono.toLowerCase().contains(searchTermLowerCase) ||
            cliente.email.toLowerCase().contains(searchTermLowerCase);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xff008452),
        title: Text('Clientes'),
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
          Column(
            children: [
              Container(
                alignment: Alignment.topCenter,
                child: busquedaCliente(
                  searchController,
                  filterClientes,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("clientes")
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
                        final cliente = Cliente(
                          rut: document["rut_cliente"] ?? "",
                          nombre: document["nom_cliente"] ?? "",
                          apellido: document["ape_cliente"] ?? "",
                          direccion: document["dir_cliente"] ?? "",
                          telefono: document["tel_cliente"] ?? "",
                          email: document["email_cliente"] ?? "",
                        );

                        final searchTermLowerCase =
                            searchController.text.toLowerCase();

                        return cliente.rut
                                .toLowerCase()
                                .contains(searchTermLowerCase) ||
                            cliente.nombre
                                .toLowerCase()
                                .contains(searchTermLowerCase) ||
                            cliente.apellido
                                .toLowerCase()
                                .contains(searchTermLowerCase) ||
                            cliente.direccion
                                .toLowerCase()
                                .contains(searchTermLowerCase) ||
                            cliente.telefono
                                .toLowerCase()
                                .contains(searchTermLowerCase) ||
                            cliente.email
                                .toLowerCase()
                                .contains(searchTermLowerCase);
                      }).toList();
                    }

                    return Center(
                      child: ClientesDataTable(
                        documentSnapshots: filteredData,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0XFF004B85),
        foregroundColor: Colors.white,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AgregarEditarClienteDialog();
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
