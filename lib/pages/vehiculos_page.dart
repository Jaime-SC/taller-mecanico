import 'package:flutter/material.dart';
import '../widgets/app_colors.dart'; // Importa el archivo app_colors.dart
import '../widgets/reusable_widget.dart';
//import '../widgets/drawer_widget.dart'; // Importa el widget del Drawer

class VehiculosPage extends StatefulWidget {
  const VehiculosPage({Key? key});

  @override
  State<VehiculosPage> createState() => _VehiculosPageState();
}

class _VehiculosPageState extends State<VehiculosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehículos', style: TextStyle(fontFamily: 'SpaceMonoNerdFont')), // Cambia el título según tu aplicación
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
            'Contenido de la página de vehículos',
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
