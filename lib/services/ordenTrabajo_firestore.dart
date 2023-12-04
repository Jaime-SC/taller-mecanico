// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cliente.dart';
import '../models/ordenTrabajo.dart';
import '../models/vehiculo.dart';

class FirestoreService {
  final CollectionReference vehiculosCollection =
      FirebaseFirestore.instance.collection("vehiculos");
  final CollectionReference ordenTrabajoCollection =
      FirebaseFirestore.instance.collection("ordenesTrabajos");
  final CollectionReference clientesCollection =
      FirebaseFirestore.instance.collection("clientes");

  Future<void> agregarOrdenTrabajo(OrdenTrabajo ordenTrabajo) async {
    // Verificamos si el vehículo tiene una referencia de cliente
    if (ordenTrabajo.rutReference == null ||
        ordenTrabajo.matriculaVehiculoReference == null) {
      print(
          "Error: El vehículo no tiene una referencia de cliente o matrícula.");
      return; // Puedes manejar esto de acuerdo a tu lógica
    }

    // Convierte objetos DateTime a Timestamp
    Timestamp fechaInicio =
        Timestamp.fromDate(ordenTrabajo.fecha_inicio as DateTime);
    Timestamp fechaTermino =
        Timestamp.fromDate(ordenTrabajo.fecha_termino as DateTime);

    // Y finalmente, añadimos el vehículo a la colección de vehículos con la referencia del cliente
    await ordenTrabajoCollection.add({
      "rutReference": ordenTrabajo.rutReference,
      "matriculaVehiculoReference": ordenTrabajo.matriculaVehiculoReference,
      "fecha_inicio": fechaInicio,
      "fecha_termino": fechaTermino,
      "estado": ordenTrabajo.estado,
    });
  }

  Future<List<OrdenTrabajo>> obtenerOrdenesTrabajos() async {
    try {
      QuerySnapshot ordenesTrabajosSnapshot =
          await ordenTrabajoCollection.get();

      // Mapeamos los documentos a objetos OrdenTrabajo
      List<OrdenTrabajo> ordenesTrabajos =
          ordenesTrabajosSnapshot.docs.map((doc) {
        return OrdenTrabajo(
          id_ord_trabajo: doc["ud_ord_trabajo"],
          rutReference: doc["rutReference"],
          matriculaVehiculoReference: doc["matriculaVehiculoReference"],
          fecha_inicio: doc["fecha_inicio"] as Timestamp,
          fecha_termino: doc["fecha_termino"] as Timestamp,

          estado: doc["estado"],
          // Incluye otras propiedades del vehículo
        );
      }).toList();

      return ordenesTrabajos;
    } catch (e) {
      print("Error al obtener vehículos: $e");
      return []; // Puedes manejar el error según tus necesidades
    }
  }

  Future<void> actualizarOrdenTrabajo(
      String ordenTrabajoId, OrdenTrabajo ordenTrabajo) async {
    try {
      await ordenTrabajoCollection
          .doc(ordenTrabajoId)
          .update(ordenTrabajo.toJson());
      print("Vehículo actualizado con éxito.");
    } catch (e) {
      print("Error al actualizar vehículo: $e");
    }
  }

  Future<void> eliminarOrdenTrabajo(String ordenTrabajoId) async {
    try {
      await ordenTrabajoCollection.doc(ordenTrabajoId).delete();
      print("Vehículo eliminado con éxito.");
    } catch (e) {
      print("Error al eliminar vehículo: $e");
    }
  }
}

class OrdenesTrabajosDataTable extends StatefulWidget {
  final List<QueryDocumentSnapshot>? documentSnapshots;

  const OrdenesTrabajosDataTable({Key? key, this.documentSnapshots})
      : super(key: key);

  @override
  _OrdenesTrabajosDataTableState createState() =>
      _OrdenesTrabajosDataTableState();
}

class _OrdenesTrabajosDataTableState extends State<OrdenesTrabajosDataTable> {
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
          buildSortableHeader('ID ORDEN TRABAJO',
              (ordenTrabajo) => ordenTrabajo.id_ord_trabajo),
          buildSortableHeader(
              'RUT CLIENTE', (ordenTrabajo) => ordenTrabajo.rutReference.id),
          buildSortableHeader(
              'MATRICULA VEHICULO',
              (ordenTrabajo) => ordenTrabajo.matriculaVehiculoReference
                  .id), // Accede al ID de la referencia`

