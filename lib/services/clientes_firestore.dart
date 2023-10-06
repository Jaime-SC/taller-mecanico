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

class ClientesDataTable extends StatefulWidget {
  final List<QueryDocumentSnapshot>? documentSnapshots;

  const ClientesDataTable({Key? key, this.documentSnapshots}) : super(key: key);

  @override
  _ClientesDataTableState createState() => _ClientesDataTableState();
}

class _ClientesDataTableState extends State<ClientesDataTable> {
  int _currentSortColumnIndex = 0;
  bool _currentSortAscending = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: DataTable(
        columns: [
          buildSortableHeader('RUT', (cliente) => cliente.rut),
          buildSortableHeader('NOMBRE', (cliente) => cliente.nombre),
          buildSortableHeader('APELLIDO', (cliente) => cliente.apellido),
          buildSortableHeader('DIRECCION', (cliente) => cliente.direccion),
          buildSortableHeader('TELEFONO', (cliente) => cliente.telefono),
          buildSortableHeader('EMAIL', (cliente) => cliente.email),
          DataColumn(
            label: Text('ACCIONES', style: TextStyle(fontSize: 17.5, fontFamily: 'SpaceMonoNerdFont', fontWeight: FontWeight.bold)),
          ),
        ],
        rows: widget.documentSnapshots?.map((documentSnapshot) {
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
              DataCell(Text(cliente.rut, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'GoMonoNerdFont'))),
              DataCell(Text(cliente.nombre, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'GoMonoNerdFont'))),
              DataCell(Text(cliente.apellido, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'GoMonoNerdFont'))),
              DataCell(Text(cliente.direccion, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'GoMonoNerdFont'))),
              DataCell(Text(cliente.telefono, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'GoMonoNerdFont'))),
              DataCell(Text(cliente.email, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'GoMonoNerdFont'))),
              DataCell(
                Row(
                  children: [
                    buildIconButton(
                      Icons.delete,
                      Color(0XFFD60019),
                      () {
                        FirestoreService()
                            .eliminarCliente(documentSnapshot.id);
                      },
                    ),
                    buildIconButton(
                      Icons.edit,
                      Color(0XFF004B85),
                      () {
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

  DataColumn buildSortableHeader(String label, Function(Cliente) getField) {
    return DataColumn(
      label: Text(label, style: TextStyle(fontSize: 17.5, fontFamily: 'SpaceMonoNerdFont', fontWeight: FontWeight.bold)),
      onSort: (columnIndex, ascending) {
        _sort<Comparable>((cliente) => getField(cliente), columnIndex, ascending);
      },
    );
  }

  IconButton buildIconButton(IconData icon, Color color, Function onPressed) {
    return IconButton(
      icon: Icon(icon),
      color: color,
      onPressed: onPressed as void Function()?,
    );
  }

  void _resetSorting() {
    setState(() {
      _currentSortColumnIndex = 0;
      _currentSortAscending = true;
    });
  }

  void _sort<T>(Comparable<T> Function(Cliente cliente) getField, int columnIndex, bool ascending) {
    if (_currentSortColumnIndex == columnIndex) {
      setState(() {
        _currentSortAscending = !_currentSortAscending;
      });
    } else {
      setState(() {
        _currentSortColumnIndex = columnIndex;
        _currentSortAscending = true;
      });
    }

    widget.documentSnapshots?.sort((a, b) {
      var aValue = getField(Cliente(
        rut: a["rut_cliente"] ?? "",
        nombre: a["nom_cliente"] ?? "",
        apellido: a["ape_cliente"] ?? "",
        direccion: a["dir_cliente"] ?? "",
        telefono: a["tel_cliente"] ?? "",
        email: a["email_cliente"] ?? "",
      ));
      var bValue = getField(Cliente(
        rut: b["rut_cliente"] ?? "",
        nombre: b["nom_cliente"] ?? "",
        apellido: b["ape_cliente"] ?? "",
        direccion: b["dir_cliente"] ?? "",
        telefono: b["tel_cliente"] ?? "",
        email: b["email_cliente"] ?? "",
      ));

      if (!ascending) {
        var temp = aValue;
        aValue = bValue;
        bValue = temp;
      }

      final comparison = aValue.compareTo(bValue as T);

      return _currentSortAscending ? comparison : -comparison;
    });
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
      _firestoreService.actualizarCliente(widget.clienteId!, cliente);
    } else {
      _firestoreService.agregarCliente(cliente);
    }

    Navigator.of(context).pop();
    setState(() {});
  }
}

void deleteCliente(String clienteId) {
  FirebaseFirestore.instance
      .collection("clientes")
      .doc(clienteId)
      .delete()
      .then(
    (value) {
      print("Eliminado Correctamente");
    },
  );
}
