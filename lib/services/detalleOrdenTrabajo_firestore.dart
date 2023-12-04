// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taller_mecanico/models/servicio.dart';
import '../models/cliente.dart';
import '../models/detalleOrdenTrabajo.dart';
import '../models/mecanico.dart';
import '../models/ordenTrabajo.dart';
import '../models/vehiculo.dart';

class FirestoreService {
  final CollectionReference detalleOrdenTrabajoCollection =
      FirebaseFirestore.instance.collection("detallesOrdenesTrabajos");
  final CollectionReference ordenTrabajoCollection =
      FirebaseFirestore.instance.collection("ordenesTrabajos");
  final CollectionReference mecanicosCollection =
      FirebaseFirestore.instance.collection("mecanicos");
  final CollectionReference clientesCollection =
      FirebaseFirestore.instance.collection("clientes");

  Future<void> agregarDetalleOrdenTrabajo(
      DetalleOrdenTrabajo detalleOrdenTrabajo) async {
    // Verificamos si todas las referencias requeridas están presentes
    if (detalleOrdenTrabajo.idOrdTrabajoReference == null ||
        detalleOrdenTrabajo.idServicioReference == null ||
        detalleOrdenTrabajo.rutMecanicoReference == null) {
      print(
          "Error: Faltan referencias necesarias para el detalle de la orden de trabajo.");
      return; // Puedes manejar esto de acuerdo a tu lógica
    }

    // Convierte objetos DateTime a Timestamp
    Timestamp fechaInicio = detalleOrdenTrabajo.fecha_inicio;
    Timestamp fechaTermino = detalleOrdenTrabajo.fecha_termino;

    // Añadimos el detalle de la orden de trabajo a la colección correspondiente
    await detalleOrdenTrabajoCollection.add({
      "idOrdTrabajoReference": detalleOrdenTrabajo.idOrdTrabajoReference,
      "idServicioReference": detalleOrdenTrabajo.idServicioReference,
      "rutMecanicoReference": detalleOrdenTrabajo.rutMecanicoReference,
      "fecha_inicio": fechaInicio,
      "fecha_termino": fechaTermino,
      "estado": detalleOrdenTrabajo.estado,
      "costo": detalleOrdenTrabajo.costo,
    });
  }

  Future<List<DetalleOrdenTrabajo>> obtenerDetallesOrdenesTrabajos() async {
    try {
      QuerySnapshot detallesOrdenesTrabajosSnapshot =
          await detalleOrdenTrabajoCollection.get();

      // Mapeamos los documentos a objetos DetalleOrdenTrabajo
      List<DetalleOrdenTrabajo> detallesOrdenesTrabajos =
          detallesOrdenesTrabajosSnapshot.docs.map((doc) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        if (data == null) {
          throw StateError('Los datos del documento son nulos.');
        }

        DocumentReference? idOrdTrabajoRef = data['idOrdTrabajoReference'];
        DocumentReference? idServicioRef = data['idServicioReference'];
        DocumentReference? rutMecanicoRef = data['rutMecanicoReference'];

        if (idOrdTrabajoRef == null) {
          throw StateError(
              'El campo idOrdTrabajoReference no está presente en el documento.');
        }

        if (idServicioRef == null) {
          throw StateError(
              'El campo idServicioReference no está presente en el documento.');
        }

        if (rutMecanicoRef == null) {
          throw StateError(
              'El campo rutMecanicoReference no está presente en el documento.');
        }

        return DetalleOrdenTrabajo(
          idOrdTrabajoReference: idOrdTrabajoRef,
          idServicioReference: idServicioRef,
          rutMecanicoReference: rutMecanicoRef,
          fecha_inicio: data['fecha_inicio'] as Timestamp,
          fecha_termino: data['fecha_termino'] as Timestamp,
          estado: data['estado'] ?? '',
          costo: data['costo'] ?? 0, // Ajusta el valor predeterminado según tus necesidades
        );
      }).toList();

      return detallesOrdenesTrabajos;
    } catch (e) {
      print("Error al obtener detallesOrdenesTrabajos: $e");
      return []; // Puedes manejar el error según tus necesidades
    }
  }

  Future<void> actualizarDetalleOrdenTrabajo(String detalleOrdenTrabajoId,
      DetalleOrdenTrabajo detalleOrdenTrabajo) async {
    try {
      await detalleOrdenTrabajoCollection
          .doc(detalleOrdenTrabajoId)
          .update(detalleOrdenTrabajo.toJson());
      print("Vehículo actualizado con éxito.");
    } catch (e) {
      print("Error al actualizar detalle Orden Trabajo: $e");
    }
  }

  Future<void> eliminarDetalleOrdenTrabajo(String detalleOrdenTrabajoId) async {
    try {
      await detalleOrdenTrabajoCollection.doc(detalleOrdenTrabajoId).delete();
      print("Vehículo eliminado con éxito.");
    } catch (e) {
      print("Error al eliminar dedtalle orden trabajo: $e");
    }
  }
}

