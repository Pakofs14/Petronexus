import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:signature/signature.dart';
import 'package:http/http.dart' as http;

class EntradaAlmacenPage extends StatefulWidget {
  final String usuario;

  const EntradaAlmacenPage({super.key, required this.usuario});

  @override
  State<EntradaAlmacenPage> createState() => _EntradaAlmacenPageState();
}

class _EntradaAlmacenPageState extends State<EntradaAlmacenPage> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _partidas = [];
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _folioController = TextEditingController();
  String? _tipoPartidaSeleccionada;
  Uint8List? _firmaRecibe;

  // Instrucciones para cada campo
  final Map<String, String> _instrucciones = {
    'folio': '1.- Anotar el número consecutivo en cada ocasión que se realice un movimiento.',
    'proveedor': '2.- Anotar la razón social del Proveedor.',
    'ordenCompra': '3.- Anotar el número de orden proporcionado por el sistema SAE.',
    'departamento': '4.- Anotar el departamento que solicitó los artículos o productos.',
    'usuarioSae': '5.- Anotar la clave de usuario del sistema SAE.',
    'almacenDestino': '6.- Anotar el almacén destino en el cual serán resguardados los artículos o productos.',
    'folioFactura': '7.- Anotar el folio de la factura generada por el Proveedor.',
    'base': '8.- Indicar el nombre de la base desde la cual se está gestionando la entrada del material.',
    'contrato': '9.- Anotar el número de contrato para el cual será ocupado el material.',
    'fechaRecepcion': '10.- Anotar la fecha de recepción que se esta entregando el material.',
    'recepcion': '11.- Anotar el número de recepción generada por el sistema SAE.',
    'descripcion': '12.- Anotar el nombre de los materiales tal cual se menciona en la factura.',
    'unidadMedida': '13.- Anotar la unidad de medida si son piezas, litros u otra unidad de medida.',
    'precioUnitario': '14.- Anotar el costo unitario de cada artículo o producto.',
    'cantidadSolicitada': '15.- Anotar la cantidad solicitada de acuerdo a las necesidades de la orden compra.',
    'cantidadEntregada': '16.- Anotar la cantidad realmente entregada por parte del proveedor para cubrir la necesidad de la operación.',
    'observaciones': '18.- Anotar en caso de ser necesario las condiciones o algún comentario referente a los artículos recibidos.',
    'tipoPartida': '19.- Seleccionar el grupo correspondiente de los artículos a los que pertenecen los productos recibidos.',
  };

  // Controladores para los campos del formulario
  final TextEditingController _proveedorController = TextEditingController();
  final TextEditingController _ordenCompraController = TextEditingController();
  final TextEditingController _departamentoController = TextEditingController();
  final TextEditingController _usuarioSaeController = TextEditingController();
  final TextEditingController _almacenDestinoController = TextEditingController();
  final TextEditingController _folioFacturaController = TextEditingController();
  final TextEditingController _baseController = TextEditingController();
  final TextEditingController _contratoController = TextEditingController();
  final TextEditingController _recepcionController = TextEditingController();

  //Nombre de quien recibe  
  final TextEditingController _nombreRecibeController = TextEditingController();

  // Controladores para partidas
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _unidadMedidaController = TextEditingController();
  final TextEditingController _precioUnitarioController = TextEditingController();
  final TextEditingController _cantidadSolicitadaController = TextEditingController();
  final TextEditingController _cantidadEntregadaController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();

  static const airtableApiToken = 'patW8Q98FkL4zObhH.c46b48da5580a5cb1ecfea2b24a2cd56f4be18a30bcba7b2e7747684f39352ec';
  static const airtableBaseId = 'appk2qomcs0VaYbCD';
  static const airtableTableName = 'Entradas';
  static const url = 'https://api.airtable.com/v0/$airtableBaseId/$airtableTableName';


  @override
  void initState() {
    super.initState();
    _fechaController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _folioController.text = '1';
    _proveedorController.text = 'Bardahl de México S. de R.L. de C.V.';
    _tipoPartidaSeleccionada = 'ACEITE'; // Valor por defecto
    _unidadMedidaController.text = 'L';
      // Configurar los controladores para convertir a mayúsculas
    _configurarControladoresMayusculas();
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _folioController.dispose();
    _proveedorController.dispose();
    _ordenCompraController.dispose();
    _departamentoController.dispose();
    _usuarioSaeController.dispose();
    _almacenDestinoController.dispose();
    _folioFacturaController.dispose();
    _baseController.dispose();
    _contratoController.dispose();
    _recepcionController.dispose();
    _descripcionController.dispose();
    _unidadMedidaController.dispose();
    _precioUnitarioController.dispose();
    _cantidadSolicitadaController.dispose();
    _cantidadEntregadaController.dispose();
    _observacionesController.dispose();
    _nombreRecibeController.dispose();
    super.dispose();
  }

  void _configurarControladoresMayusculas() {
    // Lista de todos los controladores de texto
    final controladores = [
      _folioController,
      _proveedorController,
      _ordenCompraController,
      _departamentoController,
      _usuarioSaeController,
      _almacenDestinoController,
      _folioFacturaController,
      _baseController,
      _contratoController,
      _recepcionController,
      _nombreRecibeController,
      _descripcionController,
      _observacionesController,
    ];

    // Configurar cada controlador para convertir a mayúsculas
    for (final controller in controladores) {
      controller.addListener(() {
        final text = controller.text.toUpperCase();
        if (controller.text != text) {
          controller.value = controller.value.copyWith(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );
        }
      });
    }
    
    // Configurar controladores numéricos para evitar conflicto con las mayúsculas
    _precioUnitarioController.addListener(_validarNumero);
    _cantidadSolicitadaController.addListener(_validarNumero);
    _cantidadEntregadaController.addListener(_validarNumero);
  }

  void _validarNumero() {
    final controladores = [
      _precioUnitarioController,
      _cantidadSolicitadaController,
      _cantidadEntregadaController,
    ];
    
    for (final controller in controladores) {
      final text = controller.text.replaceAll(RegExp(r'[^0-9.]'), '');
      if (controller.text != text) {
        controller.value = controller.value.copyWith(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    }
  }

  void _mostrarInstruccion(BuildContext context, String campo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Instrucción de llenado'),
        content: Text(_instrucciones[campo] ?? 'Instrucción no disponible'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _capturarFirma(BuildContext context) async {
    final signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    final result = await showDialog<Uint8List?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Firmar'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Signature(
                  controller: signatureController,
                  height: 200,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botón para limpiar
                  ElevatedButton.icon(
                    icon: const Icon(Icons.clear, size: 20),
                    label: const Text('Limpiar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () => signatureController.clear(),
                  ),
                  
                  // Botón para cancelar
                  ElevatedButton.icon(
                    icon: const Icon(Icons.cancel, size: 20),
                    label: const Text('Cancelar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  
                  // Botón para guardar
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      if (signatureController.isNotEmpty) {
                        try {
                          final bytes = await signatureController.toPngBytes();
                          if (bytes != null) {
                            Navigator.pop(context, bytes);
                          } else {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error al guardar la firma'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Firme en el área superior',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );

    // Liberar recursos del controlador
    signatureController.dispose();

    if (result != null) {
      setState(() {
        _firmaRecibe = result;
      });
    }
  }
 
  void _agregarPartida() {
    if (_descripcionController.text.isEmpty || 
        _cantidadEntregadaController.text.isEmpty ||
        _precioUnitarioController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete los campos obligatorios de la partida')),
      );
      return;
    }

    setState(() {
      _partidas.add({
        'tipo': _tipoPartidaSeleccionada,
        'descripcion': _descripcionController.text,
        'unidad': _unidadMedidaController.text,
        'precio': double.tryParse(_precioUnitarioController.text) ?? 0,
        'solicitada': double.tryParse(_cantidadSolicitadaController.text) ?? 0,
        'entregada': double.tryParse(_cantidadEntregadaController.text) ?? 0,
        'total': (double.tryParse(_precioUnitarioController.text) ?? 0) * 
                (double.tryParse(_cantidadEntregadaController.text) ?? 0),
        'observaciones': _observacionesController.text,
      });

      // Limpiar campos
      _descripcionController.clear();
      _unidadMedidaController.clear();
      _precioUnitarioController.clear();
      _cantidadSolicitadaController.clear();
      _cantidadEntregadaController.clear();
      _observacionesController.clear();
      _tipoPartidaSeleccionada = null;
    });
  }

  void _eliminarPartida(int index) {
    setState(() {
      _partidas.removeAt(index);
    });
  }

  double _calcularSubtotal() {
    return _partidas.fold(0, (sum, item) => sum + (item['total'] as double));
  }

  double _calcularIva() {
    return _calcularSubtotal() * 0.16;
  }

  double _calcularTotal() {
    return _calcularSubtotal() + _calcularIva();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _fechaController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _validarYGenerarPDF(BuildContext context) async {
    // Validación de campos
    if (_partidas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe agregar al menos una partida')),
      );
      return;
    }

    if (_firmaRecibe == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe capturar la firma de quien recibe')),
      );
      return;
    }

    if (_nombreRecibeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese el nombre de quien recibe')),
      );
      return;
    }

    // Si todo está completo, preguntar por más partidas
    final agregarMas = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Agregar otra partida?'),
        content: const Text('¿Desea agregar otra partida antes de generar el reporte?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, generar PDF'),
          ),
        ],
      ),
    );

    if (agregarMas == false) {
      _generarPDF();
    }
  }

  Future<void> _generarPDF() async {
    try {
      // Validaciones iniciales (se mantienen igual)
      if (_partidas.isEmpty) throw Exception('Debe agregar al menos una partida');
      if (_firmaRecibe == null) throw Exception('Debe capturar la firma de quien recibe');
      if (_nombreRecibeController.text.isEmpty) throw Exception('Ingrese el nombre completo de quien recibe');

      // Preparar datos para Airtable (se mantiene igual)
      final Map<String, dynamic> datosGenerales = {
        'folio': _folioController.text,
        'fecha': _fechaController.text,
        'proveedor': _proveedorController.text,
        'folioFactura': _folioFacturaController.text,
        'ordenCompra': _ordenCompraController.text,
        'base': _baseController.text,
        'departamento': _departamentoController.text,
        'contrato': _contratoController.text,
        'usuarioSae': _usuarioSaeController.text,
        'almacenDestino': _almacenDestinoController.text,
        'recepcion': _recepcionController.text,
        'nombreRecibe': _nombreRecibeController.text,
      };

      await enviarEntradaAlmacen(
        datosGenerales: datosGenerales,
        partidas: _partidas,
      );

      // Generar el PDF con todos los datos
      final pdf = pw.Document();
      final headerStyle = pw.TextStyle(
        fontSize: 18,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.black,
      );
      final normalStyle = pw.TextStyle(
        fontSize: 12,
        color: PdfColors.black,
      );
      final boldStyle = pw.TextStyle(
        fontSize: 12,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.black,
      );

      // Calcular totales
      final subtotal = _calcularSubtotal();
      final iva = _calcularIva();
      final totalGeneral = _calcularTotal();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) => [
            // Encabezado
            pw.Header(
              level: 0,
              child: pw.Column(
                children: [
                  pw.Text('ENTRADA DE ALMACÉN', 
                      style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Fecha: ${_fechaController.text}', 
                          style: pw.TextStyle(fontSize: 16)),
                      pw.Text('Folio: ${_folioController.text}', 
                          style: pw.TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            
            // Sección de Información General
            pw.SizedBox(height: 20),
            pw.Text('Información General', style: headerStyle),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              border: null,
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(3),
              },
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              data: [
                ['Proveedor:', datosGenerales['proveedor']],
                ['Orden de Compra:', datosGenerales['ordenCompra']],
                ['Folio de Factura:', datosGenerales['folioFactura']],
                ['Base/Zona:', datosGenerales['base']],
                ['Departamento:', datosGenerales['departamento']],
                ['No. Contrato:', datosGenerales['contrato']],
                ['Usuario SAE:', datosGenerales['usuarioSae']],
                ['Almacén Destino:', datosGenerales['almacenDestino']],
                ['No. Recepción:', datosGenerales['recepcion']],
              ],
            ),
            
            // Sección de Partidas
            pw.SizedBox(height: 20),
            pw.Text('Detalle de Partidas', style: headerStyle),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              border: pw.TableBorder.all(),
              headerStyle: boldStyle,
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              headers: ['Tipo', 'Descripción', 'Unidad', 'Precio Unitario', 'Cant. Ent.', 'Total'],
              data: _partidas.map((partida) => [
                partida['tipo'] ?? '',
                partida['descripcion'] ?? '',
                partida['unidad'] ?? '',
                '\$${(partida['precio'] as double).toStringAsFixed(2)}',
                partida['entregada'].toString(),
                '\$${(partida['total'] as double).toStringAsFixed(2)}',
              ]).toList(),
            ),
            
            // Totales
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(
                      children: [
                        pw.Text('Subtotal: ', style: boldStyle),
                        pw.Text('\$${subtotal.toStringAsFixed(2)}', style: normalStyle),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      children: [
                        pw.Text('IVA (16%): ', style: boldStyle),
                        pw.Text('\$${iva.toStringAsFixed(2)}', style: normalStyle),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      children: [
                        pw.Text('TOTAL: ', style: boldStyle),
                        pw.Text('\$${totalGeneral.toStringAsFixed(2)}', 
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            
            // Firmas
            pw.SizedBox(height: 30),
            pw.Text('FIRMAS', style: headerStyle),
            pw.SizedBox(height: 10),
            pw.Divider(),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                // Firma Proveedor
                pw.Column(
                  children: [
                    pw.Text('PROVEEDOR', style: boldStyle),
                    pw.SizedBox(height: 40),
                    pw.Container(width: 150, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 5),
                    pw.Text('Nombre y Firma', style: normalStyle),
                  ],
                ),
                
                // Firma Recibe
                pw.Column(
                  children: [
                    pw.Text('RECIBE', style: boldStyle),
                    pw.Container(
                      width: 100,
                      height: 50,
                      child: pw.Image(pw.MemoryImage(_firmaRecibe!), 
                      fit: pw.BoxFit.contain,
                    )),
                    pw.SizedBox(height: 5),
                    pw.Text(_nombreRecibeController.text, style: normalStyle),
                  ],
                ),
                
                // Firma Vigilancia
                pw.Column(
                  children: [
                    pw.Text('VIGILANCIA', style: boldStyle),
                    pw.SizedBox(height: 40),
                    pw.Container(width: 150, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 5),
                    pw.Text('Nombre y Firma', style: normalStyle),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

      // Guardar y descargar PDF (se mantiene igual)
      final bytes = await pdf.save();
      final blob = html.Blob([Uint8List.fromList(bytes)], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..download = 'entrada_almacen_${_fechaController.text.replaceAll('/', '-')}.pdf';
      
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF generado y datos guardados en Airtable'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> enviarEntradaAlmacen({
    required Map<String, dynamic> datosGenerales,
    required List<Map<String, dynamic>> partidas,
  }) async {
    try {
      // 1. Validaciones iniciales
      if (partidas.isEmpty) {
        throw Exception('No hay partidas para enviar');
      }

      // 2. Validar campos obligatorios
      final camposRequeridos = {
        'Folio': datosGenerales['folio'],
        'Fecha': datosGenerales['fecha'],
        'Proveedor': datosGenerales['proveedor'],
        'Folio Factura': datosGenerales['folioFactura'],
        'Orden Compra': datosGenerales['ordenCompra'],
        'Departamento': datosGenerales['departamento'],
        'Usuario SAE': datosGenerales['usuarioSae'],
        'Almacén Destino': datosGenerales['almacenDestino'],
        'Nombre Recibe': datosGenerales['nombreRecibe'],
      };

      final camposFaltantes = camposRequeridos.entries
          .where((entry) => entry.value == null || entry.value.toString().trim().isEmpty)
          .map((entry) => entry.key)
          .toList();

      if (camposFaltantes.isNotEmpty) {
        throw Exception('Campos obligatorios faltantes:\n${camposFaltantes.map((c) => '• $c').join('\n')}');
      }

      // 3. Convertir valores numéricos
      final numeroOrdenCompra = int.tryParse(datosGenerales['ordenCompra'].toString()) ?? 0;
      final numeroContrato = int.tryParse(datosGenerales['contrato']?.toString() ?? '') ?? 0;
      final numeroRecepcion = int.tryParse(datosGenerales['recepcion']?.toString() ?? '') ?? 0;
      final numeroFolioFactura = int.tryParse(datosGenerales['folioFactura'].toString()) ?? 0;

      // 4. Validar partidas
      for (final partida in partidas) {
        if (partida['descripcion'] == null || partida['descripcion'].toString().trim().isEmpty) {
          throw Exception('Todas las partidas deben tener descripción');
        }
        if (partida['entregada'] == null || (partida['entregada'] as num) <= 0) {
          throw Exception('La cantidad entregada debe ser mayor que cero');
        }
      }

      // 5. Preparar headers
      final headers = {
        'Authorization': 'Bearer $airtableApiToken',
        'Content-Type': 'application/json',
      };

      // 6. Calcular totales
      final subtotalGeneral = _calcularSubtotal();
      final ivaGeneral = subtotalGeneral * 0.16;
      final totalGeneral = subtotalGeneral + ivaGeneral;

      // 7. Enviar cada partida
      final erroresPartidas = <String>[];

      for (final partida in partidas) {
        try {
          // Calcular totales por partida
          final precioUnitario = (partida['precio'] as num).toDouble();
          final cantidadEntregada = (partida['entregada'] as num).toDouble();
          final subtotalPartida = precioUnitario * cantidadEntregada;
          final ivaPartida = subtotalPartida * 0.16;
          final totalPartida = subtotalPartida + ivaPartida;

          // Preparar datos para Airtable con tipos correctos
          final data = {
            'fields': {
              // Campos de texto
              'Folio': datosGenerales['folio'].toString(),
              'Fecha de recepcion': datosGenerales['fecha'].toString(),
              'Proveedor': datosGenerales['proveedor'].toString(),
              'Base/Zona': datosGenerales['base']?.toString() ?? '',
              'Departamento solicitante': datosGenerales['departamento'].toString(),
              'Usuario SAE': datosGenerales['usuarioSae'].toString(),
              'Almacen destino': datosGenerales['almacenDestino'].toString(),
              'Nombre de quien recibe': datosGenerales['nombreRecibe'].toString(),
              'Tipo de partida': partida['tipo']?.toString() ?? '',
              'Descripcion del bien': partida['descripcion'].toString(),
              'Unidad de medida': partida['unidad']?.toString() ?? '',
              'Observaciones': partida['observaciones']?.toString() ?? '',

              // Campos numéricos enteros
              'Partidas': partidas.length,
              'Folio de factura': numeroFolioFactura,
              'Numero de orden de compra': numeroOrdenCompra,
              'Numero de contrato': numeroContrato,
              'Numero de recepcion': numeroRecepcion,
              'Cantidad solicitada': (partida['solicitada'] as num).toInt(),
              'Cantidad entregada': (partida['entregada'] as num).toInt(),

              // Campos numéricos decimales
              'Precio unitario': precioUnitario,
              'Subtotal partida': subtotalPartida,
              'IVA partida': ivaPartida,
              'Total partida': totalPartida,
              'Subtotal general': subtotalGeneral,
              'IVA general': ivaGeneral,
              'Total general': totalGeneral,
            }
          };

          // Enviar a Airtable
          final response = await http.post(
            Uri.parse(url),
            headers: headers,
            body: json.encode(data),
          );

          if (response.statusCode != 200) {
            final errorData = json.decode(response.body);
            erroresPartidas.add('''
  Partida: ${partida['descripcion']}
  Error: ${errorData['error']?['type'] ?? 'Error desconocido'}
  Mensaje: ${errorData['error']?['message'] ?? response.body}
  Valores enviados:
  - Orden compra: $numeroOrdenCompra (${numeroOrdenCompra.runtimeType})
  - Contrato: $numeroContrato (${numeroContrato.runtimeType})
  - Folio factura: $numeroFolioFactura (${numeroFolioFactura.runtimeType})
  ''');
          }
        } catch (e) {
          erroresPartidas.add('Error procesando partida "${partida['descripcion']}": $e');
        }
      }

      if (erroresPartidas.isNotEmpty) {
        throw Exception('Errores en partidas:\n${erroresPartidas.join('\n')}');
      }

    } catch (e) {
      throw Exception('''
  Error al enviar entrada de almacén:
  ${e.toString()}

  Verifique que:
  1. Los campos numéricos contengan solo dígitos
  2. No haya campos obligatorios vacíos
  3. Los formatos de fecha sean correctos
  ''');
    }
  }
    
  Widget _buildFieldWithHelp({
    required String label,
    required String fieldKey,
    required TextEditingController controller,
    bool isRequired = false,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return SizedBox( // Añade SizedBox
      width: double.infinity, // Ocupa todo el ancho disponible
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.help_outline, size: 20),
            onPressed: () => _mostrarInstruccion(context, fieldKey),
          ),
        ),
        validator: isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Este campo es requerido';
                }
                return null;
              }
            : null,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Lista de contratos predefinidos
    final List<String> contratos = ['850', '853', '860', '870', '871', '801', '802', '819', '615'];
    // Lista de unidades de medida
    final List<String> unidadesMedida = ['PZA', 'KG', 'L', 'M', 'M3', 'KIT', 'JUEGO'];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrada Almacén', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFC0261F),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'ENTRADA DE ALMACÉN',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              // Campo de Folio
              _buildFieldWithHelp(
                label: 'Folio',
                fieldKey: 'folio',
                controller: _folioController,
                isRequired: true,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),

              // Primera fila de campos
              Row(
                children: [
                  Expanded(
                    child: _buildFieldWithHelp(
                      label: 'Nombre del Proveedor',
                      fieldKey: 'proveedor',
                      controller: _proveedorController,
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildFieldWithHelp(
                      label: 'Folio de Factura',
                      fieldKey: 'folioFactura',
                      controller: _folioFacturaController,
                      isRequired: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Segunda fila de campos
              Row(
                children: [
                  Expanded(
                    child: _buildFieldWithHelp(
                      label: 'No. Orden de Compra',
                      fieldKey: 'ordenCompra',
                      controller: _ordenCompraController,
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildFieldWithHelp(
                      label: 'Base/Zona',
                      fieldKey: 'base',
                      controller: _baseController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              // Tercera fila de campos - Modificada para el contrato
              Row(
                children: [
                  Expanded(
                    child: _buildFieldWithHelp(
                      label: 'Departamento Solicitante',
                      fieldKey: 'departamento',
                      controller: _departamentoController,
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _contratoController.text.isEmpty ? null : _contratoController.text,
                      decoration: InputDecoration(
                        labelText: 'No. de Contrato',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.help_outline, size: 20),
                          onPressed: () => _mostrarInstruccion(context, 'contrato'),
                        ),
                      ),
                      items: contratos.map((contrato) {
                        return DropdownMenuItem<String>(
                          value: contrato,
                          child: Text(contrato),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _contratoController.text = value ?? '';
                        });
                      },
                      hint: const Text('Seleccione un contrato'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Cuarta fila de campos
              Row(
                children: [
                  Expanded(
                    child: _buildFieldWithHelp(
                      label: 'Usuario SAE Almacenista',
                      fieldKey: 'usuarioSae',
                      controller: _usuarioSaeController,
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildFieldWithHelp(
                      label: 'Fecha de Recepción',
                      fieldKey: 'fechaRecepcion',
                      controller: _fechaController,
                      isRequired: true,
                      readOnly: true,
                      onTap: () => _seleccionarFecha(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Quinta fila de campos
              Row(
                children: [
                  Expanded(
                    child: _buildFieldWithHelp(
                      label: 'Almacén Destino',
                      fieldKey: 'almacenDestino',
                      controller: _almacenDestinoController,
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildFieldWithHelp(
                      label: 'No. de Recepción',
                      fieldKey: 'recepcion',
                      controller: _recepcionController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sección de partidas
              const Text(
                'PARTIDAS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              // Tipo de partida
              DropdownButtonFormField<String>(
                value: _tipoPartidaSeleccionada, // Esto mostrará el valor por defecto
                decoration: InputDecoration(
                  labelText: 'Tipo de Partida',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.help_outline, size: 20),
                    onPressed: () => _mostrarInstruccion(context, 'tipoPartida'),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'MAQUINARIA', child: Text('Maquinaria')),
                  DropdownMenuItem(value: 'HERRAMIENTAS', child: Text('Herramientas')),
                  DropdownMenuItem(value: 'REFACCIONES', child: Text('Refacciones')),
                  DropdownMenuItem(value: 'COMBUSTIBLE', child: Text('Combustible')),
                  DropdownMenuItem(value: 'ACEITE', child: Text('Aceite')),
                  DropdownMenuItem(value: 'ARTÍCULOS', child: Text('Artículos')),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipoPartidaSeleccionada = value;
                  });
                },
              ),
              const SizedBox(height: 10),

              // Campos para agregar partida
              _buildFieldWithHelp(
                label: 'Descripción del Bien',
                fieldKey: 'descripcion',
                controller: _descripcionController,
              ),
              const SizedBox(height: 10),
              
              Row(
                children: [
                  Expanded(
                    child: // En el Dropdown de unidades de medida, modificar así:
                    DropdownButtonFormField<String>(
                      value: _unidadMedidaController.text.isEmpty ? 'L' : _unidadMedidaController.text,
                      decoration: InputDecoration(
                        labelText: 'Unidad de Medida',
                        border: const OutlineInputBorder(),
                      ),
                      items: unidadesMedida.map((unidad) {
                        return DropdownMenuItem<String>(
                          value: unidad,
                          child: Text(unidad),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _unidadMedidaController.text = value ?? 'L';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildFieldWithHelp(
                      label: 'Precio Unitario',
                      fieldKey: 'precioUnitario',
                      controller: _precioUnitarioController,
                      keyboardType: TextInputType.number,
                      isRequired: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              Row(
                children: [
                  Expanded(
                    child: _buildFieldWithHelp(
                      label: 'Cant. Solicitada',
                      fieldKey: 'cantidadSolicitada',
                      controller: _cantidadSolicitadaController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildFieldWithHelp(
                      label: 'Cant. Entregada*',
                      fieldKey: 'cantidadEntregada',
                      controller: _cantidadEntregadaController,
                      keyboardType: TextInputType.number,
                      isRequired: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              _buildFieldWithHelp(
                label: 'Observaciones',
                fieldKey: 'observaciones',
                controller: _observacionesController,
              ),
              const SizedBox(height: 10),
              // Modificar el botón de agregar partida en el build:
              ElevatedButton(
                onPressed: _agregarPartida,
                child: Text(_partidas.isEmpty ? 'Agregar Partida' : 'Agregar Otra Partida'),
              ),
              const SizedBox(height: 20),

              // Lista de partidas agregadas
              if (_partidas.isNotEmpty) ...[
                const Text(
                  'Partidas Registradas:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ..._partidas.map((partida) {
                  final index = _partidas.indexOf(partida);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(partida['descripcion']),
                      subtitle: Text(
                        '${partida['entregada']} ${partida['unidad']} x \$${partida['precio']} = \$${partida['total'].toStringAsFixed(2)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminarPartida(index),
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),

                // Totales
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('SUBTOTAL:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('\$${_calcularSubtotal().toStringAsFixed(2)}'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('IVA (16%):', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('\$${_calcularIva().toStringAsFixed(2)}'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('TOTAL:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('\$${_calcularTotal().toStringAsFixed(2)}', 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Firmas
              const SizedBox(height: 30),
              const Text(
                'FIRMAS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('PROVEEDOR', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 50),
                      SizedBox(
                        width: 150,
                        child: Divider(color: Colors.grey[700], thickness: 1),
                      ),
                      const Text('Nombre y Firma'),
                    ],
                  ),            
                  Column(
                    children: [
                      const Text('RECIBE', style: TextStyle(fontWeight: FontWeight.bold)),
                      if (_firmaRecibe != null)
                        Image.memory(_firmaRecibe!, height: 80),
                      SizedBox( // Añade SizedBox para limitar el ancho
                        width: 200, // o el ancho que prefieras
                        child: TextFormField(
                          controller: _nombreRecibeController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre completo de quien recibe',
                            border: OutlineInputBorder(),
                          ),
                          // Añade esto para preservar exactamente lo que el usuario escribe
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.none, // No forzar mayúsculas
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Este campo es obligatorio';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _capturarFirma(context),
                        child: const Text('Capturar Firma'),
                      ),
                    ],
                  ),            
                  Column(
                    children: [
                      const Text('VIGILANCIA', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 50),
                      SizedBox(
                        width: 150,
                        child: Divider(color: Colors.grey[700], thickness: 1),
                      ),
                      const Text('Nombre y Firma'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _validarYGenerarPDF(context), // Nueva función
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC0261F),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('ENVIAR'),
                ),
              ),
              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }
}