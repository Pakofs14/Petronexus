import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ReportePage extends StatefulWidget {
  @override
  _ReportePageState createState() => _ReportePageState();
}

class _ReportePageState extends State<ReportePage> {
  // Nuevo estado para controlar el tipo de vehículo seleccionado
  String? _tipoVehiculo;
  bool _showVehicleSelectionDialog = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _operadorController = TextEditingController();
  final TextEditingController _gasolineraController = TextEditingController();
  final TextEditingController _importeController = TextEditingController();
  final TextEditingController _litrosController = TextEditingController();
  final TextEditingController _placasController = TextEditingController();
  final TextEditingController _odometroController = TextEditingController();
  final TextEditingController _odometroUltimoController =
      TextEditingController();
  final TextEditingController _folioTicketController = TextEditingController();

  final List<String> _contratos = [
    '850',
    '851',
    '851 PANUCO',
    '853',
    '860',
    '870',
    '871',
    '801',
    '802',
    '819',
    '615'
  ];
  String? _contratoSeleccionado;
  bool _isContratoValid = false;

  // FocusNodes para cada campo de texto
  final FocusNode _operadorFocusNode = FocusNode();
  final FocusNode _gasolineraFocusNode = FocusNode();
  final FocusNode _importeFocusNode = FocusNode();
  final FocusNode _litrosFocusNode = FocusNode();
  final FocusNode _placasFocusNode = FocusNode();
  final FocusNode _odometroFocusNode = FocusNode();
  final FocusNode _odometroUltimoFocusNode = FocusNode();
  final FocusNode _folioTicketFocusNode = FocusNode();

  String _fechaHoy = DateFormat('dd/MM/yyyy').format(DateTime.now());
  String _horaActual = DateFormat('HH:mm').format(DateTime.now());

  String?
      _currentImageData; // Para almacenar la imagen actual que se está subiendo
  String? _currentImageType; // Para almacenar el tipo de imagen actual

  String? _fotoPlacasUrl;
  String? _fotoUnidadUrl;
  String? _fotoTicketUrl;
  String? _fotoOdometroUrl;
  String _diferenciaKilometros = '';
  String _rendimiento = '';

  // Estados de validación existentes
  bool _isImporteValid = false;
  bool _isLitrosValid = false;
  bool _isOdometroValid = false;
  // Variables de estado para validación
  bool _isOperadorValid = false;
  bool _isGasolineraValid = false;
  bool _isTipoGasolinaValid = false;
  bool _isPlacasValid = false; // Estado de validación para el campo de placas
  // Agrega este estado de validación
  bool _isFolioTicketValid = false;

  // Precio por litro calculado
  String _precioPorLitro = '';
  // Agrega esta variable:
  String? _operadorSeleccionado;
  // Lista de gasolineras
  final List<String> _gasolineras = [
    'ADMINISTRADORA DE GASOLINERAS ESMEGAS',
    'COMBUSTIBLES REAL S.A. DE C.V.',
    'DISTRIBUIDORA ENERGETICOS LA FE',
    'ESTACION DE SERVICIO FRAGOSO',
    'GASOLINERA EL JAIBO SA. DE CV., PANUCO, VER.',
    'GASOLINERA ENERGETICOS EXPRESS DE TAMAULIPAS',
    'GASOLINERA LOS TOROS',
    'GASOLINERA CHOCO GAS S.A. DE C.V.',
    'SERVICIOS INTEGRADOS DEL SUERTE DE VERACRUZ.',
  ];

  final List<String> _operadores = [
    'Adrian Santoyo Contreras',
    'Adrian Trujillo Reyes',
    'Aira E. Herrera S.',
    'Alberto Perez Hernandez',
    'Alberto Prianthi Garcia',
    'Alberto Guadalupe Jimenez Ramirez',
    'Amarelo Antonio Amarelo Herrera',
    'Angel Silverio Arteaga',
    'Armando Rojas Sanchez',
    'Armando Rojas Silverio',
    'Arvin Gagbran Velazquez Romero',
    'Bladimir Sandoval Hernandez',
    'Blas Hernandez Mendez',
    'Cesar Antonio Amarelo Herrera',
    'Christian Gerardo Torres Villacencio',
    'Constantino Mosqueda Bocanegra',
    'Danilo Giovanni Céspedes Zepeta',
    'David Josue Marquez Sanchez',
    'Eulogio Villanueva Salazar',
    'Eymar Rodriguez Cano',
    'Felipe de Jesus Montes Canales',
    'Fernando Bello Hernandez',
    'Fernando Hernandez Barandica',
    'Filiberto Cordero Martinez',
    'Genaro Jimenez García',
    'Gilberto Isai Franco Aguilar',
    'Gonzalo Muñoz Sarabia',
    'Hector Ivan Hernandez Rodriguez',
    'Hervert de Jesus Sanchez Lemus',
    'Humberto Osorio Rodriguez',
    'Irving Genaro Vazquez Ramirez',
    'Irving Magaña Perez',
    'Isai Garcia Ramirez',
    'Jesus Hernandez Gonzalez',
    'Jose Antonio Lopez Valdes',
    'Jose de Jesus Villanueva Salazar',
    'Jose Hernandez García',
    'Jose Luis Martínez Cabrera',
    'Jose Luis Tellez Islas',
    'Jose Luis Tique Tique',
    'Jose Octavio Gonzalez Carmona',
    'Jose Rodolfo Velazquez Gonzalez',
    'Jose Villanueva Salazar',
    'Josue Ivan Aran Ravelo',
    'Juan Carlos Bringas Martinez',
    'Juan Jose Diaz Castro',
    'Juan Manuel Vite Santes',
    'Juan Pablo Lopez Argüelles',
    'Juan Ramos Perez',
    'Juan Ramos Rosas',
    'Leonel Hernandez Gutierrez',
    'Leonel Mendez Villalba',
    'Luis Enrique Chagoya Ramirez',
    'Luis Javier Del Angel Granillo',
    'Marco Antonio Mauro Santes',
    'Miguel Angel García Jimenez',
    'Miguel Angel Tejeda Melo',
    'Miguel Angel Valdez Casados',
    'Misael Chacha Echeverria',
    'Omar Muratalla Espinoza',
    'Pánfilo Diaz Cruz',
    'Raul Eduardo Morales Castro',
    'Rafael Garcia Rojas',
    'Ranulfo Vera Rosas',
    'Ricardo García Marquez',
    'Roberto Cortez Baqueiro',
    'Soldador Alberto Guadalupe Jimenez Ramirez',
    'Ulises Eduardo Jimenez Lopez',
    'Vicente Herrera Gonzalez',
    'Zeferino de la Luna Perez',
    // Operadores adicionales del documento original que no estaban en tu lista inicial
    'Enrique Olguin Polanco',
    'Ricardo Alberto Reyes Perez',
    'Alvaro Vazquez Luna',
    'Luis Enrique Fuentes Mendez',
    'Ivan Alarcon Montelongo',
    'Francisco Javier Cortez Gomez',
    'Juan de Dios Rodriguez Lara',
  ];

