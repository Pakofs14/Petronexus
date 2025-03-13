import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:petronexus/password.dart';
import 'dart:convert';
import 'package:petronexus/reporte.dart';
import 'package:petronexus/desglose.dart';

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

        _usuarios.clear();

        for (var record in records) {
          final usuario = record['fields']['Usuario'];
          final password = record['fields']['Password'];
          final permisoSubir = record['fields']['Permiso Subir'] == 'Si';
          final permisoDescargar = record['fields']['Permiso Descargar'] == 'Si';
          final permisoPassword = record['fields']['Permiso Password'] == 'Si';

          if (usuario != null && password != null) {
            _usuarios[usuario] = {
              'password': password,
              'subir': permisoSubir,
              'descargar': permisoDescargar,
              'contraseñas': permisoPassword,
            };
          }
        }

        setState(() {});
      } else {
        throw Exception('Error al obtener datos de Airtable: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  void _mostrarDialogoLogin(BuildContext context, String permiso, Widget page) {
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Iniciar sesión'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
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
                final username = _usernameController.text;
                final password = _passwordController.text;

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
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
                    _verificarPermiso(permiso, page);
                  } else {
                    _mostrarMensajeError(context, 'Contraseña incorrecta');
                  }
                } else {
                  _mostrarMensajeError(context, 'Usuario no encontrado');
                }
              },
              child: const Text('Iniciar sesión'),
            ),
          ],
        );
      },
    );
  }

  void _verificarPermiso(String permiso, Widget page) {
    if (_usuarioActual != null && _usuarios[_usuarioActual]![permiso]) {
      _navegarConFade(context, page); // Navegación con efecto de fade
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Acceso Denegado'),
            content: const Text('No tienes permiso para acceder a esta sección.'),
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
  }

  void _mostrarMensajeError(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(mensaje),
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

  void _mostrarDialogo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Función no disponible'),
          content: const Text('Esta función estará disponible próximamente.'),
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
                    _mostrarDialogoLogin(context, 'subir', ReportePage());
                  },
                ),
                ListTile(
                  leading: const Icon(FontAwesomeIcons.fileAlt),
                  title: const Text('Reportes de gasolina'),
                  onTap: () {
                    _mostrarDialogoLogin(context, 'descargar', DesglosePage());
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
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Usuarios'),
              onTap: () {
                _mostrarDialogoLogin(context, 'contraseñas', PasswordPage());
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