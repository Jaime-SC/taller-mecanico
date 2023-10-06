import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cliente.dart';
import '../widgets/app_colors.dart';
import '../widgets/reusable_widget.dart';
import '../services/clientes_firestore.dart';

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
      drawer: AppDrawer(),
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
              Expanded(
                child: Column(
                  children: [
                    busquedaCliente(),
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Center(
                        child: ClientesDataTable(
                          documentSnapshots: filteredDocumentSnapshots,
                        ),
                      ),
                    ),
                  ],
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

  Container busquedaCliente() {
    return Container(
      width: 500, // Usar todo el ancho disponible
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        cursorColor: Color(0XFFD60019),
        controller: searchController,
        onChanged: filterClientes,
        decoration: InputDecoration(
          hintText: 'Buscar clientes',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