class DetallesOrdenesTrabajosDataTable extends StatefulWidget {
  final List<QueryDocumentSnapshot>? documentSnapshots;

  const DetallesOrdenesTrabajosDataTable({Key? key, this.documentSnapshots})
      : super(key: key);

  @override
  _DetallesOrdenesTrabajosDataTableState createState() =>
      _DetallesOrdenesTrabajosDataTableState();
}

class _DetallesOrdenesTrabajosDataTableState
    extends State<DetallesOrdenesTrabajosDataTable> {
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
            'ID ORDEN TRABAJO',
            (detalleOrdenTrabajo) =>
                detalleOrdenTrabajo.idOrdTrabajoReference.id,
          ),
          buildSortableHeader(
            'ID SERVICIO',
            (detalleOrdenTrabajo) => detalleOrdenTrabajo.idServicioReference.id,
          ),
          buildSortableHeader(
            'RUT MECANICO',
            (detalleOrdenTrabajo) =>
                detalleOrdenTrabajo.rutMecanicoReference.id,
          ),
          buildSortableHeader(
            'FECHA INICIO',
            (detalleOrdenTrabajo) => detalleOrdenTrabajo.fecha_inicio,
          ),
          buildSortableHeader(
            'FECHA TERMINO',
            (detalleOrdenTrabajo) => detalleOrdenTrabajo.fecha_termino,
          ),
          buildSortableHeader(
            'ESTADO',
            (detalleOrdenTrabajo) => detalleOrdenTrabajo.estado,
          ),
          buildSortableHeader(
            'COSTO',
            (detalleOrdenTrabajo) => detalleOrdenTrabajo.costo.toString(),
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
              final detalleOrdenTrabajo =
                  DetalleOrdenTrabajo.fromFirestore(documentSnapshot);

              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      detalleOrdenTrabajo.idOrdTrabajoReference.id,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GoMonoNerdFont',
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      detalleOrdenTrabajo.idServicioReference.id,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GoMonoNerdFont',
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      detalleOrdenTrabajo.rutMecanicoReference.id,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GoMonoNerdFont',
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      DateFormat('dd-MM-yyyy')
                          .format(detalleOrdenTrabajo.fecha_inicio.toDate()),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GoMonoNerdFont',
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      DateFormat('dd-MM-yyyy')
                          .format(detalleOrdenTrabajo.fecha_termino.toDate()),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GoMonoNerdFont',
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      detalleOrdenTrabajo.estado,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GoMonoNerdFont',
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      detalleOrdenTrabajo.costo.toString(),
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
                            // Usa el método adecuado para eliminar detalleOrdenTrabajo
                            FirestoreService().eliminarDetalleOrdenTrabajo(documentSnapshot.id);
                          },
                        ),
                        buildIconButton(
                          Icons.edit,
                          Color(0XFF004B85),
                          () {
                            // Usa el método adecuado para editar detalleOrdenTrabajo
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AgregarEditarDetalleOrdenTrabajoDialog(
                                  detalleOrdenTrabajo: detalleOrdenTrabajo,
                                  detalleOrdenTrabajoId: documentSnapshot.id,
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

  DataColumn buildSortableHeader(
      String label, dynamic Function(DetalleOrdenTrabajo) getValue) {
    return DataColumn(
      label: Text(label,
          style: TextStyle(
              fontSize: 17.5,
              fontFamily: 'SpaceMonoNerdFont',
              fontWeight: FontWeight.bold)),
      onSort: (columnIndex, ascending) {
        // Lógica de clasificación aquí
      },
    );
  }

  String formatDate(DateTime date) {
    if (date == null) {
      return ""; // o algún otro valor predeterminado si la fecha es nula
    }
    return DateFormat('dd-MM-yyyy').format(date);
  }

  IconButton buildIconButton(
      IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon),
      color: color,
      onPressed: onPressed,
    );
  }

  void _resetSorting() {
    setState(() {
      _currentSortColumnIndex = 0;
      _currentSortAscending = true;
    });
  }

  void _sort<T>(
      String Function(DetalleOrdenTrabajo detalleOrdenTrabajo) getField,
      int columnIndex,
      bool ascending) {
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
      var aValue = getField(DetalleOrdenTrabajo.fromFirestore(a));
      var bValue = getField(DetalleOrdenTrabajo.fromFirestore(b));

      if (!ascending) {
        var temp = aValue;
        aValue = bValue;
        bValue = temp;
      }

      // Comparar los valores según el tipo de dato
      if (aValue is DateTime && bValue is DateTime) {
        final comparison = aValue.compareTo(bValue);
        return _currentSortAscending ? comparison : -comparison;
      } else {
        // Si no son DateTime, simplemente comparar como cadenas
        final comparison = aValue.toString().compareTo(bValue.toString());
        return _currentSortAscending ? comparison : -comparison;
      }
    });
  }
}

