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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchDataFromAirtable();
  }

  @override
  void dispose() {
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
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lista de registros',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.swipe, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Text(
                          'Desliza horizontalmente para ver todos los campos',
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      thickness: 8.0,
                      radius: Radius.circular(4.0),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            sortColumnIndex: _sortColumnIndex,
                            sortAscending: _sortAscending,
                            columnSpacing: 12,
                            headingRowHeight: 50,
                            dataRowMinHeight: 40,
                            border: TableBorder(
                              horizontalInside:
                                  BorderSide(color: Colors.grey[300]!),
                              verticalInside:
                                  BorderSide(color: Colors.grey[300]!),
                              bottom: BorderSide(color: Colors.grey[300]!),
                              top: BorderSide(color: Colors.grey[300]!),
                              left: BorderSide(color: Colors.grey[300]!),
                              right: BorderSide(color: Colors.grey[300]!),
                            ),
                            columns: [
                              DataColumn(
                                label: Expanded(
                                    child: Text('Contrato',
                                        textAlign: TextAlign.center)),
                                onSort: (columnIndex, ascending) {
                                  _sort<String>(
                                      (registro) => registro['Contrato'] ?? '',
                                      columnIndex,
                                      ascending);
                                },
                              ),
                              DataColumn(
                                label: Expanded(
                                    child: Text('Operador',
                                        textAlign: TextAlign.center)),
                                onSort: (columnIndex, ascending) {
                                  _sort<String>(
                                      (registro) =>
                                          registro['Nombre Operador'] ?? '',
                                      columnIndex,
                                      ascending);
                                },
                              ),
                              DataColumn(
                                label: Expanded(
                                    child: Text('Gasolinera',
                                        textAlign: TextAlign.center)),
                                onSort: (columnIndex, ascending) {
                                  _sort<String>(
                                      (registro) =>
                                          registro['Nombre Gasolinera'] ?? '',
                                      columnIndex,
                                      ascending);
                                },
                              ),
                              DataColumn(
                                label: Expanded(
                                    child: Text('Tipo Gasolina',
                                        textAlign: TextAlign.center)),
                                onSort: (columnIndex, ascending) {
                                  _sort<String>(
                                      (registro) => registro['Gasolina'] ?? '',
                                      columnIndex,
                                      ascending);
                                },
                              ),
                              DataColumn(
                                label: Expanded(
                                    child: Text('Fecha',
                                        textAlign: TextAlign.center)),
                                onSort: (columnIndex, ascending) {
                                  _sort<String>(
                                      (registro) => registro['Fecha'] ?? '',
                                      columnIndex,
                                      ascending);
                                },
                              ),
                              DataColumn(
                                label: Expanded(
                                    child: Text('Hora',
                                        textAlign: TextAlign.center)),
                                onSort: (columnIndex, ascending) {
                                  _sort<String>(
                                      (registro) => registro['Hora'] ?? '',
                                      columnIndex,
                                      ascending);
                                },
                              ),
                              DataColumn(
                                label: Expanded(
                                    child: Text('Tipo Vehículo',
                                        textAlign: TextAlign.center)),
                                onSort: (columnIndex, ascending) {
                                  _sort<String>(
                                      (registro) =>
                                          registro['Tipo Vehiculo'] ?? '',
                                      columnIndex,
                                      ascending);
                                },
                              ),
                              DataColumn(
                                label: Expanded(
                                    child: Text('Placas',
                                        textAlign: TextAlign.center)),
                                onSort: (columnIndex, ascending) {
                                  _sort<String>(
                                      (registro) => registro['Placas'] ?? '',
                                      columnIndex,
                                      ascending);
                                },
                              ),
                              DataColumn(
                                label: Expanded(
                                    child: Text('Importe',
                                        textAlign: TextAlign.center)),
                                onSort: (columnIndex, ascending) {
                                  _sort<num>(
                                      (registro) => registro['Importe'] ?? 0,
                                      columnIndex,
                                      ascending);
                                },
                              ),
                              DataColumn(
                                label: Expanded(
                                    child: Text('Litros',
                                        textAlign: TextAlign.center)),
                                onSort: (columnIndex, ascending) {
                                  _sort<num>(
                                      (registro) => registro['Litros'] ?? 0,
                                      columnIndex,
                                      ascending);
                                },
                              ),
                              DataColumn(
                                label: Expanded(
                                    child: Text('Precio Litros',
                                        textAlign: TextAlign.center)),
                                onSort: (columnIndex, ascending) {
                                  _sort<num>(
                                      (registro) =>
                                          registro['Precio Litros'] ?? 0,
                                      columnIndex,
                                      ascending);
                                },
                              ),
                              DataColumn(
                                label: Expanded(
                                    child: Text('Odometro',
                                        textAlign: TextAlign.center)),
                                onSort: (columnIndex, ascending) {
                                  _sort<num>(
                                      (registro) => registro['Odometro'] ?? 0,
                                      columnIndex,
                                      ascending);
                                },
                              ),
                              DataColumn(
                                label: Expanded(
                                    child: Text('Diferencia Km',
                                        textAlign: TextAlign.center)),
                                onSort: (columnIndex, ascending) {
                                  _sort<num>(
                                      (registro) =>
                                          registro['Diferencia Kilometros'] ??
                                          0,
                                      columnIndex,
                                      ascending);
                                },
                              ),
                              DataColumn(
                                label: Expanded(
                                    child: Text('Rendimiento',
                                        textAlign: TextAlign.center)),
                                onSort: (columnIndex, ascending) {
                                  _sort<String>(
                                      (registro) =>
                                          registro['Rendimiento']?.toString() ??
                                          '',
                                      columnIndex,
                                      ascending);
                                },
                              ),
                              DataColumn(
                                label: Expanded(
                                    child: Text('Folio Ticket',
                                        textAlign: TextAlign.center)),
                                onSort: (columnIndex, ascending) {
                                  _sort<String>(
                                      (registro) =>
                                          registro['Folio Ticket'] ?? '',
                                      columnIndex,
                                      ascending);
                                },
                              ),
                              DataColumn(
                                label: Expanded(
                                    child: Text('Descargar',
                                        textAlign: TextAlign.center)),
                              ),
                            ],
                            rows: _registros.map((registro) {
                              return DataRow(cells: [
                                DataCell(Text(registro['Contrato'] ?? '')),
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
                                DataCell(Text(registro['Gasolina'] ?? '')),
                                DataCell(Text(registro['Fecha'] ?? '')),
                                DataCell(Text(registro['Hora'] ?? '')),
                                DataCell(Text(registro['Tipo Vehiculo'] ?? '')),
                                DataCell(Text(registro['Placas'] ?? '')),
                                // Celda para Importe (modificada)
                                DataCell(
                                  Text(
                                    (registro['Importe'] != null &&
                                            registro['Importe']
                                                .toString()
                                                .isNotEmpty)
                                        ? '\$${double.tryParse(registro['Importe'].toString())?.toStringAsFixed(2) ?? '0.00'}'
                                        : '\$0.00',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                // Celda para Litros (modificada)
                                DataCell(
                                  Text(
                                    (registro['Litros'] != null &&
                                            registro['Litros']
                                                .toString()
                                                .isNotEmpty)
                                        ? '${double.tryParse(registro['Litros'].toString())?.toStringAsFixed(2) ?? '0.00'} L'
                                        : '0.00 L',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                // Celda para Precio Litros (modificada)
                                DataCell(
                                  Text(
                                    (registro['Precio Litros'] != null &&
                                            registro['Precio Litros']
                                                .toString()
                                                .isNotEmpty)
                                        ? '\$${double.tryParse(registro['Precio Litros'].toString())?.toStringAsFixed(2) ?? '0.00'}'
                                        : '\$0.00',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                // Celda para Odometro (modificada)
                                DataCell(
                                  Text(
                                    (registro['Odometro'] != null &&
                                            registro['Odometro']
                                                .toString()
                                                .isNotEmpty)
                                        ? '${double.tryParse(registro['Odometro'].toString())?.toStringAsFixed(0) ?? '0'} km'
                                        : '0 km',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                // Celda para Diferencia Kilometros (modificada)
                                DataCell(
                                  Text(
                                    (registro['Diferencia Kilometros'] !=
                                                null &&
                                            registro['Diferencia Kilometros']
                                                .toString()
                                                .isNotEmpty)
                                        ? '${double.tryParse(registro['Diferencia Kilometros'].toString())?.toStringAsFixed(0) ?? '0'} km'
                                        : '0 km',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                // Celda para Rendimiento (modificada)
                                DataCell(
                                  Text(
                                    (registro['Rendimiento'] != null &&
                                            registro['Rendimiento']
                                                .toString()
                                                .isNotEmpty)
                                        ? '${double.tryParse(registro['Rendimiento'].toString())?.toStringAsFixed(2) ?? '0.00'} km/L'
                                        : '0.00 km/L',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                DataCell(Text(registro['Folio Ticket'] ?? '')),
                                DataCell(
                                  ElevatedButton(
                                    onPressed: () =>
                                        _generateAndDownloadPdf(registro),
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
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _fetchDataFromAirtable() async {
    final airtableApiToken =
        'patW8Q98FkL4zObhH.c46b48da5580a5cb1ecfea2b24a2cd56f4be18a30bcba7b2e7747684f39352ec';
    final airtableBaseId = 'appk2qomcs0VaYbCD';
    final airtableTableName = 'Gasolina';
    final url =
        'https://api.airtable.com/v0/$airtableBaseId/$airtableTableName';

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
          _registros =
              List<Map<String, dynamic>>.from(data['records'].map((record) {
            return {
              'Contrato': record['fields']['Contrato'] ?? '',
              'Nombre Operador': record['fields']['Nombre Operador'] ?? '',
              'Nombre Gasolinera': record['fields']['Nombre Gasolinera'] ?? '',
              'Gasolina': record['fields']['Gasolina'] ?? '',
              'Fecha': record['fields']['Fecha'] ?? '',
              'Hora': record['fields']['Hora'] ?? '',
              'Tipo Vehiculo': record['fields']['Tipo Vehiculo'] ?? '',
              'Placas': record['fields']['Placas'] ?? '',
              'Importe': double.tryParse(
                      record['fields']['Importe']?.toString() ?? '0') ??
                  0,
              'Litros': double.tryParse(
                      record['fields']['Litros']?.toString() ?? '0') ??
                  0,
              'Precio Litros': double.tryParse(
                      record['fields']['Precio Litros']?.toString() ?? '0') ??
                  0,
              'Odometro': double.tryParse(
                      record['fields']['Odometro']?.toString() ?? '0') ??
                  0,
              'Diferencia Kilometros': double.tryParse(
                      record['fields']['Diferencia Kilometros']?.toString() ??
                          '0') ??
                  0,
              'Rendimiento': double.tryParse(
                      record['fields']['Rendimiento']?.toString() ?? '0') ??
                  0,
              'Folio Ticket': record['fields']['Folio Ticket'] ?? '',
              'Foto Placas': record['fields']['Foto Placas'],
              'Foto Unidad': record['fields']['Foto Unidad'],
              'Foto Ticket': record['fields']['Foto Ticket'],
              'Foto Odometro': record['fields']['Foto Odometro'],
            };
          }));
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

  void _sort<T>(Comparable<T> Function(Map<String, dynamic> registro) getField,
      int columnIndex, bool ascending) {
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

  Future<void> showLoadingDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            content: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Generando reporte...',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<void> _generateAndDownloadPdf(Map<String, dynamic> registro) async {
    showLoadingDialog(context);

    try {
      final pdf = pw.Document();
      final roboto =
          pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
      final robotoBold =
          pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

      Future<pw.Widget?> processImage(String? imageUrl, String label) async {
        if (imageUrl == null) return pw.Text('$label: No disponible');
        try {
          final response = await http.get(Uri.parse(imageUrl));
          if (response.statusCode != 200)
            return pw.Text('$label: Error al cargar');
          final imageBytes = response.bodyBytes;
          final image = pw.MemoryImage(imageBytes);
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label, style: pw.TextStyle(font: robotoBold)),
              pw.SizedBox(height: 5),
              pw.Container(
                width: 450,
                height: 250,
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
                child: pw.Image(image, fit: pw.BoxFit.contain),
              ),
              pw.SizedBox(height: 10),
            ],
          );
        } catch (e) {
          return pw.Text('$label: No disponible');
        }
      }

      List<pw.Widget> imageWidgets = [];
      final placasWidget = await processImage(
          registro['Foto Placas']?[0]['url'], 'Foto de las Placas');
      final unidadWidget = await processImage(
          registro['Foto Unidad']?[0]['url'], 'Foto de la Unidad');
      final ticketWidget = await processImage(
          registro['Foto Ticket']?[0]['url'], 'Foto del Ticket');
      final odometroWidget = await processImage(
          registro['Foto Odometro']?[0]['url'], 'Foto del Odómetro');

      if (placasWidget != null) imageWidgets.add(placasWidget);
      if (unidadWidget != null) imageWidgets.add(unidadWidget);
      if (ticketWidget != null) imageWidgets.add(ticketWidget);
      if (odometroWidget != null) imageWidgets.add(odometroWidget);

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
                  tableWidth: pw.TableWidth.max,
                  headerStyle: pw.TextStyle(font: robotoBold),
                  cellStyle: pw.TextStyle(font: roboto),
                  headers: ['Campo', 'Valor'],
                  data: [
                    ['Contrato', registro['Contrato'] ?? ''],
                    ['Operador', registro['Nombre Operador'] ?? ''],
                    ['Gasolinera', registro['Nombre Gasolinera'] ?? ''],
                    ['Tipo de Gasolina', registro['Gasolina'] ?? ''],
                    ['Fecha', registro['Fecha'] ?? ''],
                    ['Hora', registro['Hora'] ?? ''],
                    ['Tipo de Vehículo', registro['Tipo Vehiculo'] ?? ''],
                    ['Placas', registro['Placas'] ?? ''],
                    [
                      'Importe',
                      '\$${registro['Importe']?.toStringAsFixed(2) ?? ''}'
                    ],
                    [
                      'Litros',
                      '${registro['Litros']?.toStringAsFixed(2) ?? ''} L'
                    ],
                    [
                      'Precio Litros',
                      '\$${registro['Precio Litros']?.toStringAsFixed(2) ?? ''}'
                    ],
                    [
                      'Odometro',
                      '${registro['Odometro']?.toStringAsFixed(0) ?? ''} km'
                    ],
                    [
                      'Diferencia Kilometros',
                      '${registro['Diferencia Kilometros']?.toStringAsFixed(0) ?? ''} km'
                    ],
                    ['Rendimiento', registro['Rendimiento']?.toString() ?? ''],
                    ['Folio Ticket', registro['Folio Ticket'] ?? ''],
                  ],
                ),
                pw.SizedBox(height: 20),
              ],
            );
          },
        ),
      );

      const int imagesPerPage = 2;
      for (var i = 0; i < imageWidgets.length; i += imagesPerPage) {
        final end = (i + imagesPerPage < imageWidgets.length)
            ? i + imagesPerPage
            : imageWidgets.length;
        final pageImages = imageWidgets.sublist(i, end);
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Header(
                    level: 0,
                    child: pw.Text(
                        'Reporte de Carga de Gasolina (Página ${i ~/ imagesPerPage + 2})',
                        style: pw.TextStyle(font: robotoBold, fontSize: 24)),
                  ),
                  pw.SizedBox(height: 20),
                  ...pageImages,
                ],
              );
            },
          ),
        );
      }

      final bytes = await pdf.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..download =
            'reporte_gasolina_${registro['Nombre Operador'] ?? 'reporte'}.pdf';
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      hideLoadingDialog(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Descarga exitosa!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      hideLoadingDialog(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar el PDF: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _downloadExcel(List<Map<String, dynamic>> registros) async {
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    // Encabezados convertidos a CellValue
    sheet.appendRow([
      TextCellValue('Contrato'),
      TextCellValue('Operador'),
      TextCellValue('Gasolinera'),
      TextCellValue('Tipo Gasolina'),
      TextCellValue('Fecha'),
      TextCellValue('Hora'),
      TextCellValue('Tipo Vehículo'),
      TextCellValue('Placas'),
      TextCellValue('Importe'),
      TextCellValue('Litros'),
      TextCellValue('Precio Litros'),
      TextCellValue('Odometro'),
      TextCellValue('Diferencia Kilometros'),
      TextCellValue('Rendimiento'),
      TextCellValue('Folio Ticket'),
      TextCellValue('Foto Placas'),
      TextCellValue('Foto Unidad'),
      TextCellValue('Foto Ticket'),
      TextCellValue('Foto Odometro'),
    ]);

    for (var registro in registros) {
      sheet.appendRow([
        TextCellValue(registro['Contrato']?.toString() ?? ''),
        TextCellValue(registro['Nombre Operador']?.toString() ?? ''),
        TextCellValue(registro['Nombre Gasolinera']?.toString() ?? ''),
        TextCellValue(registro['Gasolina']?.toString() ?? ''),
        TextCellValue(registro['Fecha']?.toString() ?? ''),
        TextCellValue(registro['Hora']?.toString() ?? ''),
        TextCellValue(registro['Tipo Vehiculo']?.toString() ?? ''),
        TextCellValue(registro['Placas']?.toString() ?? ''),
        TextCellValue(registro['Importe']?.toString() ?? ''),
        TextCellValue(registro['Litros']?.toString() ?? ''),
        TextCellValue(registro['Precio Litros']?.toString() ?? ''),
        TextCellValue(registro['Odometro']?.toString() ?? ''),
        TextCellValue(registro['Diferencia Kilometros']?.toString() ?? ''),
        TextCellValue(registro['Rendimiento']?.toString() ?? ''),
        TextCellValue(registro['Folio Ticket']?.toString() ?? ''),
        TextCellValue(registro['Foto Placas']?[0]['url']?.toString() ?? ''),
        TextCellValue(registro['Foto Unidad']?[0]['url']?.toString() ?? ''),
        TextCellValue(registro['Foto Ticket']?[0]['url']?.toString() ?? ''),
        TextCellValue(registro['Foto Odometro']?[0]['url']?.toString() ?? ''),
      ]);
    }

    var excelBytes = excel.encode();
    if (excelBytes != null) {
      final blob = html.Blob([Uint8List.fromList(excelBytes)],
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..download = 'reporte_gasolina.xlsx';
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    }
  }
}
