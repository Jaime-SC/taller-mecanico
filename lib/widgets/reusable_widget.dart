import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taller_mecanico/pages/factura_page.dart';
import 'package:taller_mecanico/pages/mecanicos_page.dart';
import 'package:taller_mecanico/pages/servicio_page.dart';
import '../pages/clientes_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/ordenTrabajo_page.dart';
import '../pages/register_page.dart';
import '../pages/vehiculos_page.dart';

Image logoWidget(String imageName) => Image.asset(
      imageName,
      fit: BoxFit.fitWidth,
      width: 340,
      height: 340,
      color: Colors.white,
    );

Image logoDrawer(String imageName) => Image.asset(
      imageName,
      color: Colors.white,
    );

class AppDrawer extends StatelessWidget {
  final VoidCallback? onSignOut;

  AppDrawer({Key? key, this.onSignOut}) : super(key: key);

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
          drawerItem("Clientes", () => navigateTo(context, ClientesPage())),
          drawerItem("Vehículos", () => navigateTo(context, VehiculosPage())),
          drawerItem("Orden de Trabajo",
              () => navigateTo(context, OrdenesTrabajosPage())),
          drawerItem("Mecanicos", () => navigateTo(context, MecanicosPage())),
          drawerItem("Servicios", () => navigateTo(context, ServiciosPage())),
          drawerItem("Facturas", () => navigateTo(context, FacturasPage())),          
          drawerItem("Cerrar Sesión", () async {
            try {
              await FirebaseAuth.instance.signOut();
              // Navega a la pantalla de inicio de sesión u otra pantalla apropiada
              navigateTo(context, LoginPage());
            } catch (e) {
              print("Error al cerrar sesión: $e");
            }
          }),
        ],
      ),
    );
  }
}

Widget drawerItem(String title, Function onTap) => ListTile(
      title: Text(title,
          style: TextStyle(fontFamily: 'SpaceMonoNerdFont', fontSize: 17.5)),
      onTap: onTap as void Function()?,
    );

void navigateTo(BuildContext context, Widget page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

Container busquedaCliente(TextEditingController searchController,
        Function(String) filterClientes) =>
    Container(
      width: 500,
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

Container busquedaVehiculo(TextEditingController searchController,
        Function(String) filterVehiculos) =>
    Container(
      width: 500,
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
        onChanged: filterVehiculos,
        decoration: InputDecoration(
          hintText: 'Buscar Vehiculos',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
      ),
    );

Container busquedaOrdenTrabajo(TextEditingController searchController,
        Function(String) filterOrdenesTrabajos) =>
    Container(
      width: 500,
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
        onChanged: filterOrdenesTrabajos,
        decoration: InputDecoration(
          hintText: 'Buscar OrdenesTrabajos',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
      ),
    );

Container busquedaMecanico(TextEditingController searchController,
        Function(String) filterMecanicos) =>
    Container(
      width: 500,
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
        onChanged: filterMecanicos,
        decoration: InputDecoration(
          hintText: 'Buscar Mecanicos',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
      ),
    );

Container busquedaServicio(TextEditingController searchController,
        Function(String) filterServicios) =>
    Container(
      width: 500,
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
        onChanged: filterServicios,
        decoration: InputDecoration(
          hintText: 'Buscar Servicios',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
      ),
    );

Container busquedaFactura(TextEditingController searchController,
        Function(String) filterFacturas) =>
    Container(
      width: 500,
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
        onChanged: filterFacturas,
        decoration: InputDecoration(
          hintText: 'Buscar Facturas',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
      ),
    );

TextField reusableTextField(String text, IconData icon, bool isPasswordType,
        TextEditingController controller) =>
    TextField(
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

Container loginButton(BuildContext context, bool isLogin, Function onTap) =>
    Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
      child: ElevatedButton(
        onPressed: () => onTap(),
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

Row opcionRegistro(BuildContext context) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Para crear nueva cuenta, presione",
          style: TextStyle(color: Colors.black),
        ),
        GestureDetector(
          onTap: () => navigateTo(context, RegisterPage()),
          child: const Text(
            " Aquí",
            style: TextStyle(
                color: Color(0xffD60019), fontWeight: FontWeight.bold),
          ),
        )
      ],
    );

Widget buildGradientContainer(Widget child, List<Color> colors) => Container(
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

Widget textFieldAgregarClientes(String labelText, IconData prefixIcon,
        bool isPassword, TextEditingController controller) =>
    Container(
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
