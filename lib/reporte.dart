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

  // FocusNodes para cada campo de texto
  final FocusNode _operadorFocusNode = FocusNode();
  final FocusNode _gasolineraFocusNode = FocusNode();
  final FocusNode _importeFocusNode = FocusNode();
  final FocusNode _litrosFocusNode = FocusNode();
  final FocusNode _placasFocusNode = FocusNode();
  final FocusNode _odometroFocusNode = FocusNode(); // Nuevo FocusNode


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
  }

  @override
  void dispose() {
    // Limpiar los FocusNodes
    _operadorFocusNode.dispose();
    _gasolineraFocusNode.dispose();
    _importeFocusNode.dispose();
    _litrosFocusNode.dispose();
    _placasFocusNode.dispose();
    _odometroFocusNode.dispose(); // Limpiar el FocusNode del odómetro
    super.dispose();
  }

  void _onFocusChange(FocusNode focusNode, Function(String) validator) {
    if (!focusNode.hasFocus) {
      // Cuando el campo pierde el foco, validar el texto
      validator(_getControllerText(focusNode));
    }
  }

  String _getControllerText(FocusNode focusNode) {
    if (focusNode == _operadorFocusNode) return _operadorController.text;
    if (focusNode == _gasolineraFocusNode) return _gasolineraController.text;
    if (focusNode == _importeFocusNode) return _importeController.text;
    if (focusNode == _litrosFocusNode) return _litrosController.text;
    if (focusNode == _placasFocusNode) return _placasController.text;
    if (focusNode == _odometroFocusNode) return _odometroController.text; // Agregar el odómetro
    return '';
  }

  void _validateOperador(String value) {
    setState(() {
      _isOperadorValid = value.isNotEmpty && RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value);
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
    _isOdometroValid = value.isNotEmpty && RegExp(r'^\d+$').hasMatch(value)&& value.length <= 10;
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
    cameraInput.accept = 'image/*'; // Aceptar solo imágenes
    cameraInput.click(); // Abrir el selector de archivos o la cámara

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

      // Mostrar mensaje de éxito específico
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
    // Store the build context
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
                Navigator.of(context).pop(); // Cerrar el diálogo de vista previa
                
                // Crear un BuildContext separado para el diálogo de carga
                BuildContext? loadingDialogContext;
                
                // Mostrar diálogo de carga
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
                    // Verificar si el widget aún está montado
                    if (mounted && loadingDialogContext != null) {
                      Navigator.of(loadingDialogContext!).pop(); // Cerrar el diálogo de carga
                      onImageSelected(imageUrl); // Llamar al callback con la URL de la imagen
                    }
                  }, imageType); // Pasar el tipo de imagen como tercer argumento
                } catch (e) {
                  // Verificar si el widget aún está montado
                  if (mounted && loadingDialogContext != null) {
                    Navigator.of(loadingDialogContext!).pop(); // Cerrar el diálogo de carga
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
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reporte de Carga de Combustible'),
        backgroundColor: Color(0xFFC0261F),
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTextField(
                controller: _operadorController,
                label: 'Nombre del Operador',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el nombre del operador';
                  } else if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
                    return 'El nombre solo debe contener letras';
                  }
                  return null;
                },
                onChanged: _validateOperador,
                isValid: _isOperadorValid,
                description: 'Ingrese el nombre completo del operador empezando por apellidos.',
              ),
              _buildTextField(
                controller: _gasolineraController,
                label: 'Nombre de la Gasolinera',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese el nombre de la gasolinera' : null,
                onChanged: _validateGasolinera,
                isValid: _isGasolineraValid,
                description: 'Ingrese el nombre de la gasolinera donde se realizó la carga (Tal cual se muestra en el ticket).',
              ),
              _buildReadOnlyTextField(
                  label: 'Fecha',
                  initialValue: _fechaHoy,
                  description: 'Fecha de hoy (automática).'),
              _buildReadOnlyTextField(
                  label: 'Hora',
                  initialValue: _horaActual,
                  description: 'Hora actual (automática).'),
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
                description: 'Ingrese las placas de la unidad que realizó la carga.',
              ),
              _buildCameraButton(
                'Tomar Foto de las placas',
                'Tome una foto de las placas del vehículo.  (Foto legible)',
                onPressed: () {
                  _openCameraOrFilePicker((imageData) {
                    _showImagePreviewDialog(imageData, (imageUrl) {
                      setState(() {
                        _fotoPlacasUrl = imageUrl; // Usar _fotoPlacasUrl en lugar de _fotoOdometroUrl
                      });
                    }, 'Foto Placas'); // Pasar el tipo de imagen
                  });
                },
                isUploaded: _fotoPlacasUrl != null, // Verificar _fotoPlacasUrl
                imageUrl: _fotoPlacasUrl, // Pasar la URL de la imagen
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
                onChanged: _validateImporte,
                isValid: _isImporteValid,
                description: 'Ingrese el importe total del combustible cargado. (Tal cual se muestra en el ticket)',
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
                onChanged: _validateLitros,
                isValid: _isLitrosValid,
                description: 'Ingrese la cantidad de litros de combustible cargados. (Tal cual se muestra en el ticket)',
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
              onChanged: _validateOdometro, // Asegúrate de que esto esté correctamente configurado
              isValid: _isOdometroValid,
              focusNode: _odometroFocusNode, // Pasar el FocusNode
              description: 'Ingrese el número del odómetro del vehículo.',
            ),
            _buildCameraButton(
                'Tomar Foto del Odómetro',
                'Tome una foto del odómetro del vehículo.  (Foto legible)',
                onPressed: () {
                  _openCameraOrFilePicker((imageData) {
                    _showImagePreviewDialog(imageData, (imageUrl) {
                      setState(() {
                        _fotoOdometroUrl = imageUrl; // Usar _fotoOdometroUrl
                      });
                    }, 'Foto Odómetro'); // Pasar el tipo de imagen
                  });
                },
                isUploaded: _fotoOdometroUrl != null, // Verificar _fotoOdometroUrl
                imageUrl: _fotoOdometroUrl, // Pasar la URL de la imagen
              ),
              _buildCameraButton(
                'Tomar Foto del Ticket',
                'Tome una foto del ticket de la compra de combustible. (Foto legible)',
                onPressed: () {
                  _openCameraOrFilePicker((imageData) {
                    _showImagePreviewDialog(imageData, (imageUrl) {
                      setState(() {
                        _fotoTicketUrl = imageUrl;
                      });
                    }, 'Foto Ticket'); // Pasar el tipo de imagen
                  });
                },
                isUploaded: _fotoTicketUrl != null,
                imageUrl: _fotoTicketUrl, // Pasar la URL de la imagen
              ),
              _buildCameraButton(
                'Tomar Foto de la Unidad en Gasolinera',
                'Tome una foto de la unidad en la gasolinera. (Foto donde se vean las placas)',
                onPressed: () {
                  _openCameraOrFilePicker((imageData) {
                    _showImagePreviewDialog(imageData, (imageUrl) {
                      setState(() {
                        _fotoUnidadUrl = imageUrl;
                      });
                    }, 'Foto Unidad'); // Pasar el tipo de imagen
                  });
                },
                isUploaded: _fotoUnidadUrl != null,
                imageUrl: _fotoUnidadUrl, // Pasar la URL de la imagen
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Stack(
        children: [
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isValid)
                    Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8), // Espacio entre el ícono y el botón de info
                  _buildDescriptionIcon(description),
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

  Widget _buildReadOnlyTextField(
      {String? label, String? initialValue, String? description}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Stack(
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
            ),
            initialValue: initialValue,
            enabled: false,
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _buildDescriptionIcon(description),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionIcon(String? description) {
    return IconButton(
      icon: Icon(Icons.help_outline, color: Colors.grey),
      onPressed: () =>
          _mostrarDescripcion(description ?? 'No hay descripción disponible.'),
    );
  }

  Widget _buildCameraButton(String label, String description, {required Function() onPressed, bool isUploaded = false, String? imageUrl}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isUploaded)
          InkWell(
            onTap: () {
              if (imageUrl != null) {
                _showImagePreviewDialog(imageUrl, (imageUrl) {}, 'Vista previa'); // Abrir vista previa
              }
            },
            child: Icon(Icons.check_circle, color: Colors.green),
          ),
        SizedBox(width: 8), // Espacio entre el ícono y el botón
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 5,
            backgroundColor: Color(0xFFC0261F),
          ),
          child: Text(label,
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
        IconButton(
          icon: Icon(Icons.help_outline, color: Colors.grey),
          onPressed: () =>
              _mostrarDescripcion(description),
        ),
      ],
    ),
  );
}

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Evita que el usuario cierre el diálogo tocando fuera
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
          'Nombre Operador': _operadorController.text,
          'Nombre Gasolinera': _gasolineraController.text,
          'Fecha': _fechaHoy,
          'Hora': _horaActual,
          'Placas': _placasController.text,
          'Importe': double.parse(_importeController.text),
          'Litros': double.parse(_litrosController.text),
          'Odometro': int.parse(_odometroController.text),
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

          _operadorController.clear();
          _gasolineraController.clear();
          _importeController.clear();
          _litrosController.clear();
          _placasController.clear();
          _odometroController.clear();

          setState(() {
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
        Navigator.of(context).pop(); // Cerrar el diálogo de carga en caso de error
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