  final List<String> _placasPredefinidas = [
    'GZ6352B',
    'GY1105D',
    'GY3840D',
    'HC2385A',
    'HD5130A',
    'HD5316A',
    'HD5317A',
    'HD5318A',
    'HD5322A',
    'HD5324A',
    'HD5327A',
    'LB56635',
    'LJS018B',
    'LJS020B',
    'LJS032B',
    'LJS036B',
    'LKD446A',
    'LKK810A',
    'MAF4415',
    'MGG6453',
    'MJZ7160',
    'MRF1787',
    'MRF5374',
    'MRF5385',
    'MTZ2442',
    'MTZ2445',
    'MTZ2446',
    'MTZ2454',
    'MTZ2456',
    'MTZ2463',
    'MTZ2466',
    'MTZ2482',
    'MTZ2496',
    'MTZ2497',
    'MTZ8632',
    'MTZ8635',
    'MUK8290',
    'MUK8353',
    'MUK8355',
    'MUK8381',
    'MUN5051',
    'MUN5064',
    'MUN5079',
    'MUN5081',
    'MUN5098',
    'MUN5142',
    'MUN5165',
    'MUN5171',
    'MUT9031',
    'MXJ5267',
    'NFW748A',
    'NFW755A',
    'NFW759A',
    'NFY991A',
    'NFY997A',
    'NNS195A',
    'NNS199A',
    'NNS205A',
    'NNS209A',
    'NNS213A',
    'NNS217A',
    'NRA673A',
    'NRA677A',
    'NRB809A',
    'NW82877',
    'PAZ9825',
    'WM29012',
    // Agregar las nuevas placas
    'WM29012',
    'MTZ2456',
    'HD5327A',
    'PAZ9825',
    'GZ0224A',
    'GZ0227A',
    'KZ99367',
    '29AG7M',
    'GZ1595B',
    'GZ1608B',
    'MTZ2485',
    'GZ2615E',
    'GY2465A'
  ];

  // Lista de placas que no tienen odómetro funcional
  final List<String> _placasSinOdometro = [
    'WM29012',
    'MTZ2456',
    'HD5327A',
    'PAZ9825',
    'GZ0224A',
    'GZ0227A',
    'KZ99367',
    '29AG7M',
    'GZ1595B',
    'GZ1608B',
    'MTZ2485',
    'GZ2615E',
    'GY2465A'
  ];
  // Tipo de gasolina seleccionada
  String? _tipoGasolina;

  @override
  void initState() {
    super.initState();
    // Agregar listeners a los FocusNodes
    _operadorFocusNode.addListener(
        () => _onFocusChange(_operadorFocusNode, _validateOperador));
    _gasolineraFocusNode.addListener(
        () => _onFocusChange(_gasolineraFocusNode, _validateGasolinera));
    _importeFocusNode
        .addListener(() => _onFocusChange(_importeFocusNode, _validateImporte));
    _litrosFocusNode
        .addListener(() => _onFocusChange(_litrosFocusNode, _validateLitros));
    _placasFocusNode
        .addListener(() => _onFocusChange(_placasFocusNode, _validatePlacas));
    _odometroFocusNode.addListener(
        () => _onFocusChange(_odometroFocusNode, _validateOdometro));
    _gasolineraController.text = 'GASOLINERA LOS TOROS';
    _validateGasolinera('GASOLINERA LOS TOROS');

    _litrosFocusNode.addListener(() {
      if (!_litrosFocusNode.hasFocus) {
        // Solo validar cuando pierde el foco
        _validateLitros(_litrosController.text);

        // Mostrar error si no es válido
        if (!_isLitrosValid && _litrosController.text.isNotEmpty) {
          _mostrarErrorDecimalesLitros(context,
              'Debe incluir punto decimal y exactamente 3 decimales (ejemplo: 45.678)');
        }
      }
    });
  }