class AgregarEditarDetalleOrdenTrabajoDialog extends StatefulWidget {
  final DetalleOrdenTrabajo? detalleOrdenTrabajo;
  final String? detalleOrdenTrabajoId;

  AgregarEditarDetalleOrdenTrabajoDialog(
      {this.detalleOrdenTrabajo, this.detalleOrdenTrabajoId});

  @override
  _AgregarEditarDetalleOrdenTrabajoDialogState createState() =>
      _AgregarEditarDetalleOrdenTrabajoDialogState();
}

class _AgregarEditarDetalleOrdenTrabajoDialogState
    extends State<AgregarEditarDetalleOrdenTrabajoDialog> {
  bool _isDisposed = false;
  final TextEditingController idOrdTrabajoReferenceController =
      TextEditingController();
  final TextEditingController idServicioReferenceController =
      TextEditingController();
  final TextEditingController rutMecanicoReferenceController =
      TextEditingController();
  final TextEditingController fechaInicioController = TextEditingController();
  final TextEditingController fechaTerminoController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();
  final TextEditingController costoController = TextEditingController();

  Future<void> _seleccionarMecanico(BuildContext context) async {
    final mecanicoSeleccionado = await showDialog<Mecanico>(
      context: context,
      builder: (BuildContext context) {
        return MecanicoSeleccionDialog();
      },
    );

    if (mecanicoSeleccionado != null) {
      setState(() {
        rutMecanicoReferenceController.text = mecanicoSeleccionado.rut_mecanico;
      });
    }
  }

  Future<void> _seleccionarServicio(BuildContext context) async {
    final servicioSeleccionado = await showDialog<Servicio>(
      context: context,
      builder: (BuildContext context) {
        return ServiciosSeleccionDialog();
      },
    );

    if (servicioSeleccionado != null) {
      setState(() {
        idServicioReferenceController.text = servicioSeleccionado.id_servicio;
      });
    }
  }

  Future<void> _seleccionarOrdenTrabajo(BuildContext context) async {
    final ordenTrabajoSeleccionado = await showDialog<OrdenTrabajo>(
      context: context,
      builder: (BuildContext context) {
        return OrdenesTrabajosSeleccionDialog();
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
  void dispose() {
    idOrdTrabajoReferenceController.dispose();
    idServicioReferenceController.dispose();
    rutMecanicoReferenceController.dispose();
    fechaInicioController.dispose();
    fechaTerminoController.dispose();
    estadoController.dispose();
    costoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Inicializar controladores con la información del vehículo si está disponible
    if (widget.detalleOrdenTrabajo != null) {
      idOrdTrabajoReferenceController.text =
          widget.detalleOrdenTrabajo!.idOrdTrabajoReference.id;
      idServicioReferenceController.text =
          widget.detalleOrdenTrabajo!.idServicioReference.id;
      rutMecanicoReferenceController.text =
          widget.detalleOrdenTrabajo!.rutMecanicoReference.id;
      fechaInicioController.text = DateFormat('dd-MM-yyyy')
          .format(widget.detalleOrdenTrabajo!.fecha_inicio.toDate());
      fechaTerminoController.text = DateFormat('dd-MM-yyyy')
          .format(widget.detalleOrdenTrabajo!.fecha_termino.toDate());

      estadoController.text = widget.detalleOrdenTrabajo!.estado;
      costoController.text = widget.detalleOrdenTrabajo!.costo.toString();
    }

    return AlertDialog(
      title: Text('Agregar Nuevo Detalle de Orden de Trabajo'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: textField(
                      "ID Orden de Trabajo", idOrdTrabajoReferenceController,
                      enabled: false),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _seleccionarOrdenTrabajo(context);
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: textField("ID Servicio", idServicioReferenceController,
                      enabled: false),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _seleccionarServicio(context);
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: textField(
                      "Rut Mecanico", rutMecanicoReferenceController,
                      enabled: false),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _seleccionarMecanico(context);
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: textField("Fecha inicio", fechaInicioController),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    _seleccionarFecha(context, fechaInicioController);
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: textField("Fecha Termino", fechaTerminoController),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    _seleccionarFecha(context, fechaTerminoController);
                  },
                ),
              ],
            ),
            textField("Costo", costoController),
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
              if (widget.detalleOrdenTrabajo != null) {
                // Lógica para editar el detalle de la orden de trabajo existente en Firebase
                editarDetalleOrdenTrabajoExistente();
              } else {
                // Lógica para agregar el nuevo detalle de la orden de trabajo a Firebase
                agregarNuevoDetalleOrdenTrabajo();
              }
              Navigator.pop(context); // Cierra el cuadro de diálogo
            } else {
              // Muestra un mensaje de error si hay campos vacíos
              mostrarErrorCamposVacios();
            }
          },
          child:
              Text(widget.detalleOrdenTrabajo != null ? 'Editar' : 'Agregar'),
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

  bool camposValidos() {
    // Verifica que todos los campos estén llenos
    return fechaInicioController.text.isNotEmpty &&
        fechaTerminoController.text.isNotEmpty &&
        estadoController.text.isNotEmpty &&
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

  Future<void> agregarNuevoDetalleOrdenTrabajo() async {
    try {
      // Obtener una referencia a la colección "detalleOrdenesTrabajo" en Firebase
      final detalleOrdenesTrabajoCollection =
          FirebaseFirestore.instance.collection("detallesOrdenesTrabajos");

      

      // Obtén las referencias basadas en los IDs proporcionados
      final idOrdTrabajoReference = FirebaseFirestore.instance
          .collection('ordenesTrabajos')
          .doc(idOrdTrabajoReferenceController.text);

      final idServicioReference = FirebaseFirestore.instance
          .collection('servicios')
          .doc(idServicioReferenceController.text);

      final rutMecanicoReference = FirebaseFirestore.instance
          .collection('mecanicos')
          .doc(rutMecanicoReferenceController.text);

      // Convierte las fechas de texto a objetos DateTime
      DateTime fechaInicio =
          DateFormat('dd-MM-yyyy').parse(fechaInicioController.text);
      DateTime fechaTermino =
          DateFormat('dd-MM-yyyy').parse(fechaTerminoController.text);

      // Convierte las fechas de DateTime a Timestamp
      Timestamp fechaInicioTimestamp = Timestamp.fromDate(fechaInicio);
      Timestamp fechaTerminoTimestamp = Timestamp.fromDate(fechaTermino);
      int costo = int.parse(costoController.text);
      

      // Agregar el nuevo detalle de orden de trabajo a Firebase
      await detalleOrdenesTrabajoCollection.add({
        "idOrdTrabajoReference": idOrdTrabajoReference,
        "idServicioReference": idServicioReference,
        "rutMecanicoReference": rutMecanicoReference,
        "fecha_inicio": fechaInicioTimestamp,
        "fecha_termino": fechaTerminoTimestamp,
        "estado": estadoController.text,
        "costo": costo,
      });

      print(
          "Nuevo detalle orden de trabajo agregado con éxito a Firebase");
    } catch (e) {
      print("Error al agregar detalle de orden de trabajo a Firebase: $e");
    }
  }

  void editarDetalleOrdenTrabajoExistente() async {
    try {
      // Obtener la referencia al documento del detalle de orden de trabajo en Firebase
      final detalleOrdenTrabajoRef = FirebaseFirestore.instance
          .collection("detallesOrdenesTrabajos")
          .doc(widget.detalleOrdenTrabajo?.idOrdTrabajoReference.id);

      // Convertir las fechas de texto a objetos DateTime
      DateTime fechaInicio =
          DateFormat('dd-MM-yyyy').parse(fechaInicioController.text);
      DateTime fechaTermino =
          DateFormat('dd-MM-yyyy').parse(fechaTerminoController.text);

      // Convertir las fechas de DateTime a Timestamp
      Timestamp fechaInicioTimestamp = Timestamp.fromDate(fechaInicio);
      Timestamp fechaTerminoTimestamp = Timestamp.fromDate(fechaTermino);

      // Obtener las referencias reales a los documentos correspondientes
      final idServicioReference = FirebaseFirestore.instance
          .collection('servicios')
          .doc(idServicioReferenceController.text);

      final rutMecanicoReference = FirebaseFirestore.instance
          .collection('mecanicos')
          .doc(rutMecanicoReferenceController.text);
      int costo = int.parse(costoController.text);

      // Actualizar la información del detalle de orden de trabajo en Firebase
      await detalleOrdenTrabajoRef.update({
        "idServicioReference": idServicioReference,
        "rutMecanicoReference": rutMecanicoReference,
        "fecha_inicio": fechaInicioTimestamp,
        "fecha_termino": fechaTerminoTimestamp,
        "costo": costo,
        "estado": estadoController.text,
      });

      // Actualizar los controladores de texto y forzar la reconstrucción del widget
      setState(() {
        fechaInicioController.text =
            DateFormat('dd-MM-yyyy').format(fechaInicio);
        fechaTerminoController.text =
            DateFormat('dd-MM-yyyy').format(fechaTermino);
      });

      print("Detalle de orden de trabajo editado con éxito en Firebase.");
    } catch (e) {
      print("Error al editar detalle de orden de trabajo en Firebase: $e");
    }
  }
}

class MecanicoSeleccionDialog extends StatefulWidget {
  @override
  _MecanicoSeleccionDialogState createState() =>
      _MecanicoSeleccionDialogState();
}

class _MecanicoSeleccionDialogState extends State<MecanicoSeleccionDialog> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Seleccionar Mecanico'),
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
                labelText: 'Buscar Mecanico',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  // Actualiza la lista de clientes basándose en el término de búsqueda
                  // Puedes utilizar la función de búsqueda en tu lista original
                });
              },
            ),
            Expanded(
              child: FutureBuilder<List<Mecanico>>(
                future: cargarMecanicos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            'Error al cargar mecánicos: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No hay mecánicos disponibles.'));
                  } else {
                    // Filtra la lista de mecánicos según el término de búsqueda
                    final filteredMecanicos = snapshot.data!
                        .where((mecanico) =>
                            mecanico.nom_mecanico.toLowerCase().contains(
                                searchController.text.toLowerCase()) ||
                            mecanico.ape_mecanico.toLowerCase().contains(
                                searchController.text.toLowerCase()) ||
                            mecanico.rut_mecanico
                                .toLowerCase()
                                .contains(searchController.text.toLowerCase()))
                        .toList();

                    return ListView.builder(
                      itemCount: filteredMecanicos.length,
                      itemBuilder: (context, index) {
                        final mecanico = filteredMecanicos[index];
                        return ListTile(
                          title: Text(
                              " ${mecanico.nom_mecanico} ${mecanico.ape_mecanico} ${mecanico.rut_mecanico}"),
                          onTap: () {
                            Navigator.pop(context, mecanico);
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

  Future<List<Mecanico>> cargarMecanicos() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection("mecanicos").get();

      return snapshot.docs.map((doc) {
        return Mecanico(
          id: doc.id,
          rut_mecanico: doc["rut_mecanico"] ?? '',
          nom_mecanico: doc["nom_mecanico"] ?? '',
          ape_mecanico: doc["ape_mecanico"] ?? '',
          email_mecanico: doc["email_mecanico"] ?? '',
        );
      }).toList();
    } catch (e) {
      print("Error al cargar mecanico: $e");
      return [];
    }
  }
}

class ServiciosSeleccionDialog extends StatefulWidget {
  @override
  _ServiciosSeleccionDialogState createState() =>
      _ServiciosSeleccionDialogState();
}

class _ServiciosSeleccionDialogState extends State<ServiciosSeleccionDialog> {
  TextEditingController searchController = TextEditingController();

  Future<List<Servicio>> cargarServicios() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection("servicios").get();

      return snapshot.docs.map((doc) {
        return Servicio(
          id_servicio: doc[
              "id_servicio"], // Utiliza el ID del documento como ID del servicio
          descripcion: doc["descripcion"] ?? '',
          costo: doc["costo"] ?? 0,
        );
      }).toList();
    } catch (e) {
      print("Error al cargar servicios: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Seleccionar Servicio'),
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
                labelText: 'Buscar servicio',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  // Actualiza la lista de servicios basándose en el término de búsqueda
                  // Puedes utilizar la función de búsqueda en tu lista original
                });
              },
            ),
            Expanded(
              child: FutureBuilder<List<Servicio>>(
                future: cargarServicios(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            'Error al cargar servicios: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No hay servicios disponibles.'));
                  } else {
                    // Filtra la lista de servicios según el término de búsqueda
                    final filteredServicios = snapshot.data!
                        .where((servicio) =>
                            servicio.descripcion.toLowerCase().contains(
                                searchController.text.toLowerCase()) ||
                            servicio.id_servicio
                                .toLowerCase()
                                .contains(searchController.text.toLowerCase()))
                        .toList();

                    return ListView.builder(
                      itemCount: filteredServicios.length,
                      itemBuilder: (context, index) {
                        final servicio = filteredServicios[index];
                        return ListTile(
                          title: Text(
                              "${servicio.id_servicio} ${servicio.descripcion}"),
                          onTap: () {
                            Navigator.pop(context, servicio);
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
}

class OrdenesTrabajosSeleccionDialog extends StatefulWidget {
  @override
  _OrdenesTrabajosSeleccionDialogState createState() =>
      _OrdenesTrabajosSeleccionDialogState();
}

class _OrdenesTrabajosSeleccionDialogState
    extends State<OrdenesTrabajosSeleccionDialog> {
  TextEditingController searchController = TextEditingController();

  Future<List<OrdenTrabajo>> cargarOrdenesTrabajos() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection("ordenesTrabajos").get();

      return snapshot.docs.map((doc) {
        return OrdenTrabajo(
          id_ord_trabajo: doc["id_ord_trabajo"],
          rutReference: doc["rutReference"],
          matriculaVehiculoReference: doc["matriculaVehiculoReference"],
          fecha_inicio: doc["fecha_inicio"] as Timestamp,
          fecha_termino: doc["fecha_termino"] as Timestamp,
          estado: doc["estado"] ?? '',
        );
      }).toList();
    } catch (e) {
      print("Error al cargar ordenes de trabajo: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Seleccionar Orden de Trabajo'),
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
                labelText: 'Buscar Orden de Trabajo',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  // Actualiza la lista de servicios basándose en el término de búsqueda
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
                            'Error al cargar ordenes de trabajo: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text('No hay ordenes de trabajo disponibles.'));
                  } else {
                    // Filtra la lista de ordenes de trabajo según el término de búsqueda
                    final filteredOrdenesTrabajos = snapshot.data!
                        .where((ordenTrabajo) =>
                            ordenTrabajo.rutReference
                                .toString()
                                .toLowerCase()
                                .contains(
                                    searchController.text.toLowerCase()) ||
                            ordenTrabajo.matriculaVehiculoReference
                                .toString()
                                .toLowerCase()
                                .contains(
                                    searchController.text.toLowerCase()) ||
                            ordenTrabajo.id_ord_trabajo
                                .toLowerCase()
                                .contains(searchController.text.toLowerCase()))
                        .toList();

                    return ListView.builder(
                      itemCount: filteredOrdenesTrabajos.length,
                      itemBuilder: (context, index) {
                        final ordenTrabajo = filteredOrdenesTrabajos[index];
                        return ListTile(
                          title: Text(
                              "${ordenTrabajo.id_ord_trabajo} ${ordenTrabajo.rutReference} ${ordenTrabajo.matriculaVehiculoReference}"),
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
}
