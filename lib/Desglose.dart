import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'dart:typed_data';
class DesglosePage extends StatefulWidget {
  @override
  _DesglosePageState createState() => _DesglosePageState();
}

class _DesglosePageState extends State<DesglosePage> {
  List<Map<String, dynamic>> _registros = [];
  bool _isLoading = true;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  // Create a ScrollController
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchDataFromAirtable();
  }

  @override
  void dispose() {
    // Dispose of the ScrollController to avoid memory leaks
    _scrollController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Reportes de Carga de Gasolina'),
      backgroundColor: Color(0xFFC0261F),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
    ),
    body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botón para descargar en Excel y título de la sección
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lista de registros',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () => _downloadExcel(_registros),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Descargar Excel'),
                      ),
                    ],
                  ),
                ),
                // Indicador de scroll horizontal más destacado
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.swipe, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        'Desliza horizontalmente para ver todos los campos',
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Tabla con datos - Con Scrollbar horizontal explícito
                Expanded(
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    thickness: 8.0,
                    radius: Radius.circular(4.0),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _sortAscending,
                        columnSpacing: 20,
                        headingRowHeight: 50,
                        dataRowMinHeight: 60,
                        dataRowMaxHeight: 80,
                        border: TableBorder(
                          horizontalInside: BorderSide(color: Colors.grey[300]!),
                          verticalInside: BorderSide(color: Colors.grey[300]!),
                          bottom: BorderSide(color: Colors.grey[300]!),
                          top: BorderSide(color: Colors.grey[300]!),
                          left: BorderSide(color: Colors.grey[300]!),
                          right: BorderSide(color: Colors.grey[300]!),
                        ),
                        columns: [
                          DataColumn(
                            label: Expanded(child: Text('Operador', textAlign: TextAlign.center)),
                            onSort: (columnIndex, ascending) {
                              _sort<String>((registro) => registro['Nombre Operador'] ?? '', columnIndex, ascending);
                            },
                          ),
                          DataColumn(
                            label: Expanded(child: Text('Gasolinera', textAlign: TextAlign.center)),
                            onSort: (columnIndex, ascending) {
                              _sort<String>((registro) => registro['Nombre Gasolinera'] ?? '', columnIndex, ascending);
                            },
                          ),
                          DataColumn(
                            label: Expanded(child: Text('Fecha', textAlign: TextAlign.center)),
                            onSort: (columnIndex, ascending) {
                              _sort<String>((registro) => registro['Fecha'] ?? '', columnIndex, ascending);
                            },
                          ),
                          DataColumn(
                            label: Expanded(child: Text('Hora', textAlign: TextAlign.center)),
                            onSort: (columnIndex, ascending) {
                              _sort<String>((registro) => registro['Hora'] ?? '', columnIndex, ascending);
                            },
                          ),
                          DataColumn(
                            label: Expanded(child: Text('Placas', textAlign: TextAlign.center)),
                            onSort: (columnIndex, ascending) {
                              _sort<String>((registro) => registro['Placas'] ?? '', columnIndex, ascending);
                            },
                          ),
                          DataColumn(
                            label: Expanded(child: Text('Importe', textAlign: TextAlign.center)),
                            onSort: (columnIndex, ascending) {
                              _sort<num>((registro) => registro['Importe'] ?? 0, columnIndex, ascending);
                            },
                          ),
                          DataColumn(
                            label: Expanded(child: Text('Litros', textAlign: TextAlign.center)),
                            onSort: (columnIndex, ascending) {
                              _sort<num>((registro) => registro['Litros'] ?? 0, columnIndex, ascending);
                            },
                          ),
                          DataColumn(
                            label: Expanded(child: Text('Descargar', textAlign: TextAlign.center)),
                          ),
                        ],
                        rows: _registros.map((registro) {
                          return DataRow(cells: [
                            DataCell(
                              Container(
                                constraints: BoxConstraints(maxWidth: 150),
                                child: Text(
                                  registro['Nombre Operador'] ?? '',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                constraints: BoxConstraints(maxWidth: 150),
                                child: Text(
                                  registro['Nombre Gasolinera'] ?? '',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(Text(registro['Fecha'] ?? '')),
                            DataCell(Text(registro['Hora'] ?? '')),
                            DataCell(Text(registro['Placas'] ?? '')),
                            DataCell(
                              Text(
                                registro['Importe'] != null
                                    ? '\$${registro['Importe'].toStringAsFixed(2)}'
                                    : '',
                                textAlign: TextAlign.right,
                              ),
                            ),
                            DataCell(
                              Text(
                                registro['Litros'] != null
                                    ? '${registro['Litros'].toStringAsFixed(2)} L'
                                    : '',
                                textAlign: TextAlign.right,
                              ),
                            ),
                            DataCell(
                              ElevatedButton(
                                onPressed: () => _generateAndDownloadPdf(registro),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFC0261F),
                                  foregroundColor: Colors.white,
                                ),
                                child: Text('PDF'),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
  );
}

  Future<void> _fetchDataFromAirtable() async {
    final airtableApiToken = 'patW8Q98FkL4zObhH.c46b48da5580a5cb1ecfea2b24a2cd56f4be18a30bcba7b2e7747684f39352ec';
    final airtableBaseId = 'appk2qomcs0VaYbCD';
    final airtableTableName = 'Gasolina';

    final url = 'https://api.airtable.com/v0/$airtableBaseId/$airtableTableName';

    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $airtableApiToken',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          _registros = List<Map<String, dynamic>>.from(data['records'].map((record) => record['fields']));
          _isLoading = false;
        });
      } else {
        throw Exception('Error al obtener los datos de Airtable');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _sort<T>(Comparable<T> Function(Map<String, dynamic> registro) getField, int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      _registros.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    });
  }

  Future<void> _generateAndDownloadPdf(Map<String, dynamic> registro) async {
    final pdf = pw.Document();
    final roboto = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final robotoBold = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

    Future<pw.Widget?> processImage(String? imageUrl, String label) async {
      if (imageUrl == null) {
        print('$label: URL de imagen no proporcionada');
        return pw.Text('$label: No disponible');
      }
      try {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode != 200) {
          print('$label: Error al cargar la imagen. Código de estado: ${response.statusCode}');
          return pw.Text('$label: Error al cargar');
        }
        final imageBytes = response.bodyBytes;
        final image = pw.MemoryImage(imageBytes);
        print('$label: Imagen cargada con éxito');
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: pw.TextStyle(font: robotoBold)),
            pw.SizedBox(height: 5),
            pw.Container(
              width: 200,  // Reducido el ancho para que se ajusten mejor las imágenes
              height: 120,  // Reducido el alto
              decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
              child: pw.Image(image, fit: pw.BoxFit.contain),
            ),
            pw.SizedBox(height: 10),
          ],
        );
      } catch (e) {
        print('$label: Error al cargar la imagen: $e');
        return pw.Text('$label: No disponible');
      }
    }

    final imageWidgets = await Future.wait([
      processImage(registro['Foto Placas']?[0]['url'], 'Foto de las Placas'),
      processImage(registro['Foto Unidad']?[0]['url'], 'Foto de la Unidad'),
      processImage(registro['Foto Ticket']?[0]['url'], 'Foto del Ticket'),
      processImage(registro['Foto Odometro']?[0]['url'], 'Foto del Odómetro'),
    ]);

    // Verifica si las imágenes se cargaron correctamente
    print('Total de imágenes cargadas: ${imageWidgets.length}');

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Reporte de Carga de Gasolina',
                    style: pw.TextStyle(font: robotoBold, fontSize: 24)),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                data: [
                  ['Operador', 'Gasolinera', 'Fecha', 'Hora', 'Placas', 'Importe', 'Litros'],
                  [
                    registro['Nombre Operador'] ?? '',
                    registro['Nombre Gasolinera'] ?? '',
                    registro['Fecha'] ?? '',
                    registro['Hora'] ?? '',
                    registro['Placas'] ?? '',
                    registro['Importe']?.toString() ?? '',
                    registro['Litros']?.toString() ?? '',
                  ],
                ],
                headerStyle: pw.TextStyle(font: robotoBold),
                cellStyle: pw.TextStyle(font: roboto),
              ),
              pw.SizedBox(height: 20),
              // Verifica las imágenes antes de agregarlas al PDF
              ...imageWidgets.whereType<pw.Widget>().toList(),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..download = 'reporte_gasolina_${registro['Nombre Operador']}.pdf';
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

