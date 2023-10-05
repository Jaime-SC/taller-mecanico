import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clientes'),
      ),
      drawer: AppDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("clientes").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          } else if (snapshot.hasData || snapshot.data != null) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.colorBase,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    Center(
                      child: ClientesDataTable(
                        documentSnapshots: snapshot.data?.docs,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return Center(
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
          // Mostrar el diálogo para agregar un nuevo cliente.
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
