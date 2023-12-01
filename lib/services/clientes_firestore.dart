import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/cliente.dart';

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
          buildSortableHeader('RUT', (cliente) => cliente.rut_cliente),
          buildSortableHeader('NOMBRE', (cliente) => cliente.nom_cliente),
          buildSortableHeader('APELLIDO', (cliente) => cliente.ape_cliente),
          buildSortableHeader('DIRECCION', (cliente) => cliente.dir_cliente),
          buildSortableHeader('TELEFONO', (cliente) => cliente.tel_cliente),
          buildSortableHeader('EMAIL', (cliente) => cliente.email_cliente),
          DataColumn(
            label: Text('ACCIONES',
                style: TextStyle(
                    fontSize: 17.5,
                    fontFamily: 'SpaceMonoNerdFont',
                    fontWeight: FontWeight.bold)),
          ),
        ],
        rows: widget.documentSnapshots?.map((documentSnapshot) {
              final cliente = Cliente(
                id: documentSnapshot.id,
                rut_cliente: documentSnapshot["rut_cliente"] ?? "",
                nom_cliente: documentSnapshot["nom_cliente"] ?? "",
                ape_cliente: documentSnapshot["ape_cliente"] ?? "",
                dir_cliente: documentSnapshot["dir_cliente"] ?? "",
                tel_cliente: documentSnapshot["tel_cliente"] ?? "",
                email_cliente: documentSnapshot["email_cliente"] ?? "",
              );

              return DataRow(
                cells: [
                  DataCell(Text(cliente.rut_cliente,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoMonoNerdFont'))),
                  DataCell(Text(cliente.nom_cliente,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoMonoNerdFont'))),
                  DataCell(Text(cliente.ape_cliente,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoMonoNerdFont'))),
                  DataCell(Text(cliente.dir_cliente,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoMonoNerdFont'))),
                  DataCell(Text(cliente.tel_cliente,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoMonoNerdFont'))),
                  DataCell(Text(cliente.email_cliente,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoMonoNerdFont'))),
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
      label: Text(label,
          style: TextStyle(
              fontSize: 17.5,
              fontFamily: 'SpaceMonoNerdFont',
              fontWeight: FontWeight.bold)),
      onSort: (columnIndex, ascending) {
        _sort<Comparable>(
            (cliente) => getField(cliente), columnIndex, ascending);
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

  void _sort<T>(Comparable<T> Function(Cliente cliente) getField,
      int columnIndex, bool ascending) {
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
        id: a.id,
        rut_cliente: a["rut_cliente"] ?? "",
        nom_cliente: a["nom_cliente"] ?? "",
        ape_cliente: a["ape_cliente"] ?? "",
        dir_cliente: a["dir_cliente"] ?? "",
        tel_cliente: a["tel_cliente"] ?? "",
        email_cliente: a["email_cliente"] ?? "",
      ));
      var bValue = getField(Cliente(
        id: b.id,
        rut_cliente: b["rut_cliente"] ?? "",
        nom_cliente: b["nom_cliente"] ?? "",
        ape_cliente: b["ape_cliente"] ?? "",
        dir_cliente: b["dir_cliente"] ?? "",
        tel_cliente: b["tel_cliente"] ?? "",
        email_cliente: b["email_cliente"] ?? "",
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
  final TextEditingController rutController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Inicializar controladores con la información del cliente si está disponible
    if (widget.cliente != null) {
      rutController.text = widget.cliente!.rut_cliente;
      nombreController.text = widget.cliente!.nom_cliente;
      apellidoController.text = widget.cliente!.ape_cliente;
      direccionController.text = widget.cliente!.dir_cliente;
      telefonoController.text = widget.cliente!.tel_cliente;
      emailController.text = widget.cliente!.email_cliente;
    }

    return AlertDialog(
      title: Text('Agregar Nuevo Cliente'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            textField("RUT", rutController),
            textField("Nombre", nombreController),
            textField("Apellido", apellidoController),
            textField("Dirección", direccionController),
            textField("Teléfono", telefonoController),
            textField("Email", emailController),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Cierra el cuadro de diálogo
          },
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            if (camposValidos()) {
              if (widget.cliente != null) {
                // Lógica para editar el cliente existente en Firebase
                editarClienteExistente();
              } else {
                // Lógica para agregar el nuevo cliente a Firebase
                agregarNuevoCliente();
              }
              Navigator.pop(context); // Cierra el cuadro de diálogo
            } else {
              // Muestra un mensaje de error si hay campos vacíos
              mostrarErrorCamposVacios();
            }
          },
          child: Text(widget.cliente != null ? 'Editar' : 'Agregar'),
        ),
      ],
    );
  }

  Widget textField(String labelText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(labelText: labelText),
        controller: controller,
      ),
    );
  }

  bool camposValidos() {
    // Verifica que todos los campos estén llenos
    return rutController.text.isNotEmpty &&
        nombreController.text.isNotEmpty &&
        apellidoController.text.isNotEmpty &&
        direccionController.text.isNotEmpty &&
        telefonoController.text.isNotEmpty &&
        emailController.text.isNotEmpty;
  }

  void mostrarErrorCamposVacios() {
    // Muestra un mensaje de error si hay campos vacíos
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(
              'Todos los campos son obligatorios. Por favor, completa la información.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void agregarNuevoCliente() async {
    try {
      // Obtener una referencia a la colección "clientes" en Firebase
      final clientesCollection =
          FirebaseFirestore.instance.collection("clientes");

      // Agregar el nuevo cliente a Firebase
      await clientesCollection.add({
        "rut_cliente": rutController.text,
        "nom_cliente": nombreController.text,
        "ape_cliente": apellidoController.text,
        "dir_cliente": direccionController.text,
        "tel_cliente": telefonoController.text,
        "email_cliente": emailController.text,
      });

      print("Nuevo cliente agregado con éxito a Firebase.");
    } catch (e) {
      print("Error al agregar nuevo cliente a Firebase: $e");
    }
  }

  void editarClienteExistente() async {
    try {
      // Obtener una referencia al documento del cliente en Firebase
      final clienteRef = FirebaseFirestore.instance
          .collection("clientes")
          .doc(widget.clienteId);

      // Actualizar la información del cliente en Firebase
      await clienteRef.update({
        "rut_cliente": rutController.text,
        "nom_cliente": nombreController.text,
        "ape_cliente": apellidoController.text,
        "dir_cliente": direccionController.text,
        "tel_cliente": telefonoController.text,
        "email_cliente": emailController.text,
      });

      print("Cliente editado con éxito en Firebase.");
    } catch (e) {
      print("Error al editar cliente en Firebase: $e");
    }
  }
}
