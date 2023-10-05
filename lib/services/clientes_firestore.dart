import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../widgets/reusable_widget.dart';

class FirestoreService {
  final CollectionReference clientesCollection =
      FirebaseFirestore.instance.collection("clientes");

  Future<void> agregarCliente(Cliente cliente) async {
    await clientesCollection.add(cliente.toJson());
  }

  Future<void> actualizarCliente(String clienteId, Cliente cliente) async {
    await clientesCollection.doc(clienteId).update(cliente.toJson());
  }

  Future<void> eliminarCliente(String clienteId) async {
    await clientesCollection.doc(clienteId).delete();
  }
}

class ClientesDataTable extends StatelessWidget {
  final List<QueryDocumentSnapshot>? documentSnapshots;

  const ClientesDataTable({Key? key, this.documentSnapshots}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25), // Color de la sombra
            spreadRadius: 5, // Radio de expansión de la sombra
            blurRadius: 7, // Radio de desenfoque de la sombra
            offset: Offset(
                0, 3), // Desplazamiento de la sombra (horizontal, vertical)
          ),
        ],
      ),
      child: DataTable(
        columns: [
          DataColumn(
            label: Text('RUT',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('NOMBRE',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('APELLIDO',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('DIRECCION',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('TELEFONO',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('EMAIL',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label:
                Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        rows: documentSnapshots?.map((documentSnapshot) {
              final cliente = Cliente(
                rut: documentSnapshot["rut_cliente"] ?? "",
                nombre: documentSnapshot["nom_cliente"] ?? "",
                apellido: documentSnapshot["ape_cliente"] ?? "",
                direccion: documentSnapshot["dir_cliente"] ?? "",
                telefono: documentSnapshot["tel_cliente"] ?? "",
                email: documentSnapshot["email_cliente"] ?? "",
              );

              return DataRow(
                cells: [
                  DataCell(Text(cliente.rut)),
                  DataCell(Text(cliente.nombre)),
                  DataCell(Text(cliente.apellido)),
                  DataCell(Text(cliente.direccion)),
                  DataCell(Text(cliente.telefono)),
                  DataCell(Text(cliente.email)),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete),
                          color: Color(0XFFD60019),
                          onPressed: () {
                            FirestoreService()
                                .eliminarCliente(documentSnapshot.id);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          color: Color(0XFF004B85),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AgregarEditarClienteDialog(
                                  cliente: cliente,
                                  clienteId: documentSnapshot.id,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList() ??
            [],
      ),
    );
  }
}

class AgregarEditarClienteDialog extends StatefulWidget {
  final Cliente? cliente;
  final String? clienteId;

  AgregarEditarClienteDialog({this.cliente, this.clienteId});

  @override
  _AgregarEditarClienteDialogState createState() =>
      _AgregarEditarClienteDialogState();
}

class _AgregarEditarClienteDialogState
    extends State<AgregarEditarClienteDialog> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController rutController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.cliente != null) {
      // Llena los controladores de texto con la información del cliente.
      rutController.text = widget.cliente!.rut;
      nombreController.text = widget.cliente!.nombre;
      apellidoController.text = widget.cliente!.apellido;
      direccionController.text = widget.cliente!.direccion;
      telefonoController.text = widget.cliente!.telefono;
      emailController.text = widget.cliente!.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.clienteId != null ? 'Editar Cliente' : 'Agregar Cliente',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            textFieldAgregarClientes('RUT', Icons.person, false, rutController),
            textFieldAgregarClientes(
                'Nombre', Icons.person, false, nombreController),
            textFieldAgregarClientes(
                'Apellido', Icons.person, false, apellidoController),
            textFieldAgregarClientes(
                'Dirección', Icons.location_on, false, direccionController),
            textFieldAgregarClientes(
                'Teléfono', Icons.phone, false, telefonoController),
            textFieldAgregarClientes(
                'Email', Icons.email, false, emailController),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _guardarCliente,
              style: ElevatedButton.styleFrom(
                primary: Color(0XFF004B85),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                widget.clienteId != null ? 'Actualizar' : 'Guardar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _guardarCliente() {
    final cliente = Cliente(
      rut: rutController.text,
      nombre: nombreController.text,
      apellido: apellidoController.text,
      direccion: direccionController.text,
      telefono: telefonoController.text,
      email: emailController.text,
    );

    if (widget.clienteId != null) {
      // Actualizar cliente existente
      _firestoreService.actualizarCliente(widget.clienteId!, cliente);
    } else {
      // Agregar nuevo cliente
      _firestoreService.agregarCliente(cliente);
    }

    Navigator.of(context)
        .pop(); // Cierra el diálogo después de guardar/actualizar.
  }
}

void deleteCliente(String clienteId) {
  FirebaseFirestore.instance
      .collection("clientes")
      .doc(clienteId)
      .delete()
      .then(
    (value) {
      print("Deleted successfully");
    },
  );
}
