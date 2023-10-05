import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/app_colors.dart'; // Importa el archivo app_colors.dart
import '../widgets/reusable_widget.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/app_colors.dart'; // Importa el archivo app_colors.dart
import '../widgets/reusable_widget.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  // ...
  List clientes = List.empty();
  String nom_cliente = "";
  String rut_cliente = "";
  @override
  void initState() {
    super.initState();
    clientes = ["Hello", "Hey There"];
  }

  createCliente() {
    // Firestore generará automáticamente un ID único para el cliente
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("clientes").doc();

    Map<String, String> clienteList = {
      "rut_cliente": rut_cliente,
      "nom_cliente": nom_cliente
    };

    documentReference
        .set(clienteList)
        .whenComplete(() => print("Data stored successfully"));
  }

  deleteCliente(String clienteId) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("clientes").doc(clienteId);

    documentReference
        .delete()
        .whenComplete(() => print("deleted successfully"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clientes'), // Cambia el título según tu aplicación
      ),
      drawer: AppDrawer(), // Usa el widget del Drawer aquí
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("clientes").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          } else if (snapshot.hasData || snapshot.data != null) {
            return Padding(
              padding: const EdgeInsets.all(25.0),
              child: Table(
                border: TableBorder.all(),
                children: [
                  TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'nom_cliente',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'rut_cliente',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...snapshot.data?.docs.map((documentSnapshot) {
                        final rutCliente = documentSnapshot["rut_cliente"] ?? "";
                        final nomCliente = documentSnapshot["nom_cliente"] ?? "";
                        return TableRow(
                          children: [
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(nomCliente),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(rutCliente),
                              ),
                            ),
                          ],
                        );
                      })?.toList() ??
                      [],
                ],
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.red,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  title: const Text("Add Cliente"),
                  content: Container(
                    width: 600,
                    height: 400,
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (String value) {
                            rut_cliente = value;
                          },
                          decoration: InputDecoration(
                            labelText: 'RUT del Cliente',
                          ),
                        ),
                        TextField(
                          onChanged: (String value) {
                            nom_cliente = value;
                          },
                          decoration: InputDecoration(
                            labelText: 'Nombre del Cliente',
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        setState(() {
                          createCliente();
                        });
                        Navigator.of(context).pop();
                      },
                      child: const Text("Add"),
                    )
                  ],
                );
              });
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
