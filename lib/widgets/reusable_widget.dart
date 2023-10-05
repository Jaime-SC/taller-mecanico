import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/clientes_page.dart';
import '../pages/login_page.dart';
import '../pages/ordenTrabajo_page.dart';
import '../pages/register_page.dart';
import '../pages/vehiculos_page.dart';
import 'app_colors.dart';

Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 340,
    height: 340,
    color: Colors.white,
  );
}

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.colorBase,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Text(
              'Menú de Navegación',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text('Clientes'),
            onTap: () {
              // Navegar a la página de clientes.dart
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClientesPage(title: 'Clientes',)),
              );
            },
          ),
          ListTile(
            title: Text('Vehículos'),
            onTap: () {
              // Navegar a la página de vehiculos.dart
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VehiculosPage()),
              );
            },
          ),
          ListTile(
            title: Text('Orden de Trabajo'),
            onTap: () {
              // Navegar a la página de ordenTrabajo.dart
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
          // Agrega más elementos de menú según tus necesidades
        ],
      ),
    );
  }
}




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
          borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
    ),
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}

// Container firebaseUIButton(BuildContext context, String title, Function onTap) {
//   return Container(
//     width: MediaQuery.of(context).size.width,
//     height: 50,
//     margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
//     decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
//     child: ElevatedButton(
//       onPressed: () {
//         onTap();
//       },
//       child: Text(
//         title,
//         style: const TextStyle(
//             color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
//       ),
//       style: ButtonStyle(
//           backgroundColor: MaterialStateProperty.resolveWith((states) {
//             if (states.contains(MaterialState.pressed)) {
//               return Colors.black26;
//             }
//             return Colors.white;
//           }),
//           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
//     ),
//   );
// }

Container loginButton(BuildContext context, bool, isLogin, Function onTap) {
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
        isLogin ? 'INICIAR SESION' : 'REGISTRARSE',
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black26;
            }
            return Color(0xFF004B85);
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
    ),
  );
}

Row opcionRegistro(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Para crear nueva cuenta, presione",
          style: TextStyle(color: Colors.black)),
      GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
        },
        child: const Text(
          " Aquí",
          style: TextStyle(color: Color(0xffD60019), fontWeight: FontWeight.bold),
        ),
      )
    ],
  );
}


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



