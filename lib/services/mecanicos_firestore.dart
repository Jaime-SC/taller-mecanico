import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../models/mecanico.dart';

class FirestoreService {
  final CollectionReference mecanicosCollection =
      FirebaseFirestore.instance.collection("mecanicos");

  Future<void> agregarMecanico(Mecanico mecanico) async {
    await mecanicosCollection.add(mecanico.toJson());
  }

  Future<void> actualizarMecanico(String mecanicoId, Mecanico mecanico) async {
    await mecanicosCollection.doc(mecanicoId).update(mecanico.toJson());
  }

  Future<void> eliminarMecanico(String mecanicoId) async {
    await mecanicosCollection.doc(mecanicoId).delete();
  }
}

class MecanicosDataTable extends StatefulWidget {
  final List<QueryDocumentSnapshot>? documentSnapshots;

  const MecanicosDataTable({Key? key, this.documentSnapshots})
      : super(key: key);

  @override
  _MecanicosDataTableState createState() => _MecanicosDataTableState();
}

class _MecanicosDataTableState extends State<MecanicosDataTable> {
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
          buildSortableHeader('RUT', (mecanico) => mecanico.rut_mecanico),
          buildSortableHeader('NOMBRE', (mecanico) => mecanico.nom_mecanico),
          buildSortableHeader('APELLIDO', (mecanico) => mecanico.ape_mecanico),
          buildSortableHeader('EMAIL', (mecanico) => mecanico.email_mecanico),
          DataColumn(
            label: Text('ACCIONES',
                style: TextStyle(
                    fontSize: 17.5,
                    fontFamily: 'SpaceMonoNerdFont',
                    fontWeight: FontWeight.bold)),
          ),
        ],
        rows: widget.documentSnapshots?.map((documentSnapshot) {
              final mecanico = Mecanico(
                id: documentSnapshot.id,
                rut_mecanico: documentSnapshot["rut_mecanico"] ?? "",
                nom_mecanico: documentSnapshot["nom_mecanico"] ?? "",
                ape_mecanico: documentSnapshot["ape_mecanico"] ?? "",
                email_mecanico: documentSnapshot["email_mecanico"] ?? "",
              );

              return DataRow(
                cells: [
                  DataCell(Text(mecanico.rut_mecanico,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoMonoNerdFont'))),
                  DataCell(Text(mecanico.nom_mecanico,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoMonoNerdFont'))),
                  DataCell(Text(mecanico.ape_mecanico,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoMonoNerdFont'))),
                  DataCell(Text(mecanico.email_mecanico,
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
                                .eliminarMecanico(documentSnapshot.id);
                          },
                        ),
                        buildIconButton(
                          Icons.edit,
                          Color(0XFF004B85),
                          () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AgregarEditarMecanicoDialog(
                                  mecanico: mecanico,
                                  mecanicoId: documentSnapshot.id,
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

  DataColumn buildSortableHeader(String label, Function(Mecanico) getField) {
    return DataColumn(
      label: Text(label,
          style: TextStyle(
              fontSize: 17.5,
              fontFamily: 'SpaceMonoNerdFont',
              fontWeight: FontWeight.bold)),
      onSort: (columnIndex, ascending) {
        _sort<Comparable>(
            (mecanico) => getField(mecanico), columnIndex, ascending);
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

  void _sort<T>(Comparable<T> Function(Mecanico mecanico) getField,
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
      var aValue = getField(Mecanico(
        id: a.id,
        rut_mecanico: a["rut_mecanico"] ?? "",
        nom_mecanico: a["nom_mecanico"] ?? "",
        ape_mecanico: a["ape_mecanico"] ?? "",
        email_mecanico: a["email_mecanico"] ?? "",
      ));
      var bValue = getField(Mecanico(
        id: b.id,
        rut_mecanico: b["rut_mecanico"] ?? "",
        nom_mecanico: b["nom_mecanico"] ?? "",
        ape_mecanico: b["ape_mecanico"] ?? "",
        email_mecanico: b["email_mecanico"] ?? "",
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

class AgregarEditarMecanicoDialog extends StatefulWidget {
  final Mecanico? mecanico;
  final String? mecanicoId;

  AgregarEditarMecanicoDialog({this.mecanico, this.mecanicoId});

  @override
  _AgregarEditarMecanicoDialogState createState() =>
      _AgregarEditarMecanicoDialogState();
}

class _AgregarEditarMecanicoDialogState
    extends State<AgregarEditarMecanicoDialog> {
  final TextEditingController rutController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Inicializar controladores con la información del Mecanico si está disponible
    if (widget.mecanico != null) {
      rutController.text = widget.mecanico!.rut_mecanico;
      nombreController.text = widget.mecanico!.nom_mecanico;
      apellidoController.text = widget.mecanico!.ape_mecanico;

      emailController.text = widget.mecanico!.email_mecanico;
    }

    return AlertDialog(
      title: Text('Agregar Nuevo Mecanico'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            textField("RUT", rutController),
            textField("Nombre", nombreController),
            textField("Apellido", apellidoController),
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
              if (widget.mecanico != null) {
                // Lógica para editar el mecanico existente en Firebase
                editarMecanicoExistente();
              } else {
                // Lógica para agregar el nuevo mecanico a Firebase
                agregarNuevoMecanico();
              }
              Navigator.pop(context); // Cierra el cuadro de diálogo
            } else {
              // Muestra un mensaje de error si hay campos vacíos
              //mostrarErrorCamposVacios();
            }
          },
          child: Text(widget.mecanico != null ? 'Editar' : 'Agregar'),
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

  /*bool camposValidos() {
    // Verifica que todos los campos estén llenos
    return rutController.text.isNotEmpty &&
        nombreController.text.isNotEmpty &&
        apellidoController.text.isNotEmpty &&
        emailController.text.isNotEmpty;
  }*/

bool camposValidos() {
  // Verifica que todos los campos estén llenos
  Map<String, TextEditingController> controllers = {
    "Rut": rutController,
    "Nombre": nombreController,
    "Apellido": apellidoController,
    "Email": emailController,
  };
  List<String> camposFaltantes = [];

  controllers.forEach((key, value) {
    if (value.text.isEmpty) {
      camposFaltantes.add(key);
    }
  });

  if (camposFaltantes.isNotEmpty) {
    mostrarErrorCamposVacios(camposFaltantes);
    return false;
  }

  return true;
}

  void mostrarErrorCamposVacios(List<String> camposFaltantes) {
    // Muestra un mensaje de error si hay campos vacíos
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Campos Vacíos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Todos los campos son obligatorios. Por favor, completa la información.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildCampoCompleto("Rut", !camposFaltantes.contains("Rut")),
                  buildCampoCompleto(
                      "Nombre", !camposFaltantes.contains("Nombre")),
                  buildCampoCompleto(
                      "Apellido", !camposFaltantes.contains("Apellido")),
                  buildCampoCompleto(
                      "Email", !camposFaltantes.contains("Email")),
                ],
              ),
            ],
          ),
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

  Widget buildCampoCompleto(String campo, bool completo) {
  return Row(
    children: [
      Icon(
        completo ? Icons.check_circle : Icons.cancel,
        color: completo ? Colors.green : Colors.red,
      ),
      SizedBox(width: 8),
      Text(
        campo,
        style: TextStyle(
          fontSize: 16,
          color: completo ? Colors.green : Colors.red,
        ),
      ),
    ],
  );
}

  void agregarNuevoMecanico() async {
    try {
      // Obtener una referencia a la colección "mecanicos" en Firebase
      final mecanicosCollection =
          FirebaseFirestore.instance.collection("mecanicos");

      // Agregar el nuevo mecanico a Firebase
      await mecanicosCollection.add({
        "rut_mecanico": rutController.text,
        "nom_mecanico": nombreController.text,
        "ape_mecanico": apellidoController.text,
        "email_mecanico": emailController.text,
      });

      print("Nuevo mecanico agregado con éxito a Firebase.");
    } catch (e) {
      print("Error al agregar nuevo mecanico a Firebase: $e");
    }
  }

  void editarMecanicoExistente() async {
    try {
      // Obtener una referencia al documento del mecanico en Firebase
      final mecanicoRef = FirebaseFirestore.instance
          .collection("mecanicos")
          .doc(widget.mecanicoId);

      // Actualizar la información del mecanico en Firebase
      await mecanicoRef.update({
        "rut_mecanico": rutController.text,
        "nom_mecanico": nombreController.text,
        "ape_mecanico": apellidoController.text,
        "email_mecanico": emailController.text,
      });

      print("Mecanico editado con éxito en Firebase.");
    } catch (e) {
      print("Error al editar mecanico en Firebase: $e");
    }
  }
}
