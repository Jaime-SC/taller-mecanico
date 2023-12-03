import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../models/vehiculo.dart';

class FirestoreService {
  final CollectionReference vehiculosCollection =
      FirebaseFirestore.instance.collection("vehiculos");
  final CollectionReference clientesCollection =
      FirebaseFirestore.instance.collection("clientes");

  Future<void> agregarVehiculo(Vehiculo vehiculo) async {
    // Verificamos si el vehículo tiene una referencia de cliente
    if (vehiculo.clienteReference == null) {
      print("Error: El vehículo no tiene una referencia de cliente.");
      return; // Puedes manejar esto de acuerdo a tu lógica
    }

    // Y finalmente, añadimos el vehículo a la colección de vehículos con la referencia del cliente
    await vehiculosCollection.add({
      "matricula_vehiculo": vehiculo.matricula_vehiculo,
      "clienteReference": vehiculo.clienteReference,
      "marca": vehiculo.marca,
      "modelo": vehiculo.modelo,
      "anio": vehiculo.anio,
    });
  }

  Future<List<Vehiculo>> obtenerVehiculos() async {
    try {
      QuerySnapshot vehiculosSnapshot = await vehiculosCollection.get();

      // Mapeamos los documentos a objetos Vehiculo
      List<Vehiculo> vehiculos = vehiculosSnapshot.docs.map((doc) {
        return Vehiculo(
          matricula_vehiculo: doc["matricula_vehiculo"],
          clienteReference:
              FirebaseFirestore.instance.doc(doc["clienteReference"]),
          marca: doc["marca"],
          modelo: doc["modelo"],
          anio: doc["anio"],
          // Incluye otras propiedades del vehículo
        );
      }).toList();

      return vehiculos;
    } catch (e) {
      print("Error al obtener vehículos: $e");
      return []; // Puedes manejar el error según tus necesidades
    }
  }

  Future<void> actualizarVehiculo(String vehiculoId, Vehiculo vehiculo) async {
    try {
      await vehiculosCollection.doc(vehiculoId).update(vehiculo.toJson());
      print("Vehículo actualizado con éxito.");
    } catch (e) {
      print("Error al actualizar vehículo: $e");
    }
  }

  Future<void> eliminarVehiculo(String vehiculoId) async {
    try {
      await vehiculosCollection.doc(vehiculoId).delete();
      print("Vehículo eliminado con éxito.");
    } catch (e) {
      print("Error al eliminar vehículo: $e");
    }
  }
}

class VehiculosDataTable extends StatefulWidget {
  final List<QueryDocumentSnapshot>? documentSnapshots;

  const VehiculosDataTable({Key? key, this.documentSnapshots})
      : super(key: key);

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
          buildSortableHeader(
              'MATRICULA VEHICULO', (vehiculo) => vehiculo.matricula_vehiculo),
          buildSortableHeader(
              'RUT CLIENTE',
              (vehiculo) => vehiculo
                  .clienteReference.id), // Accede al ID de la referencia
          buildSortableHeader('MARCA', (vehiculo) => vehiculo.marca),
          buildSortableHeader('MODELO', (vehiculo) => vehiculo.modelo),
          buildSortableHeader('AÑO', (vehiculo) => vehiculo.anio),

