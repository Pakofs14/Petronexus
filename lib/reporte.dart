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
  bool _isOperadorValid = false;
  bool _isGasolineraValid = false;
  bool _isImporteValid = false;
  bool _isLitrosValid = false;
  bool _isPlacasValid = false;
  bool _isOdometroValid = false;
  bool _isOdometroUltimoValid = false;

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

  //Lista de Operadores
  final List<String> _operadores = [
    'ABEL MORALES HERNANDEZ',
    'ABIMAEL FUENTES TENORIO',
    'ABRAHAM G. FERNANDEZ ZAVALETA',
    'ADRIAN SANTOYO CONTRERAS',
    'ADRIAN TRUJILLO REYES',
    'ADRIANA DEL CARMEN DE LA O RUIZ',
    'AIMAEL FUENTES TENORIO',
    'AIRA E. HERRERA S.',
    'ALBERTO GUADALUPE JIMENEZ RAMÍREZ',
    'ALBERTO PEREZ HERNANDEZ',
    'ALBERTO PRIANTHI GARCIA',
    'ALEJANDRO BERMUDEZ',
    'ALEJANDRO SANCHEZ BERNABÉ',
    'ALFREDO',
    'ALFREDO MARQUEZ CARDENAS',
    'ALVARO VAZQUEZ LUNA',
    'AMARELO ANTONIO AMARELO HERRERA',
    'ANDRES IVAN PEREZ HERNANDEZ',
    'ANGEL ALBERTO SANCHEZ HIDALGO',
    'ANGEL NOVELO',
    'ANGEL SILVERIO ARTEAGA',
    'ANGEL URIEL HERNANDEZ DE LA CRUZ',
    'ANIBAL IVAN HERNANDEZ',
    'ANTONIO DE JESUS JIMENEZ RAMIREZ',
    'ANTONIO DEMETRIO GARCIA',
    'ARMANDO ROJAS SALAS',
    'ARMANDO ROJAS SANCHEZ',
    'ARMANDO ROJAS SILVERIO',
    'ARVIN G. VELAZQUEZ ROMERO',
    'BELISARIO ESCOBAR SANCHEZ',
    'BENJAMIN ZUBIRI MORALES',
    'BLADIMIR SANDOVAL HERNANDEZ',
    'BLAS HERNANDEZ MENDEZ',
    'BRANDON RENDON',
    'CAMIONETA DE RESERVA',
    'CARLOS ALBERTO SANCHEZ HERNANDEZ',
    'CARLOS ALFREDO VAZQUEZ PEREZ',
    'CARLOS DE YBARRA',
    'CARLOS SANCHEZ HERNANDEZ',
    'CARLOS TUA',
    'CARLOS TUA Y RICARDO SANCHEZ',
    'CESAR ANTONIO AMARELO HERRERA',
    'CESAR IVAN AMARELO HERRERA',
    'CHRISTIAN GERARDO TORRES VILLACENCIO',
    'COMIONETA COMODIN',
    'CONSTANTINO MOSQUEDA BOCANEGRA',
    'CORNELIO GONZALEZ',
    'CRISTIAN VAZQUEZ',
    'CRISTIAN ADRIAN',
    'CRISTIAN FRANCISCO HERNANDEZ MUÑOZ',
    'CUSTODIO JOSE ANTONIO',
    'DAMIAN HERNANDEZ RODRIGUEZ',
    'DANIEL MATEO PIMIENTA PEREZ',
    'DANIELA AZUARA TAMAYO',
    'DANILO GIOVANNI CÉSPEDES ZEPETA',
    'DAVID JOSUE MARQUEZ SANCHEZ',
    'DORISLEIDY HERNANDEZ HERNANDEZ',
    'DULIO VAZQUEZ',
    'DULIO VAZQUEZY RICARDO SANCHEZ',
    'EDGAR SANTIAGO PEREZ',
    'EFRAIN REYES MONTERO',
    'ELIAS SANTES BAUTISTA',
    'ELMER VALENTIN GASPAR GUZMAN',
    'ENRIQUE ALEXANDER OLGUIN POLANCO',
    'ENRIQUE ARVIN OLGUIN',
    'ERICK PEREZ CASTAN',
    'ERIK GONZALEZ VAZQUEZ',
    'EULOGIO VILLANUEVA SALAZAR',
    'EVER SANCHEZ LEMUZ',
    'EYMAR RODRIGUEZ CANO',
    'EYMER VALENTIN GASPAR GUZMAN',
    'FELIPE DE JESUS MONTES CANALES',
    'FERNANDO BELLO HERNANDEZ',
    'FERNANDO GUERRERO ORTIZ',
    'FERNANDO HERNANDEZ BARANDICA',
    'FIDENCIO MONTIEL LOPEZ',
    'FILIBERTO CORDERO MARTINEZ',
    'FRANCISCO IVAN ZAMORA',
    'FRANCISCO JAVIER CORTES GOMEZ',
    'FRANCISCO JAVIER HERNANDEZ SUAREZ',
    'FRANCISCO JAVIER LORENZO MARTINEZ',
    'FRANCISCO JAVIER MARIN',
    'GENARO JIMENEZ GARCÍA',
    'GILBERTO ISAI FRANCO AGUILAR',
    'GONZALO MUÑOZ SARABIA',
    'GUADALUPE ISABEL HERNANDEZ NOLASCO',
    'GUILLERMO ALFREDO GONZALEZ BLANCO',
    'HECTOR IVAN HERNANDEZ RODRIGUEZ',
    'HERON RODRIGUEZ RUIZ',
    'HERVERT DE JESUS SANCHEZ LEMUS',
    'HUMBERTO OSORIO RODRIGUEZ',
    'IGNACIO HERNANDEZ HERNANDEZ',
    'IRVING GENARO VAZQUEZ RAMIREZ',
    'IRVING MAGAÑA PEREZ',
    'ISAI GARCIA RAMIREZ',
    'IVAN ALARCON MONTELONGO',
    'IVAN ARTURO GONZALEZ CORONA',
    'IVAN JOSE DIAZ',
    'IVAN SALVADOR ALARCON MONTELONGO',
    'JESUS FILIBERTO RUIZ MORAN',
    'JESUS HERNANDEZ GONZALEZ',
    'JESUS RUIZ',
    'JESUS TRINIDAD PEREZ',
    'JHONNY GARCIA TOVILLA',
    'JOSE ALBERTO VALENCIA BAUTISTA',
    'JOSE ALFREDO VAZQUEZ',
    'JOSE ANTONIO GARCIA DOMINGUEZ',
    'JOSE ANTONIO LOPEZ VALDES',
    'JOSE DE JESUS VILLANUEVA SALAZAR',
    'JOSE DIAZ CASTRO',
    'JOSE HERNANDEZ GARCÍA',
    'JOSE IVAN ARAN RAVELO',
    'JOSE LUIS ANTONIO ALBINO',
    'JOSE LUIS MARTÍNEZ CABRERA',
    'JOSE LUIS TELLEZ ISLAS',
    'JOSE LUIS TIQUE TIQUE',
    'JOSE OCTAVIO GONZALEZ CARMONA',
    'JOSE ORTIZ',
    'JOSE RICARDO JIMENEZ RIVERA',
    'JOSE RODOLFO VELAZQUEZ GONZALEZ',
    'JOSE TRINIDAD',
    'JOSE VILLANUEVA SALAZAR',
    'JOSUE IVAN ARAN RAVELO',
    'JUAN CARLOS BRINGAS MARTINEZ',
    'JUAN CARLOS CRUZ RIOS',
    'JUAN CARLOS D',
    'JUAN CARLOS GERONIMO TORRES',
    'JUAN DE DIOS RODRIGUEZ LARA',
    'JUAN FERNANDO LLAMAS CASTILLO',
    'JUAN FRANCISCO MENDEZ HERNANDEZ',
    'JUAN FRANCISCO REYES ALDANA',
    'JUAN JESUS HERNANDEZ G',
    'JUAN JOSE DIAZ',
    'JUAN JOSE DIAZ CASTRO',
    'JUAN JOSE LINO FERRER',
    'JUAN MANUEL VITE SANTES',
    'JUAN PABLO LOPEZ ARGÜELLES',
    'JUAN RAMOS PEREZ',
    'JUAN RAMOS ROSAS',
    'JULIO MADERA JARAMILLO',
    'LEONEL GUZMAN TOLENTINO',
    'LEONEL HERNANDEZ GUTIERREZ',
    'LEONEL MENDEZ VILLALBA',
    'LUIS ALBERTO MENDEZ A.',
    'LUIS ALBERTO NARANJO SUAREZ',
    'LUIS ARTURO GONZALEZ CORONA',
    'LUIS ENRIQUE CHAGOYA RAMIREZ',
    'LUIS ENRIQUE FUENTES MENDEZ',
    'LUIS ENRIQUE VIDAL REYES',
    'LUIS ESTEBAN ORTIZ SANCHEZ',
    'LUIS JAVIER DEL ANGEL GRANILLO',
    'LUIS RAUL HIDALGO ALAMILLA',
    'LUIS ROBERTO CARDENAS MENDEZ',
    'MANDALA',
    'MANUEL D. HERNANDEZ MARTINEZ',
    'MARCO ANTONIO JIMENEZ RAMOS',
    'MARCO ANTONIO MAURO SANTES',
    'MARCO EFREN GONZALEZ LAZCANO',
    'MARIA DEL CARMEN ROSAS DECUIR',
    'MARIO ALBERTO VAZQUEZ VIVEROS',
    'MARIO DE JESUS JIMENEZ RAMIREZ',
    'MARIO MEJIA',
    'MELQUISEDEC ROMERO GARCIA',
    'MIGUEL ANGEL GARCÍA JIMENEZ',
    'MIGUEL ANGEL VALDEZ CASADOS',
    'MIGUEL ANGUEL TEJEDA MELO',
    'MISAEL CHACHA ECHEVERRIA',
    'NA',
    'NELSON RENE AGUILAR CASTRO',
    'OCTAVIO GONZALEZ CARMONA',
    'OMAR MURATALLA ESPINOZA',
    'OPERADORES',
    'OSCAR OMAR CASTILLO VEGA',
    'PABLO LOPEZ ARGUELLEZ',
    'PÁNFILO DIAZ CRUZ',
    'PAULO BARRIENTOS NAVA',
    'PIPA',
    'PORFIRIO GARCIA JIMENEZ',
    'PORFIRIO JIMENEZ GONZALEZ',
    'RAFAEL GARCIA ROJAS',
    'RAFAEL MARQUEZ MARTINEZ',
    'RANULFO VERA ROSAS',
    'RAUL HIDALGO ALAMILLA',
    'RAUL MARTIN CRUZ COREDRO',
    'RAUL MEJIA',
    'RENE MAYA TREJO',
    'RENÉ PEREZ VAZQUEZ',
    'RICARDO ALBERTO REYES PEREZ',
    'RICARDO ELY RAMIREZ VAZQUEZ',
    'RICARDO GARCÍA MARQUEZ',
    'RICARDO REYES PEREZ',
    'RICARDO VAZQUEZ',
    'ROBERTO CARLOS ACOSTA MAYTIN',
    'ROBERTO CARLOS CORTÉS PÉREZ',
    'ROBERTO CECILIO',
    'ROBERTO CORTEZ BAQUEIRO',
    'RODOLFO VELAZCO GONZALEZ',
    'ROGELIO VILLAFAÑA',
    'SEBASTIAN MANUEL CARRILLO',
    'SOLDADOR ALBERTO GUADALUPE JIMENEZ RAMIREZ',
    'SOLDADOR ARMANDO ROJAS SILVA',
    'ULISES EDUARDO JIMENEZ LOPEZ',
    'VICENTE HERRERA GONZALEZ',
    'VICENTE OLGUIN RAMIREZ',
    'VIRIDIANA FRANCISCO CARBALLO',
    'WILBERT TRUJEQUE ALAMILLA',
    'ZEFERINO DE LA LUNA PEREZ',
    '(en blanco)',
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
    _odometroUltimoFocusNode.addListener(() => _onFocusChange(_odometroUltimoFocusNode, _validateOdometroUltimo));
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
    setState(() {
      _isPlacasValid = value.isNotEmpty && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value) && value.length <= 10;
    });
  }

  void _validateOdometro(String value) {
    setState(() {
      _isOdometroValid = value.isNotEmpty && RegExp(r'^\d+$').hasMatch(value) && value.length <= 10;
    });
  }

  void _validateOdometroUltimo(String value) {
    setState(() {
      _isOdometroUltimoValid = value.isNotEmpty && RegExp(r'^\d+$').hasMatch(value) && value.length <= 10;
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
                  ),
                  _buildReadOnlyTextField(
                    label: 'Hora',
                    initialValue: _horaActual,
                    description: 'Hora actual (automática).',
                    isSmallScreen: isSmallScreen,
                  ),
                  _buildTextField(
                    controller: _placasController,
                    label: 'Placas de la Unidad',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese las placas de la unidad';
                      } else if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                        return 'Las placas solo deben contener letras y números';
                      } else if (value.length > 10) {
                        return 'Las placas no pueden tener más de 10 caracteres';
                      }
                      return null;
                    },
                    onChanged: _validatePlacas,
                    isValid: _isPlacasValid,
                    focusNode: _placasFocusNode,
                    description: 'Ingrese las placas de la unidad que realizó la carga.',
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
                  _buildTextField(
                    controller: _odometroUltimoController,
                    label: 'Odómetro Última Carga',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el número del odómetro de la última carga';
                      } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                        return 'El odómetro debe ser un número entero';
                      }
                      return null;
                    },
                    onChanged: _validateOdometroUltimo,
                    isValid: _isOdometroUltimoValid,
                    focusNode: _odometroUltimoFocusNode,
                    description: 'Ingrese el número del odómetro de la última carga.',
                    isSmallScreen: isSmallScreen,
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
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    String? label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? description,
    Function(String)? onChanged,
    bool isValid = false,
    FocusNode? focusNode,
    required bool isSmallScreen,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isValid)
                    Icon(Icons.check_circle, color: Colors.green),
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
            validator: validator,
            onChanged: onChanged,
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
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          suffixIcon: IconButton(
            icon: Icon(Icons.help_outline, color: Colors.grey),
            onPressed: () => _mostrarDescripcion(description ?? 'No hay descripción disponible.'),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            iconSize: isSmallScreen ? 20 : 24,
          ),
        ),
        initialValue: initialValue,
        enabled: false,
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
              suffixIcon: IconButton(
                icon: Icon(Icons.help_outline, color: Colors.grey),
                onPressed: () => _mostrarDescripcion(description ?? 'No hay descripción disponible.'),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                iconSize: isSmallScreen ? 20 : 24,
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
              suffixIcon: IconButton(
                icon: Icon(Icons.help_outline, color: Colors.grey),
                onPressed: () => _mostrarDescripcion(description ?? 'No hay descripción disponible.'),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                iconSize: isSmallScreen ? 20 : 24,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _gasolineraController.text.isNotEmpty ? _gasolineraController.text : null,
                onChanged: (String? newValue) {
                  setState(() {
                    _gasolineraController.text = newValue ?? '';
                    _validateGasolinera(newValue ?? '');
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
              suffixIcon: IconButton(
                icon: Icon(Icons.help_outline, color: Colors.grey),
                onPressed: () => _mostrarDescripcion(description ?? 'No hay descripción disponible.'),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                iconSize: isSmallScreen ? 20 : 24,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _tipoGasolina,
                onChanged: (String? newValue) {
                  setState(() {
                    _tipoGasolina = newValue;
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

  Future<void> _enviarFormulario() async {
    if (_formKey.currentState!.validate()) {
      if (_fotoPlacasUrl == null || _fotoUnidadUrl == null || _fotoTicketUrl == null || _fotoOdometroUrl == null) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Por favor, suba todas las imágenes requeridas.'),
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
        return;
      }

      // Mostrar el diálogo de carga
      showLoadingDialog(context);

      final airtableApiToken = 'patW8Q98FkL4zObhH.c46b48da5580a5cb1ecfea2b24a2cd56f4be18a30bcba7b2e7747684f39352ec';
      final airtableBaseId = 'appk2qomcs0VaYbCD';
      final airtableTableName = 'Gasolina';
      final url = 'https://api.airtable.com/v0/$airtableBaseId/$airtableTableName';

      var body = {
        'fields': {
          'Nombre Operador': _operadorSeleccionado, // Usar _operadorSeleccionado
          'Nombre Gasolinera': _gasolineraController.text,
          'Fecha': _fechaHoy,
          'Hora': _horaActual,
          'Placas': _placasController.text,
          'Importe': double.parse(_importeController.text),
          'Litros': double.parse(_litrosController.text),
          'Odometro': int.parse(_odometroController.text),
          'Odometro Ultimo': int.parse(_odometroUltimoController.text),
          'Gasolina': _tipoGasolina,
          'Foto Placas': _fotoPlacasUrl != null ? [{ 'url': _fotoPlacasUrl }] : null,
          'Foto Unidad': _fotoUnidadUrl != null ? [{ 'url': _fotoUnidadUrl }] : null,
          'Foto Ticket': _fotoTicketUrl != null ? [{ 'url': _fotoTicketUrl }] : null,
          'Foto Odometro': _fotoOdometroUrl != null ? [{ 'url': _fotoOdometroUrl }] : null,
        }
      };

      try {
        var response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $airtableApiToken',
            'Content-Type': 'application/json',
          },
          body: json.encode(body),
        );

        Navigator.of(context).pop(); // Cerrar el diálogo de carga

        if (response.statusCode == 200) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Éxito'),
                content: Text('El reporte se ha enviado correctamente.'),
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

        setState(() {
        _operadorSeleccionado = null; // Limpiar el valor seleccionado
        _gasolineraController.clear();
        _importeController.clear();
        _litrosController.clear();
        _placasController.clear();
        _odometroController.clear();
        _odometroUltimoController.clear();
        _fotoPlacasUrl = null;
        _fotoUnidadUrl = null;
        _fotoTicketUrl = null;
        _fotoOdometroUrl = null;
        _isOperadorValid = false;
        _isGasolineraValid = false;
        _isImporteValid = false;
        _isLitrosValid = false;
        _isPlacasValid = false;
        _isOdometroValid = false;
        _isOdometroUltimoValid = false;
        _precioPorLitro = '';
        _tipoGasolina = null;
      });
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Hubo un error al enviar el reporte. Por favor, inténtelo de nuevo.'),
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
      } catch (e) {
        Navigator.of(context).pop(); // Cerrar el diálogo
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Hubo un error de conexión. Por favor, inténtelo de nuevo.'),
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

}