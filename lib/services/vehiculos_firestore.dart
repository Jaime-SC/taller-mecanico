import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/vehiculo.dart';
import '../widgets/reusable_widget.dart';

class FirestoreService {
  final CollectionReference vehiculosCollection =
      FirebaseFirestore.instance.collection("vehiculos");

  Future<void> agregarVehiculo(Vehiculo vehiculo) async {
    await vehiculosCollection.add(vehiculo.toJson());
  }

  Future<void> actualizarVehiculo(String vehiculoId, Vehiculo vehiculo) async {
    await vehiculosCollection.doc(vehiculoId).update(vehiculo.toJson());
  }

  Future<void> eliminarVehiculo(String vehiculoId) async {
    await vehiculosCollection.doc(vehiculoId).delete();
  }
}

class VehiculosDataTable extends StatefulWidget {
  final List<QueryDocumentSnapshot>? documentSnapshots;

  const VehiculosDataTable({Key? key, this.documentSnapshots}) : super(key: key);

  @override
  _VehiculosDataTableState createState() => _VehiculosDataTableState();
}

class _VehiculosDataTableState extends State<VehiculosDataTable> {
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
          buildSortableHeader('MATRICULA VEHICULO', (vehiculo) => vehiculo.matricula_vehiculo),
          buildSortableHeader('RUT CLIENTE', (vehiculo) => vehiculo.rut_cliente),
          buildSortableHeader('MARCA', (vehiculo) => vehiculo.marca),
          buildSortableHeader('MODELO', (vehiculo) => vehiculo.modelo),
          buildSortableHeader('AÑO', (vehiculo) => vehiculo.anio),
          
          DataColumn(
            label: Text('ACCIONES', style: TextStyle(fontSize: 17.5, fontFamily: 'SpaceMonoNerdFont', fontWeight: FontWeight.bold)),
          ),
        ],
        rows: widget.documentSnapshots?.map((documentSnapshot) {
          final vehiculo = Vehiculo(
            matricula_vehiculo: documentSnapshot["matricula_vehiculo"] ?? "",
            rut_cliente: documentSnapshot["rut_cliente"] ?? "",
            marca: documentSnapshot["marca"] ?? "",
            modelo: documentSnapshot["modelo"] ?? "",
            anio: documentSnapshot["anio"] ?? "",
            
          );

          return DataRow(
            cells: [
              DataCell(Text(vehiculo.matricula_vehiculo, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'GoMonoNerdFont'))),
              DataCell(Text(vehiculo.rut_cliente, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'GoMonoNerdFont'))),
              DataCell(Text(vehiculo.marca, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'GoMonoNerdFont'))),
              DataCell(Text(vehiculo.modelo, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'GoMonoNerdFont'))),
              DataCell(Text(vehiculo.anio, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'GoMonoNerdFont'))),
              
              DataCell(
                Row(
                  children: [
                    buildIconButton(
                      Icons.delete,
                      Color(0XFFD60019),
                      () {
                        FirestoreService()
                            .eliminarVehiculo(documentSnapshot.id);
                      },
                    ),
                    buildIconButton(
                      Icons.edit,
                      Color(0XFF004B85),
                      () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AgregarEditarVehiculoDialog(
                              vehiculo: vehiculo,
                              vehiculoId: documentSnapshot.id,
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

  DataColumn buildSortableHeader(String label, Function(Vehiculo) getField) {
    return DataColumn(
      label: Text(label, style: TextStyle(fontSize: 17.5, fontFamily: 'SpaceMonoNerdFont', fontWeight: FontWeight.bold)),
      onSort: (columnIndex, ascending) {
        _sort<Comparable>((vehiculo) => getField(vehiculo), columnIndex, ascending);
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

  void _sort<T>(Comparable<T> Function(Vehiculo vehiculo) getField, int columnIndex, bool ascending) {
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
      var aValue = getField(Vehiculo(
        matricula_vehiculo: a["matricula_vehiculo"] ?? "",
        rut_cliente: a["rut_cliente"] ?? "",
        marca: a["marca"] ?? "",
        modelo: a["modelo"] ?? "",
        anio: a["anio"] ?? "",
        
      ));
      var bValue = getField(Vehiculo(
        matricula_vehiculo: b["matricula_vehiculo"] ?? "",
        rut_cliente: b["rut_cliente"] ?? "",
        marca: b["marca"] ?? "",
        modelo: b["modelo"] ?? "",
        anio: b["anio"] ?? "",
        
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

class AgregarEditarVehiculoDialog extends StatefulWidget {
  final Vehiculo? vehiculo;
  final String? vehiculoId;

  AgregarEditarVehiculoDialog({this.vehiculo, this.vehiculoId});

  @override
  _AgregarEditarVehiculoDialogState createState() =>
      _AgregarEditarVehiculoDialogState();
}

class _AgregarEditarVehiculoDialogState
    extends State<AgregarEditarVehiculoDialog> {
  final TextEditingController matriculaVehiculoController =
      TextEditingController();
  final TextEditingController rutVehiculoController = TextEditingController();
  final TextEditingController marcaController = TextEditingController();
  final TextEditingController modeloController = TextEditingController();
  final TextEditingController anioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Inicializar controladores con la información del vehículo si está disponible
    if (widget.vehiculo != null) {
      matriculaVehiculoController.text = widget.vehiculo!.matricula_vehiculo;
      rutVehiculoController.text = widget.vehiculo!.rut_cliente;
      marcaController.text = widget.vehiculo!.marca;
      modeloController.text = widget.vehiculo!.modelo;
      anioController.text = widget.vehiculo!.anio;
    }

    return AlertDialog(
      title: Text('Agregar Nuevo Vehiculo'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            textField("Matricula Vehiculo", matriculaVehiculoController),
            textField("Rut Cliente", rutVehiculoController),
            textField("Marca", marcaController),
            textField("Modelo", modeloController),
            textField("Año", anioController),
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
              if (widget.vehiculo != null) {
                // Lógica para editar el vehículo existente en Firebase
                editarVehiculoExistente();
              } else {
                // Lógica para agregar el nuevo vehículo a Firebase
                agregarNuevoVehiculo();
              }
              Navigator.pop(context); // Cierra el cuadro de diálogo
            } else {
              // Muestra un mensaje de error si hay campos vacíos
              mostrarErrorCamposVacios();
            }
          },
          child: Text(widget.vehiculo != null ? 'Editar' : 'Agregar'),
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
    return matriculaVehiculoController.text.isNotEmpty &&
        rutVehiculoController.text.isNotEmpty &&
        marcaController.text.isNotEmpty &&
        modeloController.text.isNotEmpty &&
        anioController.text.isNotEmpty;
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

  void agregarNuevoVehiculo() async {
    try {
      // Obtener una referencia a la colección "vehiculos" en Firebase
      final vehiculosCollection =
          FirebaseFirestore.instance.collection("vehiculos");

      // Agregar el nuevo vehículo a Firebase
      await vehiculosCollection.add({
        "matricula_vehiculo": matriculaVehiculoController.text,
        "rut_cliente": rutVehiculoController.text,
        "marca": marcaController.text,
        "modelo": modeloController.text,
        "anio": anioController.text,
      });

      print("Nuevo vehículo agregado con éxito a Firebase.");
    } catch (e) {
      print("Error al agregar nuevo vehículo a Firebase: $e");
    }
  }

  void editarVehiculoExistente() async {
    try {
      // Obtener una referencia al documento del vehículo en Firebase
      final vehiculoRef =
          FirebaseFirestore.instance.collection("vehiculos").doc(widget.vehiculoId);

      // Actualizar la información del vehículo en Firebase
      await vehiculoRef.update({
        "matricula_vehiculo": matriculaVehiculoController.text,
        "rut_cliente": rutVehiculoController.text,
        "marca": marcaController.text,
        "modelo": modeloController.text,
        "anio": anioController.text,
      });

      print("Vehículo editado con éxito en Firebase.");
    } catch (e) {
      print("Error al editar vehículo en Firebase: $e");
    }
  }
}
