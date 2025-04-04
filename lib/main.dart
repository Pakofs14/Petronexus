import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:petronexus/password.dart';
import 'dart:convert';
import 'package:petronexus/reporte.dart';
import 'package:petronexus/desglose.dart';
import 'package:petronexus/entrada.dart'; // Asegúrate de crear este archivo
import 'package:petronexus/salida.dart'; // Asegúrate de crear este archivo

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Petronexus',
      theme: ThemeData(
        primaryColor: const Color(0xFFC0261F),
        scaffoldBackgroundColor: const Color(0xFFe5e8e8),
      ),
      home: const MyHomePage(title: 'Petronexus'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, Map<String, dynamic>> _usuarios = {};
  String? _usuarioActual;

  @override
  void initState() {
    super.initState();
    _cargarUsuariosDesdeAirtable();
  }

  Future<void> _cargarUsuariosDesdeAirtable() async {
    final airtableApiToken =
        'patW8Q98FkL4zObhH.c46b48da5580a5cb1ecfea2b24a2cd56f4be18a30bcba7b2e7747684f39352ec';
    final airtableBaseId = 'appk2qomcs0VaYbCD';
    final airtableTableName = 'Contraseñas';
    final url =
        'https://api.airtable.com/v0/$airtableBaseId/$airtableTableName';

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

        _usuarios.clear();

        for (var record in records) {
          final usuario = record['fields']['Usuario'];
          final password = record['fields']['Password'];
          final permisoSubir = record['fields']['Permiso Subir'] == 'Si';
          final permisoDescargar =
              record['fields']['Permiso Descargar'] == 'Si';
          final permisoPassword = record['fields']['Permiso Password'] == 'Si';
          final permisoAlmacen =
              record['fields']['Permiso Almacen'] == 'Si'; // Nuevo permiso

          if (usuario != null && password != null) {
            _usuarios[usuario] = {
              'password': password,
              'subir': permisoSubir,
              'descargar': permisoDescargar,
              'contraseñas': permisoPassword,
              'almacen': permisoAlmacen, // Agregar el nuevo permiso
            };
          }
        }

        setState(() {});
      } else {
        throw Exception(
            'Error al obtener datos de Airtable: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  void _mostrarDialogoLogin(BuildContext context,
      {String? permiso, Widget? page, String? customMessage}) {
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    bool _obscureText = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Iniciar sesión'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (customMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(customMessage,
                          style: TextStyle(color: Colors.red)),
                    ),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureText,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    final username = _usernameController.text;
                    final password = _passwordController.text;

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return const AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 20),
                              Text('Validando credenciales...'),
                            ],
                          ),
                        );
                      },
                    );

                    await Future.delayed(const Duration(seconds: 2));

                    Navigator.of(context).pop();

                    if (_usuarios.containsKey(username)) {
                      if (_usuarios[username]!['password'] == password) {
                        _usuarioActual = username;
                        Navigator.of(context).pop();

                        if (permiso != null && page != null) {
                          _verificarPermiso(permiso, page);
                        }
                      } else {
                        _mostrarDialogoLogin(
                          context,
                          permiso: permiso,
                          page: page,
                          customMessage: 'Contraseña incorrecta',
                        );
                      }
                    } else {
                      _mostrarDialogoLogin(
                        context,
                        permiso: permiso,
                        page: page,
                        customMessage: 'Usuario no encontrado',
                      );
                    }
                  },
                  child: const Text('Iniciar sesión'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _verificarPermiso(String permiso, Widget page) {
    if (_usuarioActual != null && _usuarios[_usuarioActual]![permiso]) {
      _navegarConFade(context, page);
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Acceso Denegado'),
            content:
                const Text('No tienes permiso para acceder a esta sección.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
    }
  }

  void _navegarConFade(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  // Agrega este método en la clase _MyHomePageState
  void _mostrarDialogo(BuildContext context, {String? mensaje}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Función no disponible'),
          content:
              Text(mensaje ?? 'Esta función estará disponible próximamente.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
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
        title: Text(widget.title),
        backgroundColor: const Color(0xFFC0261F),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      backgroundColor: const Color(0xFFe5e8e8),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/lateral.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Petronexus',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ExpansionTile(
              leading: const Icon(Icons.local_gas_station),
              title: const Text('Carga de Gasolina'),
              children: [
                ListTile(
                  leading: const Icon(FontAwesomeIcons.upload),
                  title: const Text('Subir carga de gasolina'),
                  onTap: () {
                    _mostrarDialogoLogin(context,
                        permiso: 'subir', page: ReportePage());
                  },
                ),
                ListTile(
                  leading: const Icon(FontAwesomeIcons.fileAlt),
                  title: const Text('Reportes de gasolina'),
                  onTap: () {
                    _mostrarDialogoLogin(context,
                        permiso: 'descargar', page: DesglosePage());
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(FontAwesomeIcons.oilCan),
              title: const Text('Servicio de aceite'),
              children: [
                ListTile(
                  leading: const Icon(FontAwesomeIcons.upload),
                  title: const Text('Subir servicio de aceite'),
                  onTap: () {
                    _mostrarDialogo(context);
                  },
                ),
                ListTile(
                  leading: const Icon(FontAwesomeIcons.fileAlt),
                  title: const Text('Reportes de servicio'),
                  onTap: () {
                    _mostrarDialogo(context);
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(FontAwesomeIcons.warehouse),
              title: const Text('Almacén'),
              children: [
                ListTile(
                  leading: const Icon(FontAwesomeIcons.boxOpen),
                  title: const Text('Entrada Almacén'),
                  onTap: () {
                    _mostrarDialogoLogin(
                      context,
                      permiso: 'almacen',
                      page: EntradaAlmacenPage(usuario: _usuarioActual ?? ''),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(FontAwesomeIcons.dolly),
                  title: const Text('Salida Almacén'),
                  onTap: () {
                    _mostrarDialogoLogin(
                      context,
                      permiso: 'almacen',
                      page: SalidaAlmacenPage(usuario: _usuarioActual ?? ''),
                    );
                  },
                ),
              ],
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Usuarios'),
              onTap: () {
                _mostrarDialogoLogin(context,
                    permiso: 'contraseñas', page: PasswordPage());
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/oil.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