  @override
  void dispose() {
    _operadorFocusNode.dispose();
    _gasolineraFocusNode.dispose();
    _importeFocusNode.dispose();
    _litrosFocusNode.dispose();
    _placasFocusNode.dispose();
    _odometroFocusNode.dispose();
    _odometroUltimoFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange(FocusNode focusNode, Function(String) validator) {
    if (!focusNode.hasFocus) {
      validator(_getControllerText(focusNode));
    }
  }

  String _getControllerText(FocusNode focusNode) {
    if (focusNode == _operadorFocusNode) return _operadorController.text;
    if (focusNode == _gasolineraFocusNode) return _gasolineraController.text;
    if (focusNode == _importeFocusNode) return _importeController.text;
    if (focusNode == _litrosFocusNode) return _litrosController.text;
    if (focusNode == _placasFocusNode) return _placasController.text;
    if (focusNode == _odometroFocusNode) return _odometroController.text;
    if (focusNode == _odometroUltimoFocusNode)
      return _odometroUltimoController.text;
    return '';
  }

  void _actualizarOdometroUltimo(String placa) async {
    if (placa.isEmpty) {
      setState(() {
        _odometroUltimoController.text = ''; // Limpiar el campo si no hay placa
      });
      return;
    }

    final ultimoOdometro = await _obtenerUltimoOdometro(placa);
    setState(() {
      _odometroUltimoController.text =
          ultimoOdometro?.toString() ?? 'No hay odómetro registrado';
    });
  }

  void _onPlacasChanged(String value) {
    _validatePlacas(value);

    if (_placasSinOdometro.contains(value)) {
      // Mostrar mensaje emergente para placas sin odómetro
      _mostrarMensajeOdometroNoFuncional();

      setState(() {
        _odometroController.text = '0';
        _odometroUltimoController.text = 'Odómetro no funciona';
        _isOdometroValid = true; // Forzar validación para permitir enviar
      });
    } else {
      _actualizarOdometroUltimo(value);
    }
  }

  void _mostrarMensajeOdometroNoFuncional() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Aviso importante'),
          content: Text('Esta unidad no tiene odómetro funcional. '
              'Por favor capture los datos restantes y tome foto del odómetro.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  void _validateFolioTicket(String value) {
    setState(() {
      _isFolioTicketValid = value.isNotEmpty;
    });
  }

  // En el método _validatePlacas:
  void _validatePlacas(String value) {
    bool isValid = value.isNotEmpty &&
        RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(value) && // Añade el guion
        value.length <= 10; // Aumenta el límite si es necesario

    if (_isPlacasValid != isValid) {
      setState(() {
        _isPlacasValid = isValid;
      });
    }
  }

  void _validateOdometro(String value) {
    bool isOdometroValid = false;

    if (value.isNotEmpty &&
        RegExp(r'^\d+$').hasMatch(value) &&
        value.length <= 10) {
      if (_odometroUltimoController.text.isEmpty ||
          _odometroUltimoController.text == 'No hay odómetro registrado') {
        // Si no hay odómetro registrado, consideramos válido si hay un valor numérico
        isOdometroValid = true;
      } else {
        try {
          int odometroActual = int.parse(value);
          int odometroUltimo = int.parse(_odometroUltimoController.text);
          isOdometroValid = odometroActual > odometroUltimo;
        } catch (e) {
          isOdometroValid = false;
        }
      }
    }

    setState(() {
      // Solo actualizamos el estado de validación del odómetro
      _isOdometroValid = isOdometroValid;
    });

    _calcularDiferenciaKilometros(); // Calcular la diferencia de kilómetros
  }

  void _validateOperador(String? value) {
    setState(() {
      _isOperadorValid = value != null && value.isNotEmpty;
    });
  }

  void _validateGasolinera(String value) {
    setState(() {
      _isGasolineraValid = value.isNotEmpty;
    });
  }

  void _validateTipoGasolina(String? value) {
    setState(() {
      _isTipoGasolinaValid = value != null && value.isNotEmpty;
    });
  }

  void _mostrarDescripcion(String descripcion) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ayuda'),
          content: Text(descripcion),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _openCameraOrFilePicker(Function(String) onImageSelected) {
    String userAgent = html.window.navigator.userAgent.toLowerCase();

    if (userAgent.contains('iphone') ||
        userAgent.contains('ipad') ||
        userAgent.contains('android')) {
      _openCamera(onImageSelected);
    } else {
      _openFilePicker(onImageSelected);
    }
  }

  void _openCamera(Function(String) onImageSelected) {
    html.FileUploadInputElement cameraInput = html.FileUploadInputElement();
    cameraInput.accept = 'image/*';
    cameraInput.click();

    cameraInput.onChange.listen((e) {
      final files = cameraInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();

        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((e) {
          String imageData = reader.result as String;
          onImageSelected(imageData);
        });
      }
    });
  }

