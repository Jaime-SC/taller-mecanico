// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/factura.dart';
import '../models/ordenTrabajo.dart';


class FirestoreService {
  final CollectionReference facturasCollection =
      FirebaseFirestore.instance.collection("facturas");
  final CollectionReference ordenTrabajoCollection =
      FirebaseFirestore.instance.collection("ordenesTrabajos");

  Future<void> agregarFactura(Factura factura) async {
    // Verificamos si la factura tiene una referencia de orden de trabajo
    if (factura.idOrdTrabajoReference == null) {
      print("Error: La factura no tiene una referencia de orden de trabajo.");
      return; // Puedes manejar esto de acuerdo a tu lógica
    }

    // Y finalmente, añadimos la factura a la colección de facturas con la referencia de orden de trabajo
    await facturasCollection.add({
      "id_factura": factura.id_factura,
      "idOrdTrabajoReference": factura.idOrdTrabajoReference,
      "fecha_factura": factura.fecha_factura,
      "total": factura.total,
      "estado": factura.estado,
    });
  }

  Future<List<Factura>> obtenerFacturas() async {
    try {
      QuerySnapshot facturasSnapshot = await facturasCollection.get();

      // Mapeamos los documentos a objetos factura
      List<Factura> facturas = facturasSnapshot.docs.map((doc) {
        return Factura(
          id_factura: doc["id_factura"] ?? '',
          idOrdTrabajoReference: doc["idOrdTrabajoReference"],
          fecha_factura: doc["fecha_factura"] as Timestamp,
          total: doc["total"] ?? 0,
          estado: doc["estado"] ?? '',
        );
      }).toList();

      return facturas;
    } catch (e) {
      print("Error al obtener facturas: $e");
      return []; // Puedes manejar el error según tus necesidades
    }
  }

  Future<void> actualizarFactura(String facturaId, Factura factura) async {
    try {
      await facturasCollection.doc(facturaId).update(factura.toJson());
      print("Vehículo actualizado con éxito.");
    } catch (e) {
      print("Error al actualizar vehículo: $e");
    }
  }

  Future<void> eliminarFactura(String facturaId) async {
    try {
      await facturasCollection.doc(facturaId).delete();
      print("Vehículo eliminado con éxito.");
    } catch (e) {
      print("Error al eliminar vehículo: $e");
    }
  }
}

class FacturasDataTable extends StatefulWidget {
  final List<QueryDocumentSnapshot>? documentSnapshots;

  const FacturasDataTable({Key? key, this.documentSnapshots}) : super(key: key);

  @override
  _FacturasDataTableState createState() => _FacturasDataTableState();
}

class _FacturasDataTableState extends State<FacturasDataTable> {
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
          buildSortableHeader('ID Factura', (factura) => factura.id_factura),
          buildSortableHeader(
              'ID Orden de Trabajo',
              (factura) => factura
                  .idOrdTrabajoReference.id), // Accede al ID de la referencia
          buildSortableHeader(
              'Fecha', (factura) => factura.fecha_factura.toDate().toString()),
          buildSortableHeader('Total', (factura) => factura.total.toString()),
          buildSortableHeader('Estado', (factura) => factura.estado),