Future<void> _downloadExcel(List<Map<String, dynamic>> registros) async {
  var excel = Excel.createExcel();
  var sheet = excel['Sheet1'];

  // Definir los encabezados de las columnas
  sheet.appendRow([
    'Operador',
    'Gasolinera',
    'Fecha',
    'Hora',
    'Placas',
    'Importe',
    'Litros',
    'Foto Placas',
    'Foto Unidad',
    'Foto Ticket',
    'Foto Odometro',
  ]);

  // Llenar la hoja con los datos de los registros
  for (var registro in registros) {
    // Obtener los URLs de las imágenes
    final fotoPlacasUrl = registro['Foto Placas']?[0]['url'] ?? '';
    final fotoUnidadUrl = registro['Foto Unidad']?[0]['url'] ?? '';
    final fotoTicketUrl = registro['Foto Ticket']?[0]['url'] ?? '';
    final fotoOdometroUrl = registro['Foto Odometro']?[0]['url'] ?? '';

    // Verificar el acceso a las imágenes
    await _testImageAccess(fotoPlacasUrl, 'patW8Q98FkL4zObhH.c46b48da5580a5cb1ecfea2b24a2cd56f4be18a30bcba7b2e7747684f39352ec');
    await _testImageAccess(fotoUnidadUrl, 'patW8Q98FkL4zObhH.c46b48da5580a5cb1ecfea2b24a2cd56f4be18a30bcba7b2e7747684f39352ec');
    await _testImageAccess(fotoTicketUrl, 'patW8Q98FkL4zObhH.c46b48da5580a5cb1ecfea2b24a2cd56f4be18a30bcba7b2e7747684f39352ec');
    await _testImageAccess(fotoOdometroUrl, 'patW8Q98FkL4zObhH.c46b48da5580a5cb1ecfea2b24a2cd56f4be18a30bcba7b2e7747684f39352ec');

    // Crear una fila con los datos
    sheet.appendRow([
      registro['Nombre Operador'] ?? '',
      registro['Nombre Gasolinera'] ?? '',
      registro['Fecha'] ?? '',
      registro['Hora'] ?? '',
      registro['Placas'] ?? '',
      registro['Importe']?.toString() ?? '',
      registro['Litros']?.toString() ?? '',
      fotoPlacasUrl, // URL de la foto de las placas
      fotoUnidadUrl, // URL de la foto de la unidad
      fotoTicketUrl, // URL de la foto del ticket
      fotoOdometroUrl, // URL de la foto del odómetro
    ]);
  }

  // Convertir el archivo Excel a bytes
  var excelBytes = excel.encode();

  if (excelBytes != null) {
    // Crear un Blob con los bytes del archivo Excel
    final blob = html.Blob([Uint8List.fromList(excelBytes)], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Crear un enlace de descarga
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..download = 'reporte_gasolina.xlsx';
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}
Future<void> _testImageAccess(String imageUrl, String authToken) async {
  try {
    final response = await http.get(
      Uri.parse(imageUrl),
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      print('La imagen es accesible');
    } else {
      print('Error al acceder a la imagen: ${response.statusCode}');
    }
  } catch (e) {
    print('Excepción al acceder a la imagen: $e');
  }
}

}


