import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/app_colors.dart';
import '../widgets/reusable_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int clientCount = 0;

  @override
  void initState() {
    super.initState();
    getClientCount();
  }

  void getClientCount() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("clientes").get();

    setState(() {
      clientCount = snapshot.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Inicio', style: TextStyle(fontFamily: 'SpaceMonoNerdFont')),
        backgroundColor: Color(0xff004B85),
        foregroundColor: Colors.white,
      ),
      drawer: AppDrawer(),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.colorBase,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Alinea las tarjetas en el centro
              children: [
                Card(
                  elevation: 5,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Text(
                          'Clientes Registrados',
                          style: TextStyle(
                            fontFamily: 'SpaceMonoNerdFont',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '$clientCount',
                          style: TextStyle(
                              fontSize: 75, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                // Agrega dos tarjetas adicionales aquí
                Card(
                  elevation: 5,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Text(
                          'Vehiculos en Taller',
                          style: TextStyle(
                            fontFamily: 'SpaceMonoNerdFont',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '-',
                          style: TextStyle(
                              fontSize: 75, fontWeight: FontWeight.bold),
                        ),
                        // Contenido de la segunda tarjeta
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 5,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Text(
                          'Trabajos terminados por Semana',
                          style: TextStyle(
                            fontFamily: 'SpaceMonoNerdFont',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '-',
                          style: TextStyle(
                              fontSize: 75, fontWeight: FontWeight.bold),
                        ),
                        // Contenido de la tercera tarjeta
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