          DataColumn(
            label: Text('ACCIONES',
                style: TextStyle(
                    fontSize: 17.5,
                    fontFamily: 'SpaceMonoNerdFont',
                    fontWeight: FontWeight.bold)),
          ),
        ],
        rows: widget.documentSnapshots?.map((documentSnapshot) {
              final factura = Factura.fromFirestore(documentSnapshot);

              return DataRow(
                cells: [
                  DataCell(Text(factura.id_factura,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoMonoNerdFont'))),
                  DataCell(Text(factura.idOrdTrabajoReference.id,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoMonoNerdFont'))),
                  DataCell(Text(factura.fecha_factura.toDate().toString(),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoMonoNerdFont'))),
                  DataCell(Text(factura.total.toString(),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoMonoNerdFont'))),
                  DataCell(Text(factura.estado,
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
                                .eliminarFactura(documentSnapshot.id);
                          },
                        ),
                        buildIconButton(
                          Icons.edit,
                          Color(0XFF004B85),
                          () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AgregarEditarFacturaDialog(
                                  factura: factura,
                                  facturaId: documentSnapshot.id,
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

  DataColumn buildSortableHeader(String label, Function(Factura) getField) {
    return DataColumn(
      label: Text(label,
          style: TextStyle(
              fontSize: 17.5,
              fontFamily: 'SpaceMonoNerdFont',
              fontWeight: FontWeight.bold)),
      onSort: (columnIndex, ascending) {
        _sort<Comparable>(
            (factura) => getField(factura), columnIndex, ascending);
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

  void _sort<T>(Comparable<T> Function(Factura factura) getField,
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
      var aValue = getField(Factura(
        id_factura: a["id_factura"] ?? "",
        idOrdTrabajoReference: a["idOrdTrabajoReference"] ?? "",
        fecha_factura: a["fecha_factura"] ?? "",
        total: a["total"] ?? "",
        estado: a["estado"] ?? "",
      ));
      var bValue = getField(Factura(
        id_factura: b["id_factura"] ?? "",
        idOrdTrabajoReference: b["idOrdTrabajoReference"] ?? "",
        fecha_factura: b["fecha_factura"] ?? "",
        total: b["total"] ?? "",
        estado: b["estado"] ?? "",
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

class AgregarEditarFacturaDialog extends StatefulWidget {
  final Factura? factura;
  final String? facturaId;

  AgregarEditarFacturaDialog({this.factura, this.facturaId});

  @override
  _AgregarEditarFacturaDialogState createState() =>
      _AgregarEditarFacturaDialogState();
}

class _AgregarEditarFacturaDialogState
    extends State<AgregarEditarFacturaDialog> {
  bool _isDisposed = false;
  final TextEditingController idOrdTrabajoReferenceController =
      TextEditingController();
  final TextEditingController fechaFacturaController =
      TextEditingController(); // No editable por el usuario
  final TextEditingController totalController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();
  final TextEditingController idOrdTrabajoSeleccionadoController = TextEditingController();


  Future<void> _seleccionarFecha(
      BuildContext context, TextEditingController controller) async {
    final currentContext = context;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (_isDisposed) {
      return;
    }

    if (pickedDate != null && pickedDate != DateTime.now()) {
      print('Valor del controlador antes: ${controller.text}');

      if (currentContext == context && mounted && !_isDisposed) {
        setState(() {
          controller.text = DateFormat('dd-MM-yyyy').format(pickedDate);
        });
      }

      print('Valor del controlador después: ${controller.text}');
    }
  }

  Future<void> _seleccionarOrdenTrabajo(BuildContext context) async {
    final ordenTrabajoSeleccionado = await showDialog<OrdenTrabajo>(
      context: context,
      builder: (BuildContext context) {
        return OrdenTrabajoSeleccionDialog();
      },
    );

    if (ordenTrabajoSeleccionado != null) {
      setState(() {
        idOrdTrabajoReferenceController.text =
            ordenTrabajoSeleccionado.id_ord_trabajo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Inicializar controladores con la información del vehículo si está disponible
    if (widget.factura != null) {
      idOrdTrabajoReferenceController.text =
          widget.factura!.idOrdTrabajoReference.id;
      fechaFacturaController.text = DateFormat('dd-MM-yyyy')
          .format(widget.factura!.fecha_factura.toDate());
      totalController.text = widget.factura!.total.toString();
      estadoController.text = widget.factura!.estado;
    }

    return AlertDialog(
      title: Text('Agregar Nuevo Factura'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: textField(
                      "Orden de Trabajo", idOrdTrabajoReferenceController,
                      enabled: false),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    // Abre el diálogo de selección de clientes
                    _seleccionarOrdenTrabajo(context);
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: textField("Fecha factura", fechaFacturaController),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    _seleccionarFecha(context, fechaFacturaController);
                  },
                ),
              ],
            ),
            textField("Total", totalController),
            textField("Estado", estadoController),
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
              if (widget.factura != null) {
                // Lógica para editar el vehículo existente en Firebase
                editarFacturaExistente();
              } else {
                // Lógica para agregar el nuevo vehículo a Firebase
                agregarNuevoFactura();
              }
              Navigator.pop(context); // Cierra el cuadro de diálogo
            } else {
              // Muestra un mensaje de error si hay campos vacíos
              mostrarErrorCamposVacios();
            }
          },
          child: Text(widget.factura != null ? 'Editar' : 'Agregar'),
        ),
      ],
    );
  }

  Widget textField(String labelText, TextEditingController controller,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(labelText: labelText),
        controller: controller,
        enabled: enabled,
      ),
    );
  }

  bool camposValidos() {
    // Verifica que todos los campos estén llenos
    return idOrdTrabajoReferenceController.text.isNotEmpty &&
        fechaFacturaController.text.isNotEmpty &&
        totalController.text.isNotEmpty &&
        estadoController.text.isNotEmpty;
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

  Future<void> agregarNuevoFactura() async {
    try {
      // Obtener una referencia a la colección "Facturas" en Firebase
      final facturasCollection =
          FirebaseFirestore.instance.collection("facturas");

      // Obtén la referencia del cliente basada en el ID proporcionado
      final idOrdTrabajoReference = FirebaseFirestore.instance
          .collection('ordenesTrabajos')
          .doc(idOrdTrabajoReferenceController.text);
      DateTime fechaFactura =
          DateFormat('dd-MM-yyyy').parse(fechaFacturaController.text);
      Timestamp fechaFacturaTimestamp = Timestamp.fromDate(fechaFactura);
      int total = int.parse(totalController.text);

      QuerySnapshot ultimaFactura = await facturasCollection
          .orderBy('id_factura', descending: true)
          .limit(1)
          .get();

      int ultimoValor = 0;

      // Verificar si hay algún documento en la colección
      if (ultimaFactura.docs.isNotEmpty) {
        // Obtener el último valor de id_factura y aumentarlo en 1
        ultimoValor = int.parse(ultimaFactura.docs.first['id_factura']
            .toString()
            .replaceAll('FAC-', ''));
      }

      // Generar el próximo código
      String nuevoCodigo =
          'FAC-${(ultimoValor + 1).toString().padLeft(2, '0')}';

      // Agregar el nuevo vehículo a Firebase
      await facturasCollection.add({
        "id_factura": nuevoCodigo,
        "idOrdTrabajoReference":
            idOrdTrabajoReference, // Utiliza la referencia del cliente
        "fecha_factura": fechaFacturaTimestamp,
        "total": total,
        "estado": estadoController.text,
      });

      print("Nuevo vehículo agregado con éxito a Firebase.");
    } catch (e) {
      print("Error al agregar nuevo vehículo a Firebase: $e");
    }
  }

  void editarFacturaExistente() async {
    try {
      // Obtener una referencia al documento del vehículo en Firebase
      final facturaRef = FirebaseFirestore.instance
          .collection("facturas")
          .doc(widget.facturaId);

      int total = int.parse(totalController.text);
      DateTime fechaFactura =
          DateFormat('dd-MM-yyyy').parse(fechaFacturaController.text);
      Timestamp fechaFacturaTimestamp = Timestamp.fromDate(fechaFactura);

      // Actualizar la información del vehículo en Firebase
      await facturaRef.update({
        "idOrdenTrabajoReference": FirebaseFirestore.instance
            .collection('ordenesTrabajos')
            .doc(idOrdTrabajoReferenceController.text),
        "fecha_factura": fechaFacturaTimestamp,
        "total": total,
        "estado": estadoController.text,
      });

      print("Vehículo editado con éxito en Firebase.");
    } catch (e) {
      print("Error al editar vehículo en Firebase: $e");
    }
  }
}

class OrdenTrabajoSeleccionDialog extends StatefulWidget {
  @override
  _OrdenTrabajoSeleccionDialogState createState() =>
      _OrdenTrabajoSeleccionDialogState();
}

class _OrdenTrabajoSeleccionDialogState
    extends State<OrdenTrabajoSeleccionDialog> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Seleccionar OrdenTrabajo'),
      contentPadding:
          EdgeInsets.all(10.0), // Ajusta el padding según tus necesidades
      content: Container(
        width: 350.0,
        height: 450.0, // Ajusta la altura según tus necesidades
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Buscar ordenesTrabajos',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  // Actualiza la lista de ordenesTrabajoss basándose en el término de búsqueda
                  // Puedes utilizar la función de búsqueda en tu lista original
                });
              },
            ),
            Expanded(
              child: FutureBuilder<List<OrdenTrabajo>>(
                future: cargarOrdenesTrabajos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            'Error al cargar ordenesTrabajos: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text('No hay ordenesTrabajos disponibles.'));
                  } else {
                    // Filtra la lista de ordenesTrabajos según el término de búsqueda
                    final filteredOrdenesTrabajos = snapshot.data!
                        .where(
                          (ordenesTrabajo) => ordenesTrabajo.id_ord_trabajo
                              .toLowerCase()
                              .contains(
                                searchController.text.toLowerCase(),
                              ),
                        )
                        .toList();

                    return ListView.builder(
                      itemCount: filteredOrdenesTrabajos.length,
                      itemBuilder: (context, index) {
                        final ordenTrabajo = filteredOrdenesTrabajos[index];
                        return ListTile(
                          title: Text(" ${ordenTrabajo.id_ord_trabajo}"),
                          onTap: () {
                            Navigator.pop(context, ordenTrabajo);
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<OrdenTrabajo>> cargarOrdenesTrabajos() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection("ordenesTrabajos").get();

      return snapshot.docs.map((doc) {
        return OrdenTrabajo(
          id_ord_trabajo: doc["id_ord_trabajo"] ?? '',
          rutReference: doc["rutReference"] ?? '',
          matriculaVehiculoReference: doc["matriculaVehiculoReference"] ?? '',
          fecha_inicio: doc["fecha_inicio"] ?? '',
          fecha_termino: doc["fecha_termino"] ?? '',
          estado: doc["estado"] ?? '',
        );
      }).toList();
    } catch (e) {
      print("Error al cargar ordenTrabajos: $e");
      return [];
    }
  }
}