          buildSortableHeader(
              'FECHA INICIO', (ordenTrabajo) => ordenTrabajo.fecha_inicio),
          buildSortableHeader(
              'FECHO TERMINO', (ordenTrabajo) => ordenTrabajo.fecha_termino),
          buildSortableHeader('ESTADO', (ordenTrabajo) => ordenTrabajo.estado),

          DataColumn(
            label: Text('ACCIONES',
                style: TextStyle(
                    fontSize: 17.5,
                    fontFamily: 'SpaceMonoNerdFont',
                    fontWeight: FontWeight.bold)),
          ),
        ],
        rows: widget.documentSnapshots?.map((documentSnapshot) {
              final ordenTrabajo = OrdenTrabajo(
                id_ord_trabajo: documentSnapshot["id_ord_trabajo"] ?? "",
                rutReference: documentSnapshot["rutReference"],
                matriculaVehiculoReference:
                    documentSnapshot["matriculaVehiculoReference"],
                fecha_inicio: documentSnapshot["fecha_inicio"] ?? "",
                fecha_termino: documentSnapshot["fecha_termino"] ?? "",
                estado: documentSnapshot["estado"] ?? "",
              );

              return DataRow(
                cells: [
                  DataCell(Text(ordenTrabajo.id_ord_trabajo,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoMonoNerdFont'))),
                  DataCell(Text(ordenTrabajo.rutReference.id,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoMonoNerdFont'))),
                  DataCell(Text(ordenTrabajo.matriculaVehiculoReference.id,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoMonoNerdFont'))),
                  DataCell(Text(
                      DateFormat('dd-MM-yyyy')
                          .format(ordenTrabajo.fecha_inicio.toDate()),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoMonoNerdFont'))),
                  DataCell(Text(
                      DateFormat('dd-MM-yyyy')
                          .format(ordenTrabajo.fecha_termino.toDate()),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoMonoNerdFont'))),
                  DataCell(Text(ordenTrabajo.estado,
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
                                .eliminarOrdenTrabajo(documentSnapshot.id);
                          },
                        ),
                        buildIconButton(
                          Icons.edit,
                          Color(0XFF004B85),
                          () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AgregarEditarOrdenTrabajoDialog(
                                  ordenTrabajo: ordenTrabajo,
                                  ordenTrabajoId: documentSnapshot.id,
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
    String label,
    Function(OrdenTrabajo) getField,
  ) {
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 17.5,
          fontFamily: 'SpaceMonoNerdFont',
          fontWeight: FontWeight.bold,
        ),
      ),
      onSort: (columnIndex, ascending) {
        _sort<String>(
          (ordenTrabajo) => formatDate(getField(ordenTrabajo)),
          columnIndex,
          ascending,
        );
      },
    );
  }

  String formatDate(DateTime date) {
    if (date == null) {
      return ""; // o algún otro valor predeterminado si la fecha es nula
    }
    return DateFormat('dd-MM-yyyy').format(date);
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

  void _sort<T>(String Function(OrdenTrabajo ordenTrabajo) getField,
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
      var aValue = getField(OrdenTrabajo(
        id_ord_trabajo: a["id_ord_trabajo"] ?? "",
        rutReference: a["rutReference"],
        matriculaVehiculoReference: a["matriculaVehiculoReference"],
        fecha_inicio: a["fecha_inicio"] ?? "",
        fecha_termino: a["fecha_termino"] ?? "",
        estado: a["estado"] ?? "",
      ));
      var bValue = getField(OrdenTrabajo(
        id_ord_trabajo: b["id_ord_trabajo"] ?? "",
        rutReference: b["rutReference"],
        matriculaVehiculoReference: b["matriculaVehiculoReference"],
        fecha_inicio: b["fecha_inicio"] ?? "",
        fecha_termino: b["fecha_termino"] ?? "",
        estado: b["estado"] ?? "",
      ));

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

class AgregarEditarOrdenTrabajoDialog extends StatefulWidget {
  final OrdenTrabajo? ordenTrabajo;
  final String? ordenTrabajoId;

  AgregarEditarOrdenTrabajoDialog({this.ordenTrabajo, this.ordenTrabajoId});

  @override
  _AgregarEditarOrdenTrabajoDialogState createState() =>
      _AgregarEditarOrdenTrabajoDialogState();
}

class _AgregarEditarOrdenTrabajoDialogState
    extends State<AgregarEditarOrdenTrabajoDialog> {
  bool _isDisposed = false;
  final TextEditingController idOrdenTrabajoController =
      TextEditingController();
  final TextEditingController rutReferenceController = TextEditingController();
  final TextEditingController matriculaVehiculoReferenceController =
      TextEditingController();
  final TextEditingController fechaInicioController = TextEditingController();
  final TextEditingController fechaTerminoController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();
  final TextEditingController matriculaSeleccionadoController =
      TextEditingController();
  final TextEditingController clienteSeleccionadoController =
      TextEditingController();
  final TextEditingController fechaInicioSeleccionadaController =
      TextEditingController();
  final TextEditingController fechaTerminoSeleccionadaController =
      TextEditingController();

  Future<void> _seleccionarCliente(BuildContext context) async {
    final clienteSeleccionado = await showDialog<Cliente>(
      context: context,
      builder: (BuildContext context) {
        return ClienteSeleccionDialog();
      },
    );

    if (clienteSeleccionado != null) {
      setState(() {
        clienteSeleccionadoController.text = clienteSeleccionado.rut_cliente;
      });
    }
  }

  Future<void> _seleccionarVehiculo(BuildContext context) async {
    final vehiculoSeleccionado = await showDialog<Vehiculo>(
      context: context,
      builder: (BuildContext context) {
        return VehiculosSeleccionDialog();
      },
    );

    if (vehiculoSeleccionado != null) {
      setState(() {
        matriculaSeleccionadoController.text =
            vehiculoSeleccionado.matricula_vehiculo;
      });
    }
  }

  @override
  void dispose() {
    idOrdenTrabajoController.dispose();
    rutReferenceController.dispose();
    matriculaVehiculoReferenceController.dispose();
    fechaInicioController.dispose();
    fechaTerminoController.dispose();
    estadoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Inicializar controladores con la información del vehículo si está disponible
    if (widget.ordenTrabajo != null) {
      idOrdenTrabajoController.text = widget.ordenTrabajo!.id_ord_trabajo;
      rutReferenceController.text = widget.ordenTrabajo!.rutReference.id;
      matriculaVehiculoReferenceController.text =
          widget.ordenTrabajo!.matriculaVehiculoReference.id;
      fechaInicioController.text = DateFormat('dd-MM-yyyy')
          .format(widget.ordenTrabajo!.fecha_inicio.toDate());
      fechaTerminoController.text = DateFormat('dd-MM-yyyy')
          .format(widget.ordenTrabajo!.fecha_termino.toDate());

      estadoController.text = widget.ordenTrabajo!.estado;
    }

    return AlertDialog(
      title: Text('Agregar Nuevo OrdenTrabajo'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: textField("Rut Cliente", clienteSeleccionadoController,
                      enabled: false),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    // Abre el diálogo de selección de clientes
                    _seleccionarCliente(context);
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: textField(
                      "Matricula Vehiculo", matriculaSeleccionadoController,
                      enabled: false),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    // Abre el diálogo de selección de clientes
                    _seleccionarVehiculo(context);
                  },
                ),
              ],
            ),
            // Fecha de inicio
            Row(
              children: [
                Expanded(
                  child: textField(
                      "Fecha inicio", fechaInicioSeleccionadaController),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    _seleccionarFecha(
                        context, fechaInicioSeleccionadaController);
                  },
                ),
              ],
            ),

            // Fecha de término
            Row(
              children: [
                Expanded(
                  child: textField("Fecha Termino", fechaTerminoSeleccionadaController),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    _seleccionarFecha(context, fechaTerminoSeleccionadaController);
                  },
                ),
              ],
            ),
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
              if (widget.ordenTrabajo != null) {
                // Lógica para editar el vehículo existente en Firebase
                editarOrdenTrabajoExistente();
              } else {
                // Lógica para agregar el nuevo vehículo a Firebase
                agregarNuevoOrdenTrabajo();
              }
              Navigator.pop(context); // Cierra el cuadro de diálogo
            } else {
              // Muestra un mensaje de error si hay campos vacíos
              mostrarErrorCamposVacios();
            }
          },
          child: Text(widget.ordenTrabajo != null ? 'Editar' : 'Agregar'),
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
    return 
        clienteSeleccionadoController.text.isNotEmpty &&
        matriculaSeleccionadoController.text.isNotEmpty &&
        fechaInicioSeleccionadaController.text.isNotEmpty &&
        fechaTerminoSeleccionadaController.text.isNotEmpty &&
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

  Future<void> agregarNuevoOrdenTrabajo() async {
    try {
      // Obtener una referencia a la colección "ordenesTrabajos" en Firebase
      final ordenesTrabajosCollection =
          FirebaseFirestore.instance.collection("ordenesTrabajos");

      // Obtener el último documento ordenado por id_ord_trabajo de forma descendente
      QuerySnapshot ultimaOrden = await ordenesTrabajosCollection
          .orderBy('id_ord_trabajo', descending: true)
          .limit(1)
          .get();

      int ultimoValor = 0;

      // Verificar si hay algún documento en la colección
      if (ultimaOrden.docs.isNotEmpty) {
        // Obtener el último valor de id_ord_trabajo y aumentarlo en 1
        ultimoValor = int.parse(ultimaOrden.docs.first['id_ord_trabajo']
            .toString()
            .replaceAll('ORD-', ''));
      }

      // Generar el próximo código
      String nuevoCodigo =
          'ORD-${(ultimoValor + 1).toString().padLeft(2, '0')}';

      // Obtén la referencia del cliente basada en el ID proporcionado
      final rutReference = FirebaseFirestore.instance
          .collection('clientes')
          .doc(rutReferenceController.text);

      final matriculaVehiculoReference = FirebaseFirestore.instance
          .collection('vehiculos')
          .doc(matriculaVehiculoReferenceController.text);

      // Convierte las fechas de texto a objetos DateTime
      DateTime fechaInicio =
          DateFormat('dd-MM-yyyy').parse(fechaInicioController.text);
      DateTime fechaTermino =
          DateFormat('dd-MM-yyyy').parse(fechaTerminoController.text);

      // Convierte las fechas de DateTime a Timestamp
      Timestamp fechaInicioTimestamp = Timestamp.fromDate(fechaInicio);
      Timestamp fechaTerminoTimestamp = Timestamp.fromDate(fechaTermino);

      // Agregar el nuevo vehículo a Firebase
      await ordenesTrabajosCollection.add({
        "id_ord_trabajo": nuevoCodigo,
        "matriculaVehiculoReference": matriculaVehiculoReference,
        "rutReference": rutReference,
        "fecha_inicio": fechaInicioTimestamp,
        "fecha_termino": fechaTerminoTimestamp,
        "estado": estadoController.text,
      });

      print(
          "Nuevo orden de trabajo agregado con éxito a Firebase. Código: $nuevoCodigo");
    } catch (e) {
      print("Error al agregar orden de trabajo a Firebase: $e");
    }
  }

  void editarOrdenTrabajoExistente() async {
    try {
      // Obtener la referencia al documento de la orden de trabajo en Firebase
      final ordenTrabajoRef = FirebaseFirestore.instance
          .collection("ordenesTrabajos")
          .doc(widget.ordenTrabajoId);

      // Convertir las fechas de texto a objetos DateTime
      DateTime fechaInicio = DateFormat('dd-MM-yyyy')
          .parse(fechaInicioSeleccionadaController.text);
      DateTime fechaTermino =
          DateFormat('dd-MM-yyyy').parse(fechaTerminoSeleccionadaController.text);

      // Convertir las fechas de DateTime a Timestamp
      Timestamp fechaInicioTimestamp = Timestamp.fromDate(fechaInicio);
      Timestamp fechaTerminoTimestamp = Timestamp.fromDate(fechaTermino);

      // Obtener las referencias reales a los documentos correspondientes
      final rutReference = FirebaseFirestore.instance
          .collection('clientes')
          .doc(clienteSeleccionadoController.text);

      final matriculaVehiculoReference = FirebaseFirestore.instance
          .collection('vehiculos')
          .doc(matriculaSeleccionadoController.text);

      // Actualizar la información de la orden de trabajo en Firebase
      await ordenTrabajoRef.update({
        "rutReference": rutReference,
        "matriculaVehiculoReference": matriculaVehiculoReference,
        "fecha_inicio": fechaInicioTimestamp,
        "fecha_termino": fechaTerminoTimestamp,
        "estado": estadoController.text,
      });

      // Actualizar los controladores de texto y forzar la reconstrucción del widget
      setState(() {
        fechaInicioController.text =
            DateFormat('dd-MM-yyyy').format(fechaInicio);
        fechaTerminoController.text =
            DateFormat('dd-MM-yyyy').format(fechaTermino);
      });

      print("Orden de trabajo editada con éxito en Firebase.");
    } catch (e) {
      print("Error al editar orden de trabajo en Firebase: $e");
    }
  }
}

class ClienteSeleccionDialog extends StatefulWidget {
  @override
  _ClienteSeleccionDialogState createState() => _ClienteSeleccionDialogState();
}

class _ClienteSeleccionDialogState extends State<ClienteSeleccionDialog> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Seleccionar Cliente'),
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
                labelText: 'Buscar cliente',
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
              child: FutureBuilder<List<Cliente>>(
                future: cargarClientes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            'Error al cargar clientes: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No hay clientes disponibles.'));
                  } else {
                    // Filtra la lista de clientes según el término de búsqueda
                    final filteredClientes = snapshot.data!
                        .where((cliente) =>
                            cliente.nom_cliente.toLowerCase().contains(
                                searchController.text.toLowerCase()) ||
                            cliente.ape_cliente.toLowerCase().contains(
                                searchController.text.toLowerCase()) ||
                            cliente.rut_cliente
                                .toLowerCase()
                                .contains(searchController.text.toLowerCase()))
                        .toList();

                    return ListView.builder(
                      itemCount: filteredClientes.length,
                      itemBuilder: (context, index) {
                        final cliente = filteredClientes[index];
                        return ListTile(
                          title: Text(
                              " ${cliente.nom_cliente} ${cliente.ape_cliente} ${cliente.rut_cliente}"),
                          onTap: () {
                            Navigator.pop(context, cliente);
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

  Future<List<Cliente>> cargarClientes() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection("clientes").get();

      return snapshot.docs.map((doc) {
        return Cliente(
          id: doc.id,
          rut_cliente: doc["rut_cliente"] ?? '',
          nom_cliente: doc["nom_cliente"] ?? '',
          ape_cliente: doc["ape_cliente"] ?? '',
          dir_cliente: doc["dir_cliente"] ?? '',
          tel_cliente: doc["tel_cliente"] ?? '',
          email_cliente: doc["email_cliente"] ?? '',
        );
      }).toList();
    } catch (e) {
      print("Error al cargar clientes: $e");
      return [];
    }
  }
}

class VehiculosSeleccionDialog extends StatefulWidget {
  @override
  _VehiculosSeleccionDialogState createState() =>
      _VehiculosSeleccionDialogState();
}

class _VehiculosSeleccionDialogState extends State<VehiculosSeleccionDialog> {
  TextEditingController searchController = TextEditingController();

  Future<List<Vehiculo>> cargarVehiculos() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection("vehiculos").get();

      return snapshot.docs.map((doc) {
        return Vehiculo(
          //id: doc.id,
          matricula_vehiculo: doc["matricula_vehiculo"] ?? '',
          clienteReference: doc["clienteReference"] ?? '',
          marca: doc["marca"] ?? '',
          modelo: doc["modelo"] ?? '',
          anio: doc["anio"] ?? '',
        );
      }).toList();
    } catch (e) {
      print("Error al cargar clientes: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Seleccionar Cliente'),
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
                labelText: 'Buscar cliente',
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
              child: FutureBuilder<List<Vehiculo>>(
                future: cargarVehiculos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            'Error al cargar clientes: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No hay clientes disponibles.'));
                  } else {
                    // Filtra la lista de clientes según el término de búsqueda
                    final filteredVehiculos = snapshot.data!
                        .where((vehiculo) =>
                            vehiculo.matricula_vehiculo.toLowerCase().contains(
                                searchController.text.toLowerCase()) ||
                            vehiculo.clienteReference
                                .toString()
                                .toLowerCase()
                                .contains(searchController.text.toLowerCase()))
                        .toList();

                    return ListView.builder(
                      itemCount: filteredVehiculos.length,
                      itemBuilder: (context, index) {
                        final vehiculo = filteredVehiculos[index];
                        return ListTile(
                          title: Text(
                              "${vehiculo.matricula_vehiculo} ${vehiculo.clienteReference}"),
                          onTap: () {
                            Navigator.pop(context, vehiculo);
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
