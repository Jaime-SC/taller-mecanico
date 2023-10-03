import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taller_mecanico/pages/login_page.dart';
import '../widgets/app_colors.dart'; // Importa el archivo app_colors.dart

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.colorBase, // Usa la lista de colores de HomePage
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.black26;
                  }
                  return Color(0xFF004B85);
                }),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)))),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                print("Sesion Cerrada");
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );  
              });


              
            },
            child: Text("Cerrar Sesión", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)) ,
          ),
        ),
      ),
    );
  }
}
