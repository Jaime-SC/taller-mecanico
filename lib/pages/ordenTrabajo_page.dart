import 'package:flutter/material.dart';
import '../widgets/app_colors.dart'; // Importa el archivo app_colors.dart
import '../widgets/reusable_widget.dart';
//import '../widgets/drawer_widget.dart'; // Importa el widget del Drawer

class OrdenTrabajoPage extends StatefulWidget {
  const OrdenTrabajoPage({Key? key});

  @override
  State<OrdenTrabajoPage> createState() => _OrdenTrabajoPageState();
}

class _OrdenTrabajoPageState extends State<OrdenTrabajoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orden de Trabajo'), // Cambia el título según tu aplicación
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
            'Contenido de la página de Orden de Trabajo',
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
