import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taller_mecanico/pages/home_page.dart';
import '../widgets/app_colors.dart'; // Importa el archivo app_colors.dart
import '../widgets/reusable_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          "Registrarse",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors
                .colorBase, // Usa la lista de colores desde app_colors.dart
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5), // Color de la sombra
                    spreadRadius: 1.25, // Cuánto se extiende la sombra
                    blurRadius: 7, // Cuánto se difumina la sombra
                    offset: Offset(
                        0, 3), // Offset de la sombra (horizontal, vertical)
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(50),
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField(
                      "Nombre de Usuario",
                      Icons.person_outline,
                      false,
                      _userNameTextController,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField(
                      "Email",
                      Icons.person_outline,
                      false,
                      _emailTextController,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField(
                      "Contraseña",
                      Icons.lock_outlined,
                      true,
                      _passwordTextController,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    loginButton(context, true,  () {
                          FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: _emailTextController.text,
                                  password: _passwordTextController.text)
                              .then((value) {
                                print("Nueva Cuenta Creada");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            ).onError((error, stackTrace) {
                              print("Error ${error.toString()}");
                            });
                          });
                        }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
