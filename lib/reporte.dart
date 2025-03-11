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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _operadorController = TextEditingController();
  final TextEditingController _gasolineraController = TextEditingController();
  final TextEditingController _importeController = TextEditingController();
  final TextEditingController _litrosController = TextEditingController();
  final TextEditingController _placasController = TextEditingController();
  final TextEditingController _odometroController = TextEditingController();
  final TextEditingController _odometroUltimoController = TextEditingController();

  // FocusNodes para cada campo de texto
  final FocusNode _operadorFocusNode = FocusNode();
  final FocusNode _gasolineraFocusNode = FocusNode();
  final FocusNode _importeFocusNode = FocusNode();
  final FocusNode _litrosFocusNode = FocusNode();
  final FocusNode _placasFocusNode = FocusNode();
  final FocusNode _odometroFocusNode = FocusNode();
  final FocusNode _odometroUltimoFocusNode = FocusNode();

  String _fechaHoy = DateFormat('dd/MM/yyyy').format(DateTime.now());
  String _horaActual = DateFormat('HH:mm').format(DateTime.now());

  String? _fotoPlacasUrl;
  String? _fotoUnidadUrl;
  String? _fotoTicketUrl;
  String? _fotoOdometroUrl;

  // Estados de validación existentes
  bool _isImporteValid = false;
  bool _isLitrosValid = false;
  bool _isOdometroValid = false;
    // Variables de estado para validación
  bool _isOperadorValid = false;
  bool _isGasolineraValid = false;
  bool _isTipoGasolinaValid = false;
  bool _isPlacasValid = false; // Estado de validación para el campo de placas

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
  ];
    // Tipo de gasolina seleccionada
    String? _tipoGasolina;

  @override
  void initState() {
    super.initState();
    // Agregar listeners a los FocusNodes
    _operadorFocusNode.addListener(() => _onFocusChange(_operadorFocusNode, _validateOperador));
    _gasolineraFocusNode.addListener(() => _onFocusChange(_gasolineraFocusNode, _validateGasolinera));
    _importeFocusNode.addListener(() => _onFocusChange(_importeFocusNode, _validateImporte));
    _litrosFocusNode.addListener(() => _onFocusChange(_litrosFocusNode, _validateLitros));
    _placasFocusNode.addListener(() => _onFocusChange(_placasFocusNode, _validatePlacas));
    _odometroFocusNode.addListener(() => _onFocusChange(_odometroFocusNode, _validateOdometro));
    _gasolineraController.text = 'GASOLINERA LOS TOROS';
    _validateGasolinera('GASOLINERA LOS TOROS');
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
    if (focusNode == _odometroUltimoFocusNode) return _odometroUltimoController.text;
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
      _odometroUltimoController.text = ultimoOdometro?.toString() ?? 'No hay odómetro registrado';
    });
  }

  void _onPlacasChanged(String value) {
    _validatePlacas(value); // Validar el campo de placas
    _actualizarOdometroUltimo(value); // Actualizar el odómetro último
  }

  void _validateImporte(String value) {
    setState(() {
      _isImporteValid = value.isNotEmpty && RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value);
    });
  }

  void _validateLitros(String value) {
    setState(() {
      _isLitrosValid = value.isNotEmpty && RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value);
    });
  }
  
  void _validatePlacas(String value) {
    bool isValid = value.isNotEmpty && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value) && value.length <= 7;
    if (_isPlacasValid != isValid) {
      setState(() {
        _isPlacasValid = isValid;
      });
    }
  }

  void _validateOdometro(String value) {
    setState(() {
      _isOdometroValid = value.isNotEmpty && RegExp(r'^\d+$').hasMatch(value) && value.length <= 10;
    });
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

    if (userAgent.contains('iphone') || userAgent.contains('ipad') || userAgent.contains('android')) {
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

  Future<void> _uploadImageToImgBB(String imageData, Function(String) onSuccess, String imageType) async {
    final url = 'https://api.imgbb.com/1/upload';
    final apiKey = 'a49c594e3a3152ca5168f2ed879db980';

    String base64Image = imageData.split(',').last;

    var body = {
      'key': apiKey,
      'image': base64Image,
    };

    var response = await http.post(
      Uri.parse(url),
      body: body,
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      String imageUrl = jsonResponse['data']['url'];
      onSuccess(imageUrl);

      String message;
      switch (imageType) {
        case 'Foto Placas':
          message = 'La foto de las placas se ha subido correctamente.';
          break;
        case 'Foto Unidad':
          message = 'La foto de la unidad se ha subido correctamente.';
          break;
        case 'Foto Ticket':
          message = 'La foto del ticket se ha subido correctamente.';
          break;
        case 'Foto Odómetro':
          message = 'La foto del odómetro se ha subido correctamente.';
          break;
        default:
          message = 'La imagen se ha subido correctamente.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      throw Exception('Failed to upload image to Imgbb');
    }
  }

  void _showImagePreviewDialog(String imageData, Function(String) onImageSelected, String imageType) {
    final BuildContext dialogContext = context;

    showDialog(
      context: dialogContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Vista previa de la imagen'),
          content: Image.network(imageData),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                BuildContext? loadingDialogContext;

                showDialog(
                  context: dialogContext,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    loadingDialogContext = context;
                    return AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SpinKitFadingCircle(
                            color: Colors.blue,
                            size: 50.0,
                          ),
                          SizedBox(height: 20),
                          Text('Subiendo imagen...'),
                        ],
                      ),
                    );
                  },
                );

                try {
                  await _uploadImageToImgBB(imageData, (imageUrl) {
                    if (mounted && loadingDialogContext != null) {
                      Navigator.of(loadingDialogContext!).pop();
                      onImageSelected(imageUrl);
                    }
                  }, imageType);
                } catch (e) {
                  if (mounted && loadingDialogContext != null) {
                    Navigator.of(loadingDialogContext!).pop();
                    showDialog(
                      context: dialogContext,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Error'),
                          content: Text('Error al subir la imagen: $e'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
              child: Text('Subir'),
            ),
          ],
        );
      },
    );
  }

  void _calcularPrecioPorLitro() {
    if (_importeController.text.isNotEmpty && _litrosController.text.isNotEmpty) {
      double importe = double.parse(_importeController.text);
      double litros = double.parse(_litrosController.text);
      double precioPorLitro = importe / litros;
      setState(() {
        _precioPorLitro = precioPorLitro.toStringAsFixed(2);
      });
    } else {
      setState(() {
        _precioPorLitro = '';
      });
    }
  }
    
  @override
  Widget build(BuildContext context) {
    // Obtenemos el tamaño de la pantalla para adaptaciones
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;

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
            // Cerrar el teclado al tocar fuera de un campo de texto
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildDropdownOperador(
                    label: 'Nombre del Operador',
                    description: 'Seleccione el nombre del operador.',
                    isSmallScreen: isSmallScreen,
                  ),
                  _buildDropdownGasolinera(
                    label: 'Nombre de la Gasolinera',
                    description: 'Seleccione la gasolinera donde se realizó la carga.',
                    isSmallScreen: isSmallScreen,
                  ),
                  _buildReadOnlyTextField(
                    label: 'Fecha',
                    initialValue: _fechaHoy,
                    description: 'Fecha de hoy (automática).',
                    isSmallScreen: isSmallScreen,
                    showCheckIcon: true, // Mostrar el ícono verde
                  ),
                  _buildReadOnlyTextField(
                    label: 'Hora',
                    initialValue: _horaActual,
                    description: 'Hora actual (automática).',
                    isSmallScreen: isSmallScreen,
                    showCheckIcon: true, // Mostrar el ícono verde
                  ),
                  // Reemplazar el campo de placas con el nuevo método
                  _buildPlacasField(
                    isSmallScreen: isSmallScreen,
                  ),
                  _buildResponsiveCameraButton(
                    'Tomar Foto de las placas',
                    'Tome una foto de las placas del vehículo. (Foto legible)',
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
                  ),
                  _buildTextField(
                    controller: _importeController,
                    label: 'Importe Total (\$)',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el importe total';
                      } else if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) {
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
                    description: 'Ingrese el importe total del combustible cargado. (Tal cual se muestra en el ticket)',
                    isSmallScreen: isSmallScreen,
                  ),
                  _buildTextField(
                    controller: _litrosController,
                    label: 'Litros Cargados',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese la cantidad de litros cargados';
                      } else if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) {
                        return 'Formato incorrecto. Use hasta 2 decimales';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _validateLitros(value);
                      _calcularPrecioPorLitro();
                    },
                    isValid: _isLitrosValid,
                    focusNode: _litrosFocusNode,
                    description: 'Ingrese la cantidad de litros de combustible cargados. (Tal cual se muestra en el ticket)',
                    isSmallScreen: isSmallScreen,
                  ),
                  if (_precioPorLitro.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
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
                    description: 'Ingrese el número del odómetro del vehículo.',
                    isSmallScreen: isSmallScreen,
                  ),
                  // Campo de solo lectura para el último odómetro
                  _buildTextField(
                    controller: _odometroUltimoController,
                    label: 'Odómetro Última Carga',
                    keyboardType: TextInputType.number,
                    description: 'Último odómetro registrado para la placa seleccionada.',
                    isSmallScreen: isSmallScreen,
                    enabled: false, // Deshabilitar la edición manual
                  ),
                  _buildResponsiveCameraButton(
                    'Tomar Foto del Odómetro',
                    'Tome una foto del odómetro del vehículo. (Foto legible)',
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
                  ),
                  _buildResponsiveCameraButton(
                    'Tomar Foto del Ticket',
                    'Tome una foto del ticket de la compra de combustible. (Foto legible)',
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
                  ),
                  _buildResponsiveCameraButton(
                    'Tomar Foto de la Unidad',
                    'Tome una foto de la unidad en la gasolinera. (Foto donde se vean las placas)',
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
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: ElevatedButton(
                      onPressed: _enviarFormulario,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 5,
                        backgroundColor: Color(0xFFC0261F),
                      ),
                      child: Text('Enviar',
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isValid) Icon(Icons.check_circle, color: Colors.green),
                  IconButton(
                    icon: Icon(Icons.help_outline, color: Colors.grey),
                    onPressed: () => _mostrarDescripcion(description ?? 'No hay descripción disponible.'),
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isPlacasValid) Icon(Icons.check_circle, color: Colors.green), // Ícono verde
                  IconButton(
                    icon: Icon(Icons.help_outline, color: Colors.grey),
                    onPressed: () => _mostrarDescripcion('Seleccione o ingrese las placas de la unidad. Si no encuentras tu placa anotala.'),
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
                      value: _placasController.text.isNotEmpty && _placasPredefinidas.contains(_placasController.text)
                          ? _placasController.text
                          : null,
                      onChanged: (String? newValue) {
                        _onPlacasChanged(newValue ?? ''); // Actualizar placas y odómetro
                        _placasController.text = newValue ?? ''; // Actualizar el controlador
                      },
                      items: _placasPredefinidas.map<DropdownMenuItem<String>>((String value) {
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
                      } else if (value.length > 7) { // Máximo 7 caracteres
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
    bool showCheckIcon = false, // Parámetro opcional para mostrar el ícono verde
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showCheckIcon) Icon(Icons.check_circle, color: Colors.green), // Ícono verde
              IconButton(
                icon: Icon(Icons.help_outline, color: Colors.grey),
                onPressed: () => _mostrarDescripcion(description ?? 'No hay descripción disponible.'),
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isOperadorValid) Icon(Icons.check_circle, color: Colors.green),
                  IconButton(
                    icon: Icon(Icons.help_outline, color: Colors.grey),
                    onPressed: () => _mostrarDescripcion(description ?? 'No hay descripción disponible.'),
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
                items: _operadores.map<DropdownMenuItem<String>>((String value) {
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isGasolineraValid) Icon(Icons.check_circle, color: Colors.green),
                  IconButton(
                    icon: Icon(Icons.help_outline, color: Colors.grey),
                    onPressed: () => _mostrarDescripcion(description ?? 'No hay descripción disponible.'),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    iconSize: isSmallScreen ? 20 : 24,
                  ),
                ],
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _gasolineraController.text.isNotEmpty ? _gasolineraController.text : null,
                onChanged: (String? newValue) {
                  setState(() {
                    _gasolineraController.text = newValue!;
                    _validateGasolinera(newValue);
                  });
                },
                items: _gasolineras.map<DropdownMenuItem<String>>((String value) {
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isTipoGasolinaValid) Icon(Icons.check_circle, color: Colors.green),
                  IconButton(
                    icon: Icon(Icons.help_outline, color: Colors.grey),
                    onPressed: () => _mostrarDescripcion(description ?? 'No hay descripción disponible.'),
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
    String description,
    {required Function() onPressed,
    bool isUploaded = false,
    String? imageUrl,
    required bool isSmallScreen,
  }) {
    // Acortar texto del botón en pantallas pequeñas
    String buttonText = isSmallScreen
        ? label.replaceAll('Tomar Foto de', 'Foto').replaceAll('Tomar Foto del', 'Foto')
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
                        _showImagePreviewDialog(imageUrl, (imageUrl) {}, 'Vista previa');
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
                    style: TextStyle(color: Colors.white, fontSize: isSmallScreen ? 14 : 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.help_outline, color: Colors.grey),
                onPressed: () => _mostrarDescripcion(description),
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
    final airtableApiToken = 'patW8Q98FkL4zObhH.c46b48da5580a5cb1ecfea2b24a2cd56f4be18a30bcba7b2e7747684f39352ec';
    final airtableBaseId = 'appk2qomcs0VaYbCD';
    final airtableTableName = 'Gasolina';
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

        // Filtrar los registros por la placa seleccionada
        final registrosPlaca = records.where((record) =>
            record['fields']['Placas'] == placa).toList();

        if (registrosPlaca.isNotEmpty) {
          // Convertir las fechas a DateTime antes de ordenar
          registrosPlaca.sort((a, b) {
            DateTime fechaA = DateTime.parse(a['fields']['Fecha']);
            DateTime fechaB = DateTime.parse(b['fields']['Fecha']);
            return fechaB.compareTo(fechaA); // Ordenar de más reciente a más antiguo
          });

          // Obtener el último odómetro registrado
          final ultimoOdometro = registrosPlaca.first['fields']['Odometro'];
          return ultimoOdometro;
        }
      } else {
        throw Exception('Error al obtener datos de Airtable: ${response.statusCode}');
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
        _isOdometroValid &&
        _fotoPlacasUrl != null &&
        _fotoUnidadUrl != null &&
        _fotoTicketUrl != null &&
        _fotoOdometroUrl != null) {

      // Mostrar el diálogo de carga
      showLoadingDialog(context);

      try {
        final airtableApiToken = 'patW8Q98FkL4zObhH.c46b48da5580a5cb1ecfea2b24a2cd56f4be18a30bcba7b2e7747684f39352ec';
        final airtableBaseId = 'appk2qomcs0VaYbCD';
        final airtableTableName = 'Gasolina';
        final url = 'https://api.airtable.com/v0/$airtableBaseId/$airtableTableName';

        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $airtableApiToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "fields": {
              "Nombre Operador": _operadorSeleccionado,
              "Nombre Gasolinera": _gasolineraController.text,
              "Gasolina": _tipoGasolina,
              "Fecha": _fechaHoy,
              "Hora": _horaActual,
              "Placas": _placasController.text,
              "Importe": double.parse(_importeController.text),
              "Litros": double.parse(_litrosController.text),
              "Odometro": int.parse(_odometroController.text),
              "Foto Placas": [
                {
                  "url": _fotoPlacasUrl,
                }
              ],
              "Foto Unidad": [
                {
                  "url": _fotoUnidadUrl,
                }
              ],
              "Foto Ticket": [
                {
                  "url": _fotoTicketUrl,
                }
              ],
              "Foto Odometro": [
                {
                  "url": _fotoOdometroUrl,
                }
              ],
            },
          }),
        );

        // Cerrar el diálogo de carga
        Navigator.of(context).pop();

        if (response.statusCode == 200) {
          // Mostrar ventana emergente de éxito
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Éxito'),
                content: Text('La información se ha subido correctamente.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar el diálogo
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );

          // Cerrar el teclado si está abierto
          FocusScope.of(context).unfocus();

          // Limpiar el formulario después de enviar, excepto los campos por defecto
          _formKey.currentState!.reset(); // Limpiar todos los campos
          setState(() {
            // Restablecer los campos que no son por defecto
            _operadorSeleccionado = null;
            _gasolineraController.text = 'GASOLINERA LOS TOROS'; // Valor por defecto
            _tipoGasolina = null;
            _placasController.clear();
            _importeController.clear();
            _litrosController.clear();
            _odometroController.clear();
            _fotoPlacasUrl = null;
            _fotoUnidadUrl = null;
            _fotoTicketUrl = null;
            _fotoOdometroUrl = null;
            _precioPorLitro = '';
          });
        } else {
          // Error al enviar los datos
          print('Error al enviar el reporte. Código de estado: ${response.statusCode}');
          print('Respuesta del servidor: ${response.body}'); // Imprime la respuesta del servidor

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al enviar el reporte: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Cerrar el diálogo de carga
        Navigator.of(context).pop();

        // Error de conexión
        print('Error de conexión: $e'); // Imprime el error en la consola

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Mostrar un mensaje de error si no todos los campos están llenos
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Por favor, complete todos los campos correctamente.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

}