          DataColumn(
            label: Text('ACCIONES',
                style: TextStyle(
                    fontSize: 17.5,
                    fontFamily: 'SpaceMonoNerdFont',
                    fontWeight: FontWeight.bold)),
          ),
        ],
        rows: widget.documentSnapshots?.map((documentSnapshot) {
              final vehiculo = Vehiculo(
                matricula_vehiculo:
                    documentSnapshot["matricula_vehiculo"] ?? "",
                clienteReference: documentSnapshot["clienteReference"],
                marca: documentSnapshot["marca"] ?? "",
                modelo: documentSnapshot["modelo"] ?? "",
                anio: documentSnapshot["anio"] ?? "",
              );

              return DataRow(
                cells: [
                  DataCell(Text(vehiculo.matricula_vehiculo,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoMonoNerdFont'))),
                  DataCell(Text(vehiculo.clienteReference.id,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoMonoNerdFont'))),
                  DataCell(Text(vehiculo.marca,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoMonoNerdFont'))),
                  DataCell(Text(vehiculo.modelo,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoMonoNerdFont'))),
                  DataCell(Text(vehiculo.anio,
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
      label: Text(label,
          style: TextStyle(
              fontSize: 17.5,
              fontFamily: 'SpaceMonoNerdFont',
              fontWeight: FontWeight.bold)),
      onSort: (columnIndex, ascending) {
        _sort<Comparable>(
            (vehiculo) => getField(vehiculo), columnIndex, ascending);
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

  void _sort<T>(Comparable<T> Function(Vehiculo vehiculo) getField,
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
      var aValue = getField(Vehiculo(
        matricula_vehiculo: a["matricula_vehiculo"] ?? "",
        clienteReference: a["clienteReference"] ?? "",
        marca: a["marca"] ?? "",
        modelo: a["modelo"] ?? "",
        anio: a["anio"] ?? "",
      ));
      var bValue = getField(Vehiculo(
        matricula_vehiculo: b["matricula_vehiculo"] ?? "",
        clienteReference: b["clienteReference"] ?? "",
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
  final TextEditingController clienteReferenceController =
      TextEditingController(); // No editable por el usuario
  final TextEditingController marcaController = TextEditingController();
  final TextEditingController modeloController = TextEditingController();
  final TextEditingController anioController = TextEditingController();

  Future<void> _seleccionarCliente(BuildContext context) async {
    final clienteSeleccionado = await showDialog<Cliente>(
      context: context,
      builder: (BuildContext context) {
        return ClienteSeleccionDialog();
      },
    );

    if (clienteSeleccionado != null) {
      setState(() {
        clienteReferenceController.text = clienteSeleccionado.rut_cliente;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Inicializar controladores con la información del vehículo si está disponible
    if (widget.vehiculo != null) {
      matriculaVehiculoController.text = widget.vehiculo!.matricula_vehiculo;
      clienteReferenceController.text = widget.vehiculo!.clienteReference.id;
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
            Row(
              children: [
                Expanded(
                  child: textField(
                      "Rut Cliente", clienteReferenceController,
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
              
            }
          },
          child: Text(widget.vehiculo != null ? 'Editar' : 'Agregar'),
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

  /*bool camposValidos() {
    // Verifica que todos los campos estén llenos
    return matriculaVehiculoController.text.isNotEmpty &&
        marcaController.text.isNotEmpty &&
        modeloController.text.isNotEmpty &&
        anioController.text.isNotEmpty;
  }*/

bool camposValidos() {
  // Verifica que todos los campos estén llenos
  Map<String, TextEditingController> controllers = {
    "Matricula": matriculaVehiculoController,
    "Cliente": clienteReferenceController,
    "Marca": marcaController,
    "Modelo": modeloController,
    "Año": anioController,
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
                  buildCampoCompleto("Matricula", !camposFaltantes.contains("Matricula")),
                  buildCampoCompleto(
                      "Cliente", !camposFaltantes.contains("Cliente")),
                  buildCampoCompleto(
                      "Marca", !camposFaltantes.contains("Marca")),
                  buildCampoCompleto(
                      "Modelo", !camposFaltantes.contains("Modelo")),
                  buildCampoCompleto(
                      "Año", !camposFaltantes.contains("Año")),
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

  Future<void> agregarNuevoVehiculo() async {
    try {
      // Obtener una referencia a la colección "vehiculos" en Firebase
      final vehiculosCollection =
          FirebaseFirestore.instance.collection("vehiculos");

      // Obtén la referencia del cliente basada en el ID proporcionado
      final clientReference = FirebaseFirestore.instance
          .collection('clientes')
          .doc(clienteReferenceController.text);

      // Agregar el nuevo vehículo a Firebase
      await vehiculosCollection.add({
        "matricula_vehiculo": matriculaVehiculoController.text,
        "clienteReference":
            clientReference, // Utiliza la referencia del cliente
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
      final vehiculoRef = FirebaseFirestore.instance
          .collection("vehiculos")
          .doc(widget.vehiculoId);

      // Actualizar la información del vehículo en Firebase
      await vehiculoRef.update({
        "matricula_vehiculo": matriculaVehiculoController.text,
        "clienteReference": FirebaseFirestore.instance
            .collection('clientes')
            .doc(clienteReferenceController.text),
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
      contentPadding: EdgeInsets.all(10.0), // Ajusta el padding según tus necesidades
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
                    return Center(child: Text('Error al cargar clientes: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No hay clientes disponibles.'));
                  } else {
                    // Filtra la lista de clientes según el término de búsqueda
                    final filteredClientes = snapshot.data!
                        .where((cliente) =>
                            cliente.nom_cliente.toLowerCase().contains(searchController.text.toLowerCase()) ||
                            cliente.ape_cliente.toLowerCase().contains(searchController.text.toLowerCase()) ||
                            cliente.rut_cliente.toLowerCase().contains(searchController.text.toLowerCase()))
                        .toList();

                    return ListView.builder(
                      itemCount: filteredClientes.length,
                      itemBuilder: (context, index) {
                        final cliente = filteredClientes[index];
                        return ListTile(
                          title: Text(" ${cliente.nom_cliente} ${cliente.ape_cliente} ${cliente.rut_cliente}"),
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