  void _openFilePicker(Function(String) onImageSelected) {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files!.length == 1) {
        final file = files[0];
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((e) {
          onImageSelected(reader.result as String);
        });
      }
    });
  }

  void _validateContrato(String? value) {
    setState(() {
      _isContratoValid = value != null && value.isNotEmpty;
    });
  }

  Future<void> _uploadImageToImgBB(
      String imageData, Function(String) onSuccess, String imageType) async {
    final BuildContext dialogContext = context;

    // Mostrar diálogo de carga
    Completer<void> completer = Completer();
    Timer? timeoutTimer;

    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (context) {
        // Configurar timer para mostrar advertencia después de 5 segundos
        timeoutTimer = Timer(Duration(seconds: 5), () {
          if (!completer.isCompleted) {
            Navigator.of(context).pop(); // Cerrar diálogo de carga original
            _mostrarAdvertenciaConexion(dialogContext, completer);
          }
        });

        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpinKitFadingCircle(color: Colors.blue, size: 50.0),
              SizedBox(height: 20),
              Text('Subiendo imagen...'),
            ],
          ),
        );
      },
    );

    try {
      final url = 'https://api.imgbb.com/1/upload';
      final apiKey = 'a49c594e3a3152ca5168f2ed879db980';
      String base64Image = imageData.split(',').last;

      var body = {'key': apiKey, 'image': base64Image};

      // Configurar timeout para la petición HTTP
      var response = await http
          .post(
        Uri.parse(url),
        body: body,
      )
          .timeout(Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('La conexión está tardando demasiado');
      });

      // Cancelar el timer si la petición se completó antes
      timeoutTimer?.cancel();

      if (!completer.isCompleted) {
        Navigator.of(dialogContext).pop(); // Cerrar diálogo de carga
        completer.complete();
      }

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        String imageUrl = jsonResponse['data']['url'];
        onSuccess(imageUrl);

        String message = _getSuccessMessage(imageType);

        if (mounted) {
          ScaffoldMessenger.of(dialogContext).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        _handleApiError(response.statusCode, dialogContext);
      }
    } on TimeoutException catch (_) {
      if (!completer.isCompleted) {
        Navigator.of(dialogContext).pop(); // Cerrar diálogo de carga
        _mostrarAdvertenciaConexion(dialogContext, completer);
      }
    } catch (e) {
      timeoutTimer?.cancel();
      if (!completer.isCompleted) {
        Navigator.of(dialogContext).pop();
        completer.complete();
      }
      _handleUploadError(e, dialogContext);
    }
  }

  void _mostrarAdvertenciaConexion(BuildContext context, Completer completer) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          // ... resto del diálogo ...
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                completer.complete();
                if (_currentImageData != null && _currentImageType != null) {
                  _showImagePreviewDialog(_currentImageData!, (imageUrl) {
                    setState(() {
                      switch (_currentImageType!) {
                        case 'Foto Placas':
                          _fotoPlacasUrl = imageUrl;
                          break;
                        case 'Foto Unidad':
                          _fotoUnidadUrl = imageUrl;
                          break;
                        case 'Foto Ticket':
                          _fotoTicketUrl = imageUrl;
                          break;
                        case 'Foto Odómetro':
                          _fotoOdometroUrl = imageUrl;
                          break;
                      }
                    });
                  }, _currentImageType!);
                }
              },
              child: Text('Reintentar'),
            ),
            // ... botón Cancelar ...
          ],
        );
      },
    );
  }

  String _getSuccessMessage(String imageType) {
    switch (imageType) {
      case 'Foto Placas':
        return '✅ Foto de placas subida correctamente';
      case 'Foto Unidad':
        return '✅ Foto de la unidad subida correctamente';
      case 'Foto Ticket':
        return '✅ Foto del ticket subida correctamente';
      case 'Foto Odómetro':
        return '✅ Foto del odómetro subida correctamente';
      default:
        return '✅ Imagen subida correctamente';
    }
  }

  void _handleApiError(int statusCode, BuildContext context) {
    String errorMessage;
    switch (statusCode) {
      case 400:
        errorMessage = 'Error: La imagen no es válida';
        break;
      case 403:
        errorMessage = 'Error: Acceso denegado a ImgBB';
        break;
      case 429:
        errorMessage = 'Error: Demasiadas solicitudes. Intente más tarde';
        break;
      case 500:
        errorMessage = 'Error: Problema con el servidor de ImgBB';
        break;
      default:
        errorMessage = 'Error al subir la imagen (Código $statusCode)';
    }

    if (mounted) {
      _mostrarErrorDialog(context, errorMessage);
    }
  }

  void _handleUploadError(dynamic error, BuildContext context) {
    if (error is http.ClientException) {
      _mostrarErrorDialog(
          context, 'Error de conexión: Verifique su acceso a internet');
    } else if (error is TimeoutException) {
      _mostrarErrorDialog(
          context, 'Tiempo de espera agotado: La conexión está lenta');
    } else {
      _mostrarErrorDialog(context, 'Error inesperado: ${error.toString()}');
    }
  }

  void _mostrarErrorDialog(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 10),
              Text('Error al subir imagen'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(mensaje),
              SizedBox(height: 20),
              Text('Por favor, intente nuevamente.'),
              SizedBox(height: 10),
              Text('Si el problema persiste, verifique:'),
              SizedBox(height: 5),
              Text('- Su conexión a internet', style: TextStyle(fontSize: 14)),
              Text('- El tamaño de la imagen (máx. 10MB)',
                  style: TextStyle(fontSize: 14)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Entendido', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Aquí podrías agregar lógica para reintentar
              },
              child: Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showImagePreviewDialog(
      String imageData, Function(String) onImageSelected, String imageType) {
    setState(() {
      _currentImageData = imageData;
      _currentImageType = imageType;
    });
    final BuildContext dialogContext = context;
    Completer<void>? uploadCompleter;

    showDialog(
      context: dialogContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Vista previa de la imagen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 200,
                child: Image.network(imageData),
              ),
              SizedBox(height: 10),
              Text('¿Esta imagen es correcta?', style: TextStyle(fontSize: 14)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                uploadCompleter
                    ?.complete(); // Cancelar cualquier subida en curso
                Navigator.of(context).pop();
              },
              child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                uploadCompleter = Completer();

                try {
                  await _uploadImageToImgBB(imageData, (imageUrl) {
                    if (mounted) {
                      onImageSelected(imageUrl);
                    }
                  }, imageType);
                } finally {
                  uploadCompleter?.complete();
                }
              },
              child: Text('Subir imagen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _calcularDiferenciaKilometros() async {
    if (_odometroController.text.isNotEmpty &&
        _litrosController.text.isNotEmpty) {
      final placa = _placasController.text;

      if (placa.isEmpty) {
        setState(() {
          _diferenciaKilometros = '0 km';
          _rendimiento =
              'No es posible calcular el rendimiento sin una placa válida.';
        });
        return;
      }

      final ultimoRegistro = await _obtenerUltimoRegistro(placa);

      if (ultimoRegistro == null) {
        setState(() {
          _diferenciaKilometros = '0 km';
          _rendimiento =
              'No es posible calcular el rendimiento sin una carga anterior.';
        });
        return;
      }

      try {
        int odometroActual = int.parse(_odometroController.text);
        int odometroUltimo = ultimoRegistro['Odometro'] ?? 0;
        double litrosUltimo = ultimoRegistro['Litros'] ?? 0;

        if (odometroActual > odometroUltimo) {
          int diferencia = odometroActual - odometroUltimo;
          double rendimiento = diferencia / litrosUltimo;

          setState(() {
            _diferenciaKilometros = '$diferencia km';
            _rendimiento =
                'Rendimiento: ${rendimiento.toStringAsFixed(2)} km/L';
          });
        } else {
          setState(() {
            _diferenciaKilometros =
                'El odómetro actual debe ser mayor al último registrado';
            _rendimiento = 'No es posible calcular el rendimiento.';
          });
        }
      } catch (e) {
        setState(() {
          _diferenciaKilometros = 'Error en el cálculo';
          _rendimiento = 'No es posible calcular el rendimiento.';
        });
      }
    } else {
      setState(() {
        _diferenciaKilometros = '';
        _rendimiento = '';
      });
    }
  }

  void _validateImporte(String value) {
    setState(() {
      _isImporteValid =
          value.isNotEmpty && RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value);
      if (_isImporteValid && _isLitrosValid) {
        _calcularPrecioPorLitro();
      }
    });
  }

  void _validateLitros(String value) {
    bool isValid = value.isNotEmpty && RegExp(r'^\d+\.\d{3}$').hasMatch(value);

    setState(() {
      _isLitrosValid = isValid;
    });

    if (_isImporteValid && _isLitrosValid) {
      _calcularPrecioPorLitro();
    }
  }

  void _mostrarErrorDecimalesLitros(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Formato incorrecto'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  void _calcularPrecioPorLitro() {
    if (_importeController.text.isNotEmpty &&
        _litrosController.text.isNotEmpty) {
      double importe = double.parse(_importeController.text);
      double litros = double.parse(_litrosController.text);
      double precioPorLitro = importe / litros;
      setState(() {
        _precioPorLitro = precioPorLitro.toStringAsFixed(2);
        // Validar si el precio por litro es mayor a $20
        if (precioPorLitro > 20) {
          _isImporteValid = true;
          _isLitrosValid = true;
        } else {
          _isImporteValid = false;
          _isLitrosValid = false;
        }
      });
    } else {
      setState(() {
        _precioPorLitro = '';
      });
    }
  }

  void _showVehicleSelectionDialogWidget(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Seleccione el tipo de vehículo',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildVehicleOption(
                  context,
                  icon: Icons.directions_car,
                  label: 'Camioneta/Auto',
                  value: 'Camioneta',
                ),
                SizedBox(height: 16),
                _buildVehicleOption(
                  context,
                  icon: Icons.electrical_services,
                  label: 'Generador Eléctrico',
                  value: 'Generador',
                ),
                SizedBox(height: 16),
                _buildVehicleOption(
                  context,
                  icon: Icons.air,
                  label: 'Compresora',
                  value: 'Compresora',
                ),
                SizedBox(height: 16),
                _buildVehicleOption(
                  context,
                  icon: Icons.build,
                  label: 'Grúa',
                  value: 'Grua',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;

    // Mostrar diálogo después de que el widget se haya construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_showVehicleSelectionDialog && mounted) {
        _showVehicleSelectionDialogWidget(context);
        setState(() {
          _showVehicleSelectionDialog = false;
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Reporte de Carga de Combustible'),
        backgroundColor: Color(0xFFC0261F),
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Campos comunes para todos los tipos de vehículos
                      _buildDropdownOperador(
                        label: 'Nombre del Operador',
                        description: 'Seleccione el nombre del operador.',
                        isSmallScreen: isSmallScreen,
                      ),
                      _buildDropdownGasolinera(
                        label: 'Nombre de la Gasolinera',
                        description:
                            'Seleccione la gasolinera donde se realizó la carga.',
                        isSmallScreen: isSmallScreen,
                      ),
                      _buildReadOnlyTextField(
                        label: 'Fecha',
                        initialValue: _fechaHoy,
                        description: 'Fecha de hoy (automática).',
                        isSmallScreen: isSmallScreen,
                        showCheckIcon: true,
                      ),
                      _buildReadOnlyTextField(
                        label: 'Hora',
                        initialValue: _horaActual,
                        description: 'Hora actual (automática).',
                        isSmallScreen: isSmallScreen,
                        showCheckIcon: true,
                      ),
                      _buildDropdownContrato(
                        label: 'Contrato',
                        description: 'Seleccione el contrato correspondiente.',
                        isSmallScreen: isSmallScreen,
                      ),
                      _buildTextField(
                        controller: _importeController,
                        label: 'Importe Total (\$)',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el importe total';
                          } else if (!RegExp(r'^\d+(\.\d{1,2})?$')
                              .hasMatch(value)) {
                            return 'Formato incorrecto. Use hasta 2 decimales';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _validateImporte(value);
                          _calcularPrecioPorLitro();
                        },
                        isValid: _isImporteValid,
                        focusNode: _importeFocusNode,
                        description:
                            'Ingrese el importe total del combustible cargado.',
                        isSmallScreen: isSmallScreen,
                      ),
                      _buildTextField(
                        controller: _litrosController,
                        label: 'Litros Cargados',
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese la cantidad de litros cargados';
                          } else if (!RegExp(r'^\d+\.\d{3}$').hasMatch(value)) {
                            return 'Formato incorrecto. Use punto y exactamente 3 decimales';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _validateLitros(value);
                          _calcularPrecioPorLitro();
                        },
                        isValid: _isLitrosValid,
                        focusNode: _litrosFocusNode,
                        description:
                            'Ingrese la cantidad de litros de combustible cargados (ejemplo: 45.678).',
                        isSmallScreen: isSmallScreen,
                      ),
                      if (_precioPorLitro.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(
                              bottom: isSmallScreen ? 12.0 : 16.0),
                          child: Text(
                            'Precio por litro: \$$_precioPorLitro',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      _buildDropdownTipoGasolina(
                        label: 'Tipo de Gasolina',
                        description: 'Seleccione el tipo de gasolina cargada.',
                        isSmallScreen: isSmallScreen,
                      ),
                      _buildTextField(
                        controller: _folioTicketController,
                        label: 'Folio del Ticket',
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el folio del ticket';
                          }
                          return null;
                        },
                        onChanged: _validateFolioTicket,
                        isValid: _isFolioTicketValid,
                        focusNode: _folioTicketFocusNode,
                        description:
                            'Ingrese el folio del ticket de la compra de combustible.',
                        isSmallScreen: isSmallScreen,
                      ),
                      _buildResponsiveCameraButton(
                        'Tomar Foto del Ticket',
                        'Tome una foto del ticket de la compra de combustible.',
                        onPressed: () {
                          _openCameraOrFilePicker((imageData) {
                            _showImagePreviewDialog(imageData, (imageUrl) {
                              setState(() {
                                _fotoTicketUrl = imageUrl;
                              });
                            }, 'Foto Ticket');
                          });
                        },
                        isUploaded: _fotoTicketUrl != null,
                        imageUrl: _fotoTicketUrl,
                        isSmallScreen: isSmallScreen,
                        exampleImagePath: 'assets/example_images/foto.jpg',
                      ),
                      _buildResponsiveCameraButton(
                        'Tomar Foto de la Unidad',
                        'Tome una foto de la unidad/equipo.',
                        onPressed: () {
                          _openCameraOrFilePicker((imageData) {
                            _showImagePreviewDialog(imageData, (imageUrl) {
                              setState(() {
                                _fotoUnidadUrl = imageUrl;
                              });
                            }, 'Foto Unidad');
                          });
                        },
                        isUploaded: _fotoUnidadUrl != null,
                        imageUrl: _fotoUnidadUrl,
                        isSmallScreen: isSmallScreen,
                        exampleImagePath: 'assets/example_images/unidad.jpg',
                      ),

                      // Campos específicos para camioneta/auto
                      if (_tipoVehiculo == 'Camioneta') ...[
                        _buildPlacasField(
                          isSmallScreen: isSmallScreen,
                        ),
                        _buildTextField(
                          controller: _odometroController,
                          label: 'Odómetro',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese el número del odómetro';
                            } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                              return 'El odómetro debe ser un número entero';
                            }
                            return null;
                          },
                          onChanged: _validateOdometro,
                          isValid: _isOdometroValid,
                          focusNode: _odometroFocusNode,
                          description:
                              'Ingrese el número del odómetro del vehículo.',
                          isSmallScreen: isSmallScreen,
                        ),
                        _buildTextField(
                          controller: _odometroUltimoController,
                          label: 'Odómetro Última Carga',
                          keyboardType: TextInputType.number,
                          description:
                              'Último odómetro registrado para la placa seleccionada.',
                          isSmallScreen: isSmallScreen,
                          enabled: false,
                        ),
                        if (_diferenciaKilometros.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: isSmallScreen ? 12.0 : 16.0),
                            child: Text(
                              'Kilómetros recorridos: $_diferenciaKilometros',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _diferenciaKilometros
                                        .contains('debe ser mayor')
                                    ? Colors.red
                                    : Colors.black,
                              ),
                            ),
                          ),
                        if (_rendimiento.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: isSmallScreen ? 12.0 : 16.0),
                            child: Text(
                              _rendimiento,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _rendimiento.contains('No es posible')
                                    ? Colors.red
                                    : Colors.black,
                              ),
                            ),
                          ),
                        _buildResponsiveCameraButton(
                          'Tomar Foto de las placas',
                          'Tome una foto de las placas del vehículo.',
                          onPressed: () {
                            _openCameraOrFilePicker((imageData) {
                              _showImagePreviewDialog(imageData, (imageUrl) {
                                setState(() {
                                  _fotoPlacasUrl = imageUrl;
                                });
                              }, 'Foto Placas');
                            });
                          },
                          isUploaded: _fotoPlacasUrl != null,
                          imageUrl: _fotoPlacasUrl,
                          isSmallScreen: isSmallScreen,
                          exampleImagePath: 'assets/example_images/placa.jpeg',
                        ),
                        _buildResponsiveCameraButton(
                          'Tomar Foto del Odómetro',
                          'Tome una foto del odómetro del vehículo.',
                          onPressed: () {
                            _openCameraOrFilePicker((imageData) {
                              _showImagePreviewDialog(imageData, (imageUrl) {
                                setState(() {
                                  _fotoOdometroUrl = imageUrl;
                                });
                              }, 'Foto Odómetro');
                            });
                          },
                          isUploaded: _fotoOdometroUrl != null,
                          imageUrl: _fotoOdometroUrl,
                          isSmallScreen: isSmallScreen,
                          exampleImagePath:
                              'assets/example_images/odometro.jpg',
                        ),
                      ],

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: ElevatedButton(
                          onPressed: _enviarFormulario,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 5,
                            backgroundColor: Color(0xFFC0261F),
                          ),
                          child: Text('Enviar',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _tipoVehiculo = value;
          _showVehicleSelectionDialog = false;

          // Limpiar campos específicos cuando no son para Camioneta
          if (value != 'Camioneta') {
            _placasController.clear();
            _odometroController.clear();
            _odometroUltimoController.clear();
            _fotoPlacasUrl = null;
            _fotoOdometroUrl = null;
            _diferenciaKilometros = '';
            _rendimiento = '';
          }
        });
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Se ha seleccionado: $label'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Color(0xFFC0261F)),
            SizedBox(width: 16),
            Text(label, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
    String? description,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    bool isValid = false,
    FocusNode? focusNode,
    required bool isSmallScreen,
    bool enabled = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Solo mostramos el ícono de verificación para el campo específico que corresponde
                  if (isValid &&
                      ((label == 'Odómetro' &&
                              focusNode == _odometroFocusNode) ||
                          (label == 'Importe Total (\$)' &&
                              focusNode == _importeFocusNode) ||
                          (label == 'Litros Cargados' &&
                              focusNode == _litrosFocusNode) ||
                          (label == 'Folio del Ticket' &&
                              focusNode == _folioTicketFocusNode)))
                    Icon(Icons.check_circle, color: Colors.green),
                  IconButton(
                    icon: Icon(Icons.help_outline, color: Colors.grey),
                    onPressed: () => _mostrarDescripcion(
                        description ?? 'No hay descripción disponible.'),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    iconSize: isSmallScreen ? 20 : 24,
                  ),
                ],
              ),
            ),
            keyboardType: keyboardType,
            onChanged: onChanged,
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildPlacasField({
    required bool isSmallScreen,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputDecorator(
            decoration: InputDecoration(
              labelText: 'Placas de la Unidad',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isPlacasValid)
                    Icon(Icons.check_circle,
                        color: Colors.green), // Ícono verde
                  IconButton(
                    icon: Icon(Icons.help_outline, color: Colors.grey),
                    onPressed: () => _mostrarDescripcion(
                        'Seleccione o ingrese las placas de la unidad. Si no encuentras tu placa anotala.'),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    iconSize: isSmallScreen ? 20 : 24,
                  ),
                ],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _placasController.text.isNotEmpty &&
                              _placasPredefinidas
                                  .contains(_placasController.text)
                          ? _placasController.text
                          : null,
                      onChanged: (String? newValue) {
                        _onPlacasChanged(
                            newValue ?? ''); // Actualizar placas y odómetro
                        _placasController.text =
                            newValue ?? ''; // Actualizar el controlador
                      },
                      items: _placasPredefinidas
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      hint: Text('Seleccione una placa'),
                      isExpanded: true,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _placasController,
                    decoration: InputDecoration(
                      hintText: 'Si no encuentra su placa, ingrese aquí',
                      border: InputBorder.none,
                    ),
                    onChanged: _onPlacasChanged, // Actualizar placas y odómetro
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese las placas de la unidad';
                      } else if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                        return 'Las placas solo deben contener letras y números';
                      } else if (value.length > 7) {
                        // Máximo 7 caracteres
                        return 'Las placas no pueden tener más de 7 caracteres';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyTextField({
    String? label,
    String? initialValue,
    String? description,
    required bool isSmallScreen,
    bool showCheckIcon =
        false, // Parámetro opcional para mostrar el ícono verde
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showCheckIcon)
                Icon(Icons.check_circle, color: Colors.green), // Ícono verde
              IconButton(
                icon: Icon(Icons.help_outline, color: Colors.grey),
                onPressed: () => _mostrarDescripcion(
                    description ?? 'No hay descripción disponible.'),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                iconSize: isSmallScreen ? 20 : 24,
              ),
            ],
          ),
        ),
        initialValue: initialValue,
        enabled: false, // Campo de solo lectura
      ),
    );
  }

  Widget _buildDropdownOperador({
    String? label,
    String? description,
    required bool isSmallScreen,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isOperadorValid)
                    Icon(Icons.check_circle, color: Colors.green),
                  IconButton(
                    icon: Icon(Icons.help_outline, color: Colors.grey),
                    onPressed: () => _mostrarDescripcion(
                        description ?? 'No hay descripción disponible.'),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    iconSize: isSmallScreen ? 20 : 24,
                  ),
                ],
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _operadorSeleccionado,
                onChanged: (String? newValue) {
                  setState(() {
                    _operadorSeleccionado = newValue;
                    _validateOperador(newValue);
                  });
                },
                items:
                    _operadores.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownGasolinera({
    String? label,
    String? description,
    required bool isSmallScreen,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isGasolineraValid)
                    Icon(Icons.check_circle, color: Colors.green),
                  IconButton(
                    icon: Icon(Icons.help_outline, color: Colors.grey),
                    onPressed: () => _mostrarDescripcion(
                        description ?? 'No hay descripción disponible.'),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    iconSize: isSmallScreen ? 20 : 24,
                  ),
                ],
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _gasolineraController.text.isNotEmpty
                    ? _gasolineraController.text
                    : null,
                onChanged: (String? newValue) {
                  setState(() {
                    _gasolineraController.text = newValue!;
                    _validateGasolinera(newValue);
                  });
                },
                items:
                    _gasolineras.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTipoGasolina({
    String? label,
    String? description,
    required bool isSmallScreen,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isTipoGasolinaValid)
                    Icon(Icons.check_circle, color: Colors.green),
                  IconButton(
                    icon: Icon(Icons.help_outline, color: Colors.grey),
                    onPressed: () => _mostrarDescripcion(
                        description ?? 'No hay descripción disponible.'),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    iconSize: isSmallScreen ? 20 : 24,
                  ),
                ],
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _tipoGasolina,
                onChanged: (String? newValue) {
                  setState(() {
                    _tipoGasolina = newValue;
                    _validateTipoGasolina(newValue);
                  });
                },
                items: <String>['Magna', 'Premium', 'Diésel']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveCameraButton(
    String label,
    String description, {
    required Function() onPressed,
    bool isUploaded = false,
    String? imageUrl,
    required bool isSmallScreen,
    required String
        exampleImagePath, // Nuevo parámetro para la imagen de ejemplo
  }) {
    // Acortar texto del botón en pantallas pequeñas
    String buttonText = isSmallScreen
        ? label
            .replaceAll('Tomar Foto de', 'Foto')
            .replaceAll('Tomar Foto del', 'Foto')
        : label;
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (isUploaded)
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () {
                      if (imageUrl != null) {
                        _showImagePreviewDialog(
                            imageUrl, (imageUrl) {}, 'Vista previa');
                      }
                    },
                    child: Icon(Icons.check_circle, color: Colors.green),
                  ),
                ),
              Expanded(
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 40,
                      vertical: isSmallScreen ? 12 : 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    backgroundColor: Color(0xFFC0261F),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                        color: Colors.white, fontSize: isSmallScreen ? 14 : 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.help_outline, color: Colors.grey),
                onPressed: () {
                  // Mostrar la imagen de ejemplo al hacer clic en el ícono de ayuda
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Ejemplo De Como $label'),
                        content: Image.asset(exampleImagePath),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cerrar'),
                          ),
                        ],
                      );
                    },
                  );
                },
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                iconSize: isSmallScreen ? 20 : 24,
              ),
            ],
          ),
          if (isUploaded && imageUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Imagen subida correctamente',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdownContrato({
    String? label,
    String? description,
    required bool isSmallScreen,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputDecorator(
            decoration: InputDecoration(
              labelText: label ?? 'Contrato',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isContratoValid)
                    Icon(Icons.check_circle, color: Colors.green),
                  IconButton(
                    icon: Icon(Icons.help_outline, color: Colors.grey),
                    onPressed: () => _mostrarDescripcion(description ??
                        'Seleccione el contrato correspondiente.'),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    iconSize: isSmallScreen ? 20 : 24,
                  ),
                ],
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _contratoSeleccionado,
                onChanged: (String? newValue) {
                  setState(() {
                    _contratoSeleccionado = newValue;
                    _validateContrato(newValue);
                  });
                },
                items: _contratos.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpinKitFadingCircle(
                color: Colors.blue,
                size: 50.0,
              ),
              SizedBox(height: 20),
              Text('Enviando Reporte'),
            ],
          ),
        );
      },
    );
  }

  Future<int?> _obtenerUltimoOdometro(String placa) async {
    final airtableApiToken =
        'patW8Q98FkL4zObhH.c46b48da5580a5cb1ecfea2b24a2cd56f4be18a30bcba7b2e7747684f39352ec';
    final airtableBaseId = 'appk2qomcs0VaYbCD';
    final airtableTableName = 'Gasolina';
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

        // Filtrar los registros por la placa seleccionada
        final registrosPlaca = records
            .where((record) => record['fields']['Placas'] == placa)
            .toList();

        if (registrosPlaca.isNotEmpty) {
          // Convertir las fechas a DateTime antes de ordenar
          registrosPlaca.sort((a, b) {
            DateTime fechaA = DateTime.parse(a['fields']['Fecha']);
            DateTime fechaB = DateTime.parse(b['fields']['Fecha']);
            return fechaB
                .compareTo(fechaA); // Ordenar de más reciente a más antiguo
          });

          // Obtener el último odómetro registrado
          final ultimoOdometro = registrosPlaca.first['fields']['Odometro'];
          return ultimoOdometro;
        }
      } else {
        throw Exception(
            'Error al obtener datos de Airtable: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }

    return null; // Si no se encuentra ningún registro
  }

  Future<Map<String, dynamic>?> _obtenerUltimoRegistro(String placa) async {
    final airtableApiToken =
        'patW8Q98FkL4zObhH.c46b48da5580a5cb1ecfea2b24a2cd56f4be18a30bcba7b2e7747684f39352ec';
    final airtableBaseId = 'appk2qomcs0VaYbCD';
    final airtableTableName = 'Gasolina';
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

        // Filtrar los registros por la placa seleccionada
        final registrosPlaca = records
            .where((record) => record['fields']['Placas'] == placa)
            .toList();

        if (registrosPlaca.isNotEmpty) {
          // Convertir las fechas a DateTime antes de ordenar
          registrosPlaca.sort((a, b) {
            DateTime fechaA = DateTime.parse(a['fields']['Fecha']);
            DateTime fechaB = DateTime.parse(b['fields']['Fecha']);
            return fechaB
                .compareTo(fechaA); // Ordenar de más reciente a más antiguo
          });

          // Obtener el último registro
          final ultimoRegistro = registrosPlaca.first['fields'];
          return ultimoRegistro;
        }
      } else {
        throw Exception(
            'Error al obtener datos de Airtable: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }

    return null; // Si no se encuentra ningún registro
  }

  Future<void> _enviarFormulario() async {
    if (_formKey.currentState!.validate() &&
        _isOperadorValid &&
        _isGasolineraValid &&
        _isTipoGasolinaValid &&
        _isImporteValid &&
        _isLitrosValid &&
        _isContratoValid &&
        _isFolioTicketValid) {
      // Mostrar el diálogo de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SpinKitFadingCircle(
                  color: Colors.blue,
                  size: 50.0,
                ),
                SizedBox(height: 20),
                Text('Enviando Reporte...'),
              ],
            ),
          );
        },
      );

      try {
        final airtableApiToken =
            'patW8Q98FkL4zObhH.c46b48da5580a5cb1ecfea2b24a2cd56f4be18a30bcba7b2e7747684f39352ec';
        final airtableBaseId = 'appk2qomcs0VaYbCD';
        final airtableTableName = 'Gasolina';
        final url =
            'https://api.airtable.com/v0/$airtableBaseId/$airtableTableName';

        // 1. Preparar los datos
        Map<String, dynamic> fields = {
          "Contrato": _contratoSeleccionado,
          "Nombre Operador": _operadorSeleccionado,
          "Nombre Gasolinera": _gasolineraController.text,
          "Gasolina": _tipoGasolina,
          "Fecha": DateFormat('yyyy-MM-dd').format(DateTime.now()),
          "Hora": _horaActual,
          "Folio Ticket": _folioTicketController.text,
          "Importe": double.parse(_importeController.text),
          "Litros": double.parse(_litrosController.text),
          "Precio Litros": double.parse(_precioPorLitro),
          "Tipo Vehiculo": _tipoVehiculo,
        };

        // Campos específicos por tipo de vehículo
        if (_tipoVehiculo == 'Camioneta') {
          fields.addAll({
            "Placas": _placasController.text,
            "Odometro": int.parse(_odometroController.text),
            "Diferencia Kilometros": _diferenciaKilometros.isNotEmpty
                ? int.parse(_diferenciaKilometros.replaceAll(' km', ''))
                : 0,
            "Rendimiento": _rendimiento.contains('Rendimiento')
                ? double.parse(_rendimiento
                    .replaceAll('Rendimiento: ', '')
                    .replaceAll(' km/L', ''))
                : null,
          });
        } else {
          fields.addAll({
            "Placas": "N/A",
            "Odometro": 0,
            "Diferencia Kilometros": 0,
            "Rendimiento": 0,
          });
        }

        // Agregar fotos
        _agregarFotosAFields(fields);

        // 2. Crear cuerpo de la petición
        final body = {
          "records": [
            {"fields": fields}
          ]
        };

        // 3. Log detallado antes de enviar
        _logDatosParaEnvio(fields, body);

        // 4. Enviar petición
        final response = await http
            .post(
              Uri.parse(url),
              headers: {
                'Authorization': 'Bearer $airtableApiToken',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(body),
            )
            .timeout(Duration(seconds: 30));

        // 5. Cerrar diálogo de carga
        Navigator.of(context).pop();

        if (response.statusCode == 200) {
          _mostrarExito();
          _limpiarFormulario();

          // Mostrar diálogo de opciones después del éxito
          await _mostrarOpcionesDespuesEnvio();
        } else {
          _manejarErrorRespuesta(response);
        }
      } on TimeoutException {
        Navigator.of(context).pop();
        _mostrarError('Tiempo de espera agotado. Intente nuevamente.');
      } catch (e, stackTrace) {
        Navigator.of(context).pop();
        _mostrarError('Error inesperado: ${e.toString()}');
        print('════════════════ ERROR ════════════════');
        print('Tipo de error: ${e.runtimeType}');
        print('Mensaje: ${e.toString()}');
        print('Stack trace: $stackTrace');
        print('════════════════════════════════════════');
      }
    } else {
      _mostrarError('Por favor complete todos los campos correctamente');
    }
  }

  Future<void> _mostrarOpcionesDespuesEnvio() async {
    final result = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reporte enviado con éxito'),
          content: Text('¿Qué deseas hacer ahora?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(1), // Nuevo reporte
              child: Text('Capturar otro reporte'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(2), // Menú principal
              child: Text('Regresar al menú'),
            ),
          ],
        );
      },
    );

    if (result == 1) {
      // Volver a mostrar el diálogo de selección de vehículo
      setState(() {
        _showVehicleSelectionDialog = true;
      });
    } else if (result == 2) {
      // Regresar al menú principal
      Navigator.of(context).pop();
    }
  }

  void _agregarFotosAFields(Map<String, dynamic> fields) {
    if (_fotoTicketUrl != null) {
      fields["Foto Ticket"] = [
        {"url": _fotoTicketUrl, "filename": "ticket.jpg"}
      ];
    }
    if (_fotoUnidadUrl != null) {
      fields["Foto Unidad"] = [
        {"url": _fotoUnidadUrl, "filename": "unidad.jpg"}
      ];
    }
    if (_tipoVehiculo == 'Camioneta') {
      if (_fotoPlacasUrl != null) {
        fields["Foto Placas"] = [
          {"url": _fotoPlacasUrl, "filename": "placas.jpg"}
        ];
      }
      if (_fotoOdometroUrl != null) {
        fields["Foto Odometro"] = [
          {"url": _fotoOdometroUrl, "filename": "odometro.jpg"}
        ];
      }
    }
  }

  void _logDatosParaEnvio(
      Map<String, dynamic> fields, Map<String, dynamic> body) {
    print('════════════════ DATOS A ENVIAR ════════════════');
    print('📋 Campos:');
    fields.forEach((key, value) {
      print('  • $key: ${value.toString()} (Tipo: ${value.runtimeType})');
    });

    print('\n🔠 JSON completo:');
    print(jsonEncode(body));
    print('════════════════════════════════════════════════');
  }

  void _manejarErrorRespuesta(http.Response response) {
    print('════════════════ ERROR RESPONSE ════════════════');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('════════════════════════════════════════════════');

    String mensajeError = 'Error al enviar el reporte (${response.statusCode})';

    try {
      final errorJson = jsonDecode(response.body);
      if (errorJson['error'] != null) {
        mensajeError += '\nTipo: ${errorJson['error']['type']}';
        mensajeError += '\nMensaje: ${errorJson['error']['message']}';
      }
    } catch (e) {
      print('Error al parsear respuesta de error: $e');
    }

    _mostrarError(mensajeError);
  }

  void _mostrarExito() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Reporte enviado correctamente'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _limpiarFormulario() {
    setState(() {
      // Limpiar controladores
      _operadorSeleccionado = null;
      _gasolineraController.text = 'GASOLINERA LOS TOROS';
      _importeController.clear();
      _litrosController.clear();
      _precioPorLitro = '';
      _tipoGasolina = null;
      _folioTicketController.clear();
      _placasController.clear();
      _odometroController.clear();
      _odometroUltimoController.clear();

      // Limpiar imágenes
      _fotoPlacasUrl = null;
      _fotoUnidadUrl = null;
      _fotoTicketUrl = null;
      _fotoOdometroUrl = null;

      // Limpiar cálculos
      _diferenciaKilometros = '';
      _rendimiento = '';

      // Restablecer validaciones
      _isOperadorValid = false;
      _isGasolineraValid = true;
      _isImporteValid = false;
      _isLitrosValid = false;
      _isTipoGasolinaValid = false;
      _isFolioTicketValid = false;
      _isPlacasValid = false;
      _isOdometroValid = false;
      _isContratoValid = false;

      // Mantener el tipo de vehículo para no tener que seleccionarlo de nuevo
      // _tipoVehiculo se mantiene
    });
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ $mensaje'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
  }
}
