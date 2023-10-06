import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taller_mecanico/pages/home_page.dart';
import '../widgets/app_colors.dart'; // Importa el archivo app_colors.dart
import '../widgets/reusable_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: buildGradientContainer(
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              screenWidth > 600 ? 100 : 20, 
              0,
              screenWidth > 600 ? 100 : 20, // Ancho personalizado para pantallas más grandes
              0,
            ),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/logo1.png"),
                const SizedBox(
                  height: 2,
                ),
                Container(
                  width: screenWidth > 600 ? 600 : null,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(0.5), // Color de la sombra
                        spreadRadius: 1.25, // Cuánto se extiende la sombra
                        blurRadius: 7, // Cuánto se difumina la sombra
                        offset: Offset(
                            0, 3), // Offset de la sombra (horizontal, vertical)
                      ),
                    ],
                  ),
                  child: Padding(
                    padding:  EdgeInsets.all(screenWidth > 600 ? 50 : 20), 
                    child: Column(
                      children: [
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
                          Icons.lock_outline,
                          true,
                          _passwordTextController,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        loginButton(context, true,  () {
                          FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                  email: _emailTextController.text,
                                  password: _passwordTextController.text)
                              .then((value) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()));
                          }).onError((error, stackTrace) {
                            print("Error ${error.toString()}");
                          });
                        }),
                        opcionRegistro(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AppColors
            .colorBase, // Utiliza la lista de colores desde app_colors.dart
      ),
    );
  }
}