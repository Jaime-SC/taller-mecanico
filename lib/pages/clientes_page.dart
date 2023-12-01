import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../models/cliente.dart';
import '../widgets/app_colors.dart';
import '../widgets/reusable_widget.dart';
import '../services/clientes_firestore.dart';
import 'login_page.dart';
import 'dart:convert';

class ClientesPage extends StatefulWidget {
  const ClientesPage({Key? key});

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
    print("Fetching data...");
    final snapshot =
        await FirebaseFirestore.instance.collection("clientes").get();
    setState(() {
      documentSnapshots = snapshot.docs; // Usar directamente los documentos
      filteredDocumentSnapshots = documentSnapshots;
    });
    print("Data fetched: ${documentSnapshots?.length} documents");
  }

  void filterClientes(String searchTerm) {
    setState(() {
      filteredDocumentSnapshots = documentSnapshots?.where((document) {
        final cliente = Cliente(
          id: document.id,
          rut_cliente: document["rut_cliente"] ?? "",
          nom_cliente: document["nom_cliente"] ?? "",
          ape_cliente: document["ape_cliente"] ?? "",
          dir_cliente: document["dir_cliente"] ?? "",
          tel_cliente: document["tel_cliente"] ?? "",
          email_cliente: document["email_cliente"] ?? "",
        );

        final searchTermLowerCase = searchTerm.toLowerCase();

        return cliente.rut_cliente
                .toLowerCase()
                .contains(searchTermLowerCase) ||
            cliente.nom_cliente.toLowerCase().contains(searchTermLowerCase) ||
            cliente.ape_cliente.toLowerCase().contains(searchTermLowerCase) ||
            cliente.dir_cliente.toLowerCase().contains(searchTermLowerCase) ||
            cliente.tel_cliente.toLowerCase().contains(searchTermLowerCase) ||
            cliente.email_cliente.toLowerCase().contains(searchTermLowerCase);
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
            Text('Clientes', style: TextStyle(fontFamily: 'SpaceMonoNerdFont')),
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
                          return Cliente.fromFirestore(document)
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
                        child: ClientesDataTable(
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
                  return AgregarEditarClienteDialog();
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
    final clientesCollection =
        FirebaseFirestore.instance.collection("clientes");

    try {
      // Lee el archivo JSON
      final String jsonString = await rootBundle.loadString('clientes.json');
      final List<Map<String, dynamic>> listaClientes =
          List<Map<String, dynamic>>.from(json.decode(jsonString));

      // Itera a través de la lista de clientes y agrega cada uno al lote
      for (final clienteData in listaClientes) {
        final newClienteRef = clientesCollection.doc();
        batch.set(newClienteRef, clienteData);
      }

      await batch
          .commit(); // Ejecuta la operación de lote para agregar registros
      print("Se agregaron ${listaClientes.length} registros automáticamente.");
    } catch (e) {
      print("Error al agregar registros automáticamente: $e");
    }
  }
}
