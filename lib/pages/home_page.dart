import 'package:flutter/material.dart';
import '../widgets/app_colors.dart'; // Importa el archivo app_colors.dart
import '../widgets/reusable_widget.dart';
//import 'drawer_widget.dart'; // Importa el widget del Drawer

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Aplicación'), // Cambia el título según tu aplicación
        backgroundColor: Color(0xff004B85),
        foregroundColor: Colors.white,
      ),
      drawer: AppDrawer(), // Usa el widget del Drawer aquí
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
        child: Center(
          child: Text(
            'Contenido de la página principal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
