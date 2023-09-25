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
    return Scaffold(
      body: buildGradientContainer(
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              //MediaQuery.of(context).size.height * 0.2,
              20,
              0,
            ),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/logo1.png"),
                const SizedBox(
                  height: 30,
                ),
                Container(
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
                        loginButton(context, true, true, () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()));
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
        AppColors.colorBase, // Utiliza la lista de colores desde app_colors.dart
      ),
    );
  }
}
