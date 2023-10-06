import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/clientes_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/ordenTrabajo_page.dart';
import '../pages/register_page.dart';
import '../pages/vehiculos_page.dart';
import 'app_colors.dart';

// Widget para mostrar una imagen con color personalizado
Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 340,
    height: 340,
    color: Colors.white,
  );
}

Image logoDrawer(String imageName) {
  return Image.asset(
    imageName,
    color: Colors.white,
  );
}

// Widget del menú de navegación
class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xff004B85),
            ),
            child: InkWell(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: logoDrawer("assets/images/logo1.png"),
            ),
          ),

          ListTile(
            title: Text('Clientes'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ClientesPage(
                          title: 'Clientes',
                        )),
              );
            },
          ),
          ListTile(
            title: Text('Vehículos'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VehiculosPage()),
              );
            },
          ),
          ListTile(
            title: Text('Orden de Trabajo'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrdenTrabajoPage()),
              );
            },
          ),
          ListTile(
            title: Text('Cerrar Sesión'),
            onTap: () {
              FirebaseAuth.instance.signOut().then((value) {
                print("Sesión Cerrada");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              });
            },
          ),
          // Agrega más elementos del menú según sea necesario
        ],
      ),
    );
  }
}

Container busquedaCliente(
    TextEditingController searchController, Function(String) filterClientes) {
  return Container(
    width: 500, // Usar todo el ancho disponible
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: TextField(
      cursorColor: Color(0XFFD60019),
      controller: searchController,
      onChanged: filterClientes,
      decoration: InputDecoration(
        hintText: 'Buscar Clientes',
        prefixIcon: Icon(Icons.search),
        border: InputBorder.none,
      ),
    ),
  );
}

// Widget reutilizable para campos de texto
TextField reusableTextField(String text, IconData icon, bool isPasswordType,
    TextEditingController controller) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.white,
    style: TextStyle(color: Colors.white.withOpacity(0.9)),
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        color: Color(0xB3FFFFFF),
      ),
      labelText: text,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: Color(0xFF000000).withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: const BorderSide(width: 0, style: BorderStyle.none),
      ),
    ),
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}

// Widget para un botón de inicio de sesión o registro
Container loginButton(BuildContext context, bool isLogin, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      child: Text(
        isLogin ? 'INICIAR SESIÓN' : 'REGISTRARSE',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.black26;
          }
          return Color(0xFF004B85);
        }),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    ),
  );
}

// Widget para mostrar un enlace de registro
Row opcionRegistro(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        "Para crear nueva cuenta, presione",
        style: TextStyle(color: Colors.black),
      ),
      GestureDetector(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => RegisterPage()));
        },
        child: const Text(
          " Aquí",
          style:
              TextStyle(color: Color(0xffD60019), fontWeight: FontWeight.bold),
        ),
      )
    ],
  );
}

// Widget para crear un contenedor con gradiente de colores
Widget buildGradientContainer(Widget child, List<Color> colors) {
  return Container(
    width: double.infinity,
    height: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: child,
  );
}

Widget textFieldAgregarClientes(
  String labelText,
  IconData prefixIcon,
  bool isPassword,
  TextEditingController controller,
) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 5),
    child: TextField(
      controller: controller,
      obscureText: isPassword,
      enableSuggestions: !isPassword,
      autocorrect: !isPassword,
      cursorColor: Color(0XFFD60019),
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon,
            color: Color(0XFF004B85), size: TextSelectionToolbar.kHandleSize),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
  );
}
