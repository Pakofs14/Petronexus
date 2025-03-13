import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PasswordPage extends StatefulWidget {
  @override
  _PasswordPageState createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  List<Map<String, dynamic>> _usuarios = [];

  @override
  void initState() {
    super.initState();
    _cargarUsuariosDesdeAirtable();
  }

  Future<void> _cargarUsuariosDesdeAirtable() async {
    final airtableApiToken = 'patW8Q98FkL4zObhH.c46b48da5580a5cb1ecfea2b24a2cd56f4be18a30bcba7b2e7747684f39352ec';
    final airtableBaseId = 'appk2qomcs0VaYbCD';
    final airtableTableName = 'Contraseñas';
    final url = 'https://api.airtable.com/v0/$airtableBaseId/$airtableTableName';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $airtableApiToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final records = data['records'];

        setState(() {
          _usuarios = records.map<Map<String, dynamic>>((record) {
            return {
              'id': record['id'],
              'usuario': record['fields']['Usuario'] ?? '',
              'password': record['fields']['Password'] ?? '',
              'permisoSubir': record['fields']['Permiso Subir'] == 'Si',
              'permisoDescargar': record['fields']['Permiso Descargar'] == 'Si',
              'permisoPassword': record['fields']['Permiso Password'] == 'Si',
            };
          }).toList();
        });
      } else {
        throw Exception('Error al obtener datos de Airtable: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  Future<void> _crearUsuarioEnAirtable(Map<String, dynamic> nuevoUsuario) async {
    final airtableApiToken = 'patW8Q98FkL4zObhH.c46b48da5580a5cb1ecfea2b24a2cd56f4be18a30bcba7b2e7747684f39352ec';
    final airtableBaseId = 'appk2qomcs0VaYbCD';
    final airtableTableName = 'Contraseñas';
    final url = 'https://api.airtable.com/v0/$airtableBaseId/$airtableTableName';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $airtableApiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fields': {
            'Usuario': nuevoUsuario['usuario'],
            'Password': nuevoUsuario['password'],
            'Permiso Subir': nuevoUsuario['permisoSubir'] ? 'Si' : 'No',
            'Permiso Descargar': nuevoUsuario['permisoDescargar'] ? 'Si' : 'No',
            'Permiso Password': nuevoUsuario['permisoPassword'] ? 'Si' : 'No',
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Usuario creado correctamente');
        _cargarUsuariosDesdeAirtable();
        _mostrarMensajeExito(context, 'Usuario creado correctamente');
      } else {
        throw Exception('Error al crear usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  Future<void> _eliminarUsuarioEnAirtable(String recordId) async {
    final airtableApiToken = 'patW8Q98FkL4zObhH.c46b48da5580a5cb1ecfea2b24a2cd56f4be18a30bcba7b2e7747684f39352ec';
    final airtableBaseId = 'appk2qomcs0VaYbCD';
    final airtableTableName = 'Contraseñas';
    final url = 'https://api.airtable.com/v0/$airtableBaseId/$airtableTableName/$recordId';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $airtableApiToken',
        },
      );

      if (response.statusCode == 200) {
        print('Usuario eliminado correctamente');
        _cargarUsuariosDesdeAirtable();
        _mostrarMensajeExito(context, 'Usuario eliminado correctamente');
      } else {
        throw Exception('Error al eliminar usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  void _mostrarDialogoCrearUsuario(BuildContext context) {
    final TextEditingController _usuarioController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    bool permisoSubir = false;
    bool permisoDescargar = false;
    bool permisoPassword = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Crear nuevo usuario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _usuarioController,
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<bool>(
                  value: permisoSubir,
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Sí')),
                    DropdownMenuItem(value: false, child: Text('No')),
                  ],
                  onChanged: (value) {
                    permisoSubir = value!;
                  },
                  decoration: const InputDecoration(labelText: 'Permiso Subir'),
                ),
                DropdownButtonFormField<bool>(
                  value: permisoDescargar,
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Sí')),
                    DropdownMenuItem(value: false, child: Text('No')),
                  ],
                  onChanged: (value) {
                    permisoDescargar = value!;
                  },
                  decoration: const InputDecoration(labelText: 'Permiso Descargar'),
                ),
                DropdownButtonFormField<bool>(
                  value: permisoPassword,
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Sí')),
                    DropdownMenuItem(value: false, child: Text('No')),
                  ],
                  onChanged: (value) {
                    permisoPassword = value!;
                  },
                  decoration: const InputDecoration(labelText: 'Permiso Contraseñas'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final nuevoUsuario = {
                  'usuario': _usuarioController.text,
                  'password': _passwordController.text,
                  'permisoSubir': permisoSubir,
                  'permisoDescargar': permisoDescargar,
                  'permisoPassword': permisoPassword,
                };

                await _crearUsuarioEnAirtable(nuevoUsuario);
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoEditarPermisos(BuildContext context, Map<String, dynamic> usuario) {
    bool permisoSubir = usuario['permisoSubir'] ?? false;
    bool permisoDescargar = usuario['permisoDescargar'] ?? false;
    bool permisoPassword = usuario['permisoPassword'] ?? false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar permisos de ${usuario['usuario']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<bool>(
                  value: permisoSubir,
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Sí')),
                    DropdownMenuItem(value: false, child: Text('No')),
                  ],
                  onChanged: (value) {
                    permisoSubir = value!;
                  },
                  decoration: const InputDecoration(labelText: 'Permiso Subir'),
                ),
                DropdownButtonFormField<bool>(
                  value: permisoDescargar,
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Sí')),
                    DropdownMenuItem(value: false, child: Text('No')),
                  ],
                  onChanged: (value) {
                    permisoDescargar = value!;
                  },
                  decoration: const InputDecoration(labelText: 'Permiso Descargar'),
                ),
                DropdownButtonFormField<bool>(
                  value: permisoPassword,
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Sí')),
                    DropdownMenuItem(value: false, child: Text('No')),
                  ],
                  onChanged: (value) {
                    permisoPassword = value!;
                  },
                  decoration: const InputDecoration(labelText: 'Permiso Contraseñas'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final nuevosPermisos = {
                  'permisoSubir': permisoSubir,
                  'permisoDescargar': permisoDescargar,
                  'permisoPassword': permisoPassword,
                };

                await _actualizarPermisosEnAirtable(usuario['id'], nuevosPermisos);
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _actualizarPermisosEnAirtable(String recordId, Map<String, dynamic> nuevosPermisos) async {
    final airtableApiToken = 'patW8Q98FkL4zObhH.c46b48da5580a5cb1ecfea2b24a2cd56f4be18a30bcba7b2e7747684f39352ec';
    final airtableBaseId = 'appk2qomcs0VaYbCD';
    final airtableTableName = 'Contraseñas';
    final url = 'https://api.airtable.com/v0/$airtableBaseId/$airtableTableName/$recordId';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $airtableApiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fields': {
            'Permiso Subir': nuevosPermisos['permisoSubir'] ? 'Si' : 'No',
            'Permiso Descargar': nuevosPermisos['permisoDescargar'] ? 'Si' : 'No',
            'Permiso Password': nuevosPermisos['permisoPassword'] ? 'Si' : 'No',
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Permisos actualizados correctamente');
        _cargarUsuariosDesdeAirtable();
        _mostrarMensajeExito(context, 'Permisos actualizados correctamente');
      } else {
        throw Exception('Error al actualizar permisos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  void _mostrarMensajeExito(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _mostrarDialogoConfirmacionEliminar(BuildContext context, String recordId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Estás seguro de que deseas eliminar este usuario?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await _eliminarUsuarioEnAirtable(recordId);
                Navigator.of(context).pop();
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Usuarios y Contraseñas'),
      backgroundColor: const Color(0xFFC0261F),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            _mostrarDialogoCrearUsuario(context);
          },
        ),
      ],
    ),
    body: _usuarios.isEmpty
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Usuario')),
                  DataColumn(label: Text('Contraseña')),
                  DataColumn(label: Text('Permiso Subir')),
                  DataColumn(label: Text('Permiso Descargar')),
                  DataColumn(label: Text('Permiso Contraseñas')),
                  DataColumn(label: Text('Acciones')),
                ],
                rows: _usuarios.map((usuario) {
                  return DataRow(cells: [
                    DataCell(Text(usuario['usuario'] ?? '')),
                    DataCell(Text(usuario['password'] ?? '')),
                    DataCell(Text(usuario['permisoSubir'] ? 'Sí' : 'No')),
                    DataCell(Text(usuario['permisoDescargar'] ? 'Sí' : 'No')),
                    DataCell(Text(usuario['permisoPassword'] ? 'Sí' : 'No')),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _mostrarDialogoEditarPermisos(context, usuario);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _mostrarDialogoConfirmacionEliminar(context, usuario['id']);
                            },
                          ),
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        _mostrarDialogoCrearUsuario(context); // Abre el diálogo para crear un nuevo usuario
      },
      child: const Icon(Icons.add), // Ícono de "+"
      backgroundColor: const Color(0xFFC0261F), // Color del botón
    ),
  );
}
}