import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taller_mecanico/pages/home_page.dart';
import '../widgets/app_colors.dart';
import '../widgets/reusable_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();

  // Variables para controlar la visibilidad de la notificación personalizada
  bool _showCustomNotification = false;
  String _customNotificationMessage = "";
  Color? _customNotificationBackgroundColor;

  // Función para mostrar una notificación personalizada en el centro de la pantalla
void _showCustomNotificationMessage(String message, {Color? backgroundColor}) {
  setState(() {
    _customNotificationMessage = message;
    _customNotificationBackgroundColor = backgroundColor ?? Colors.green; // Usar verde como color predeterminado si no se proporciona uno
    _showCustomNotification = true;
    });

    // Ocultar la notificación después de unos segundos
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        _showCustomNotification = false;
      });
    });
  }

  // Función para mostrar una alerta de inicio de sesión exitoso
  void _showLoginSuccessAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Inicio de sesión exitoso"),
          content: Text("Direccionando a pagina home...."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra la alerta
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
            padding: EdgeInsets.fromLTRB(20,0,20,0,),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/logo1.png"),
                const SizedBox(
                  height: 5,
                ),
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
                    padding: const EdgeInsets.all(25),
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
                          FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                  email: _emailTextController.text,
                                  password: _passwordTextController.text)
                              .then((value) {
                            _showLoginSuccessAlert(); // Mostrar la alerta de inicio de sesión exitoso
                            // _showCustomNotificationMessage("Inicio de sesión exitoso");
                          }).onError((error, stackTrace) {
                            _showCustomNotificationMessage("Error al iniciar sesión. Verifica credenciales y vuelve a intentar.", backgroundColor: const Color.fromARGB(255, 227, 89, 79));
                          });
                        }),
                        opcionRegistro(context),
                      ],
                    ),
                  ),
                ),
                // Widget de notificación personalizada
                if (_showCustomNotification)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _customNotificationBackgroundColor,
                      borderRadius: BorderRadius.circular(10), // Bordes redondeados
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
        AppColors.colorBase,
      ),
    );
  }
}