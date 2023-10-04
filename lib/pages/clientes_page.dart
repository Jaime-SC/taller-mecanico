import 'package:flutter/material.dart';
import '../widgets/app_colors.dart'; // Importa el archivo app_colors.dart
import '../widgets/reusable_widget.dart';
import 'package:firebase_core/firebase_core.dart'; // Asegúrate de importar el paquete correcto

//import '../widgets/drawer_widget.dart'; // Importa el widget del Drawer

class ClientesPage extends StatefulWidget {
  const ClientesPage({Key? key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clientes'), // Cambia el título según tu aplicación
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
            'Contenido de la página de clientes',
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
