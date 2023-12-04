import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/servicio.dart';

class FirestoreService {
  final CollectionReference serviciosCollection =
      FirebaseFirestore.instance.collection("servicios");

  Future<void> agregarServicio(Servicio servicio) async {
    await serviciosCollection.add(servicio.toJson());
  }

  Future<void> actualizarServicio(String servicioId, Servicio servicio) async {
    await serviciosCollection.doc(servicioId).update(servicio.toJson());
  }

  Future<void> eliminarServicio(String servicioId) async {
    await serviciosCollection.doc(servicioId).delete();
  }
}

class ServicioDataTable extends StatefulWidget {
  final List<QueryDocumentSnapshot>? documentSnapshots;

  const ServicioDataTable({Key? key, this.documentSnapshots}) : super(key: key);

  @override
  _ServicioDataTableState createState() => _ServicioDataTableState();
}

class _ServicioDataTableState extends State<ServicioDataTable> {
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
          buildSortableHeader(
            'ID SERVICIO',
            (servicio) => servicio.id_servicio,
          ),
          buildSortableHeader(
            'DESCRIPCIÓN',
            (servicio) => servicio.descripcion,
          ),
          buildSortableHeader(
            'COSTO',
            (servicio) => servicio.costo
                .toString(), // Convertir a cadena para mostrar en Text
          ),
          DataColumn(
            label: Text(
              'ACCIONES',
              style: TextStyle(
                fontSize: 17.5,
                fontFamily: 'SpaceMonoNerdFont',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        rows: widget.documentSnapshots?.map((documentSnapshot) {
              final servicio = Servicio(
                id_servicio: documentSnapshot["id_servicio"] ?? "",
                descripcion: documentSnapshot["descripcion"] ?? "",
                costo: documentSnapshot["costo"] ??
                    0, // Asegurarse de manejar un valor predeterminado
              );

              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      servicio.id_servicio,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GoMonoNerdFont',
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      servicio.descripcion,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GoMonoNerdFont',
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      servicio.costo.toString(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GoMonoNerdFont',
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        buildIconButton(
                          Icons.delete,
                          Color(0XFFD60019),
                          () {
                            FirestoreService()
                                .eliminarServicio(documentSnapshot.id);
                          },
                        ),
                        buildIconButton(
                          Icons.edit,
                          Color(0XFF004B85),
                          () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AgregarEditarServicioDialog(
                                  servicio: servicio,
                                  servicioId: documentSnapshot.id,
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

  DataColumn buildSortableHeader(String label, Function(Servicio) getField) {
    return DataColumn(
      label: Text(label,
          style: TextStyle(
              fontSize: 17.5,
              fontFamily: 'SpaceMonoNerdFont',
              fontWeight: FontWeight.bold)),
      onSort: (columnIndex, ascending) {
        _sort<Comparable>(
            (servicio) => getField(servicio), columnIndex, ascending);
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

  void _sort<T>(Comparable<T> Function(Servicio servicio) getField,
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
      var aValue = getField(Servicio(
        id_servicio: a["id_servicio"] ?? "",
        descripcion: a["descripcion"] ?? "",
        costo: a["costo"] ?? "",
      ));
      var bValue = getField(Servicio(
        id_servicio: b["id_servicio"] ?? "",
        descripcion: b["descripcion"] ?? "",
        costo: b["costo"] ?? "",
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

class AgregarEditarServicioDialog extends StatefulWidget {
  final Servicio? servicio;
  final String? servicioId;

  AgregarEditarServicioDialog({this.servicio, this.servicioId});

  @override
  _AgregarEditarServicioDialogState createState() =>
      _AgregarEditarServicioDialogState();
}

class _AgregarEditarServicioDialogState
    extends State<AgregarEditarServicioDialog> {
  final TextEditingController id_servicioController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController costoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Inicializar controladores con la información del servicio si está disponible
    if (widget.servicio != null) {
      descripcionController.text = widget.servicio!.descripcion;

      // Convertir el costo a cadena y luego a entero
      costoController.text = widget.servicio!.costo.toString();
    }

    return AlertDialog(
      title: Text('Agregar Nuevo Servicio'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            //textField("Servicio", id_servicioController),
            textField("Descripcion", descripcionController),
            textField("Costo", costoController),
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
              if (widget.servicio != null) {
                // Lógica para editar el servicio existente en Firebase
                editarServicioExistente();
              } else {
                // Lógica para agregar el nuevo servicio a Firebase
                agregarNuevoServicio();
              }
              Navigator.pop(context); // Cierra el cuadro de diálogo
            } else {
              // Muestra un mensaje de error si hay campos vacíos
              mostrarErrorCamposVacios();
            }
          },
          child: Text(widget.servicio != null ? 'Editar' : 'Agregar'),
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
    return descripcionController.text.isNotEmpty &&
        costoController.text.isNotEmpty;
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

  void agregarNuevoServicio() async {
    try {
      // Obtener una referencia a la colección "servicios" en Firebase
      final serviciosCollection =
          FirebaseFirestore.instance.collection("servicios");

      // Obtener el último documento ordenado por id_servicio de forma descendente
      QuerySnapshot ultimoServicio = await serviciosCollection
          .orderBy('id_servicio', descending: true)
          .limit(1)
          .get();

      int ultimoValor = 0;

      // Verificar si hay algún documento en la colección
      if (ultimoServicio.docs.isNotEmpty) {
        // Obtener el último valor de id_servicio y aumentarlo en 1
        ultimoValor = int.parse(ultimoServicio.docs.first['id_servicio']
            .toString()
            .replaceAll('SERV-', ''));
      }

      // Generar el próximo código
      String nuevoCodigo =
          'SERV-${(ultimoValor + 1).toString().padLeft(2, '0')}';

      // Convertir el valor del controlador de texto a un entero
      int costo = int.parse(costoController.text);

      // Agregar el nuevo servicio a Firebase
      await serviciosCollection.add({
        "id_servicio": nuevoCodigo,
        "descripcion": descripcionController.text,
        "costo": costo, // Almacena el costo como un entero
      });

      print(
          "Nuevo servicio agregado con éxito a Firebase. Código: $nuevoCodigo");
    } catch (e) {
      print("Error al agregar nuevo servicio a Firebase: $e");
    }
  }

  void editarServicioExistente() async {
    try {
      // Obtener una referencia al documento del servicio en Firebase
      final servicioRef = FirebaseFirestore.instance
          .collection("servicios")
          .doc(widget.servicioId);

      // Convertir el valor del controlador de texto a un entero
      int costo = int.parse(costoController.text);

      // Actualizar la información del servicio en Firebase
      await servicioRef.update({
        //"id_servicio": id_servicioController.text,
        "descripcion": descripcionController.text,
        "costo": costo, // Almacena el costo como un entero
      });

      print("Servicio editado con éxito en Firebase.");
    } catch (e) {
      print("Error al editar servicio en Firebase: $e");
    }
  }
}
