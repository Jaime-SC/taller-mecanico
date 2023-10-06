import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taller_mecanico/pages/home_page.dart';
import '../widgets/app_colors.dart';
import '../widgets/reusable_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();

  bool _showCustomNotification = false;
  String _customNotificationMessage = "";
  Color? _customNotificationBackgroundColor;

  void _showCustomNotificationMessage(String message, {Color? backgroundColor}) {
    setState(() {
      _customNotificationMessage = message;
      _customNotificationBackgroundColor =
          backgroundColor ?? const Color.fromARGB(255, 227, 89, 79);
      _showCustomNotification = true;
    });

    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        _showCustomNotification = false;
      });
    });
  }

  void _showLoginSuccessAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Inicio de sesión exitoso"),
          content: Text("Direccionando a página home...."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
              },
              child: Text("Continuar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildGradientContainer(
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/logo1.png"),
                SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 1.25,
                        blurRadius: 7,
                        offset: Offset(0, 3),
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
                        SizedBox(height: 20),
                        reusableTextField(
                          "Contraseña",
                          Icons.lock_outline,
                          true,
                          _passwordTextController,
                        ),
                        SizedBox(height: 20),
                        loginButton(context, true, () {
                          FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                email: _emailTextController.text,
                                password: _passwordTextController.text,
                              )
                              .then((value) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            );
                          }).onError((error, stackTrace) {
                            _showCustomNotificationMessage(
                              "Error al iniciar sesión. Verifica credenciales y vuelve a intentar.",
                            );
                          });
                        }),
                        opcionRegistro(context),
                        if (_showCustomNotification)
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: _customNotificationBackgroundColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Text(
                              _customNotificationMessage,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AppColors.colorBase,
      ),
    );
  }
}
