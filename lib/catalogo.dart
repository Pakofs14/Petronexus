import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class CatalogoPage extends StatefulWidget {
  @override
  _CatalogoPageState createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  List<dynamic> productos = [];
  List<dynamic> productosFiltrados = [];
  List<String> categorias = ['Todas'];
  final String apiKey =
      'patKImpJxmX6YYIRc.faa088790cc63690aae04a27756279e9b21d4a54cd43b2b83281f30205312a49';
  final String baseId = 'appk2qomcs0VaYbCD';
  final String tableName = 'tblYM1pKpGBKYsrht';
  String _categoriaSeleccionada = 'Todas';
  final TextEditingController _claveController = TextEditingController();
  FocusNode _focusNodeClave = FocusNode(); // Para manejar el foco manualmente

  // Agregar un Timer para implementar el debounce
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchProductos();
  }

  Future<void> fetchProductos() async {
    try {
      final url = Uri.parse('https://api.airtable.com/v0/$baseId/$tableName');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          productos = data['records'];
          productosFiltrados = List.from(productos);
          _actualizarCategorias(); // Actualizar categorías después de cargar productos
        });
      } else {
        debugPrint(
            'Error al cargar los productos: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Error al cargar los productos: ${response.statusCode}');
      }
    } catch (error, stackTrace) {
      debugPrint('Excepción atrapada: $error');
      debugPrint('StackTrace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar los productos: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _actualizarCategorias() {
    setState(() {
      categorias = [
        'Todas',
        ...productos
            .map((producto) => producto['fields']['CATEGORIA'] != null
                ? producto['fields']['CATEGORIA'].toString()
                : 'Sin categoría')
            .toSet()
            .toList()
      ];
    });
  }

  void _ordenarPorClave() {
    setState(() {
      productosFiltrados
          .sort((a, b) => a['fields']['CLAVE'].compareTo(b['fields']['CLAVE']));
    });
  }

  void _filtrarPorCategoria(String categoria) {
    setState(() {
      if (categoria == 'Todas') {
        productosFiltrados = List.from(productos);
      } else {
        productosFiltrados = productos
            .where((producto) => producto['fields']['CATEGORIA'] == categoria)
            .toList();
      }
    });
  }

  // Modificado para usar debounce
  void _buscarPorClave(String clave) {
    // Cancelar cualquier búsqueda anterior que esté en proceso
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Iniciar el timer para ejecutar la búsqueda después de un pequeño retraso
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        productosFiltrados = productos.where((producto) {
          return producto['fields']['CLAVE'].toString().contains(clave);
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catálogo de Productos'),
        backgroundColor: Color(0xFFC0261F),
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.sort_by_alpha),
            onPressed: _ordenarPorClave,
          ),
          DropdownButton<String>(
            value: _categoriaSeleccionada,
            dropdownColor: Color(0xFFC0261F),
            icon: Icon(Icons.arrow_drop_down, color: Colors.white),
            onChanged: (String? newValue) {
              setState(() {
                _categoriaSeleccionada = newValue!;
                _filtrarPorCategoria(newValue);
              });
            },
            items: categorias.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _claveController,
                    focusNode:
                        _focusNodeClave, // Asociar el foco con el TextField
                    decoration: InputDecoration(
                      hintText: 'Buscar por clave',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    autocorrect: true,
                    onChanged:
                        _buscarPorClave, // Llamar a la función al cambiar el texto
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    _buscarPorClave(_claveController.text);
                    FocusScope.of(context).requestFocus(
                        FocusNode()); // Perder el foco después de la búsqueda
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: productosFiltrados.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Número de columnas
                crossAxisSpacing: 8.0, // Espacio entre columnas
                mainAxisSpacing: 8.0, // Espacio entre filas
                childAspectRatio: 0.75, // Relación de aspecto de los elementos
              ),
              itemCount: productosFiltrados.length,
              itemBuilder: (context, index) {
                final producto = productosFiltrados[index]['fields'];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: producto['FOTO'] != null
                            ? Image.network(
                                producto['FOTO'][0]['url'],
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_not_supported),
                                    Text("Sin foto",
                                        style: TextStyle(fontSize: 10)),
                                  ],
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              producto['NOMBRE'] ?? 'Sin nombre',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text('Clave: ${producto['CLAVE'] ?? 'N/A'}'),
                            Text('Unidad: ${producto['UNIDAD'] ?? 'N/A'}'),
                            Text(
                                'Categoría: ${producto['CATEGORIA'] ?? 'N/A'}'),
                            Text(
                              'Descripción: ${producto['DESCRIPCION'] ?? 'Sin descripción'}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
