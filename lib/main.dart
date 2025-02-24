import 'package:flutter/material.dart';
import 'package:petronexus/catalogo.dart';
import 'package:petronexus/reporte.dart';
import 'package:petronexus/desglose.dart'; // Asegúrate de importar la página DesglosePage

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Petronexus',
      theme: ThemeData(
        primaryColor: Color(0xFFC0261F), // Usar primaryColor en lugar de primarySwatch
        scaffoldBackgroundColor: Color(0xFFe5e8e8),
      ),
      home: const MyHomePage(title: 'Petronexus'),
      debugShowCheckedModeBanner: false, // Ocultar banner de debug
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Color(0xFFC0261F),
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
            DrawerHeader(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/lateral.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Align(
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
            // Menú desplegable para "Carga de Gasolina"
            ExpansionTile(
              leading: const Icon(Icons.local_gas_station), // Ícono de gasolina
              title: const Text('Carga de Gasolina'),
              children: [
                ListTile(
                  leading: const Icon(Icons.upload), // Ícono de subir
                  title: const Text('Subir carga de gasolina'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReportePage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.list), // Ícono de lista
                  title: const Text('Reportes de carga de gasolina'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DesglosePage()),
                    );
                  },
                ),
              ],
            ),
            ListTile(
              leading: const Icon(Icons.picture_in_picture),
              title: const Text('Catálogo'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CatalogoPage()),
                );
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