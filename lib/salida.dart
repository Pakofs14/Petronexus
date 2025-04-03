import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class SalidaAlmacenPage extends StatefulWidget {
  final String usuario;

  const SalidaAlmacenPage({super.key, required this.usuario});

  @override
  _SalidaAlmacenPageState createState() => _SalidaAlmacenPageState();
}

class _SalidaAlmacenPageState extends State<SalidaAlmacenPage> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _items = [];
  final int _folio = DateTime.now().millisecondsSinceEpoch % 100000;

  // Campos del formulario
  String _noPedido = '';
  String _areaSolicitante = '';
  String _nombreUsuario = '';
  String _cargo = '';
  String _usuarioSAE = '';
  String _base = '';
  String _noContrato = '';
  String _fechaSolicitud = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _remisionSAE = '';
  String _fechaEntrega = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // Campos para nuevos items
  String _descripcionBien = '';
  String _noPozo = '';
  String _unidadMedida = '';
  String _cantidadSolicitada = '';
  String _cantidadEntregada = '';
  String _observaciones = '';

  // Firmas
  String _nombreEntrega = '';
  String _nombreRecibe = '';
  String _nombreVigilancia = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salida de Almacén'),
        backgroundColor: const Color(0xFFC0261F),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildMainForm(),
              const SizedBox(height: 20),
              _buildItemsTable(),
              const SizedBox(height: 20),
              _buildNewItemForm(),
              const SizedBox(height: 20),
              _buildSignaturesSection(),
              const SizedBox(height: 30),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'SALIDA DE ALMACÉN',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          'FOLIO: $_folio',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMainForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                  'No. DE PEDIDO', (value) => _noPedido = value, _noPedido),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField('BASE', (value) => _base = value, _base),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildTextField('AREA SOLICITANTE', (value) => _areaSolicitante = value,
            _areaSolicitante),
        const SizedBox(height: 10),
        _buildTextField('NOMBRE DEL USUARIO', (value) => _nombreUsuario = value,
            _nombreUsuario),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child:
                  _buildTextField('CARGO', (value) => _cargo = value, _cargo),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField('No. DE CONTRATO',
                  (value) => _noContrato = value, _noContrato),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                  'USUARIO SAE', (value) => _usuarioSAE = value, _usuarioSAE),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDateField('FECHA DE SOLICITUD',
                  (value) => _fechaSolicitud = value, _fechaSolicitud),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildTextField(
            'REMISIÓN SAE', (value) => _remisionSAE = value, _remisionSAE),
      ],
    );
  }

  Widget _buildItemsTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ARTÍCULOS SOLICITADOS',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('No.')),
              DataColumn(label: Text('DESCRIPCIÓN DEL BIEN')),
              DataColumn(label: Text('No. POZO')),
              DataColumn(label: Text('UNIDAD DE MEDIDA')),
              DataColumn(label: Text('CANT. SOLICITADA')),
              DataColumn(label: Text('CANT. ENTREGADA')),
              DataColumn(label: Text('OBSERVACIONES')),
              DataColumn(label: Text('ACCIONES')),
            ],
            rows: _items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return DataRow(cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(item['descripcion'] ?? '')),
                DataCell(Text(item['pozo'] ?? '')),
                DataCell(Text(item['unidad'] ?? '')),
                DataCell(Text(item['solicitada'] ?? '')),
                DataCell(Text(item['entregada'] ?? '')),
                DataCell(Text(item['observaciones'] ?? '')),
                DataCell(IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeItem(index),
                )),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNewItemForm() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AGREGAR NUEVO ARTÍCULO',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildTextField('DESCRIPCIÓN DEL BIEN',
                (value) => _descripcionBien = value, _descripcionBien),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                      'No. POZO', (value) => _noPozo = value, _noPozo),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField('UNIDAD DE MEDIDA',
                      (value) => _unidadMedida = value, _unidadMedida),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                      'CANTIDAD SOLICITADA',
                      (value) => _cantidadSolicitada = value,
                      _cantidadSolicitada,
                      keyboardType: TextInputType.number),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField('CANTIDAD ENTREGADA',
                      (value) => _cantidadEntregada = value, _cantidadEntregada,
                      keyboardType: TextInputType.number),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField('OBSERVACIONES', (value) => _observaciones = value,
                _observaciones),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _addItem,
                child: const Text('Agregar Artículo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignaturesSection() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FIRMAS DE AUTORIZACIÓN',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildDateField('FECHA DE ENTREGA',
                (value) => _fechaEntrega = value, _fechaEntrega),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSignatureField(
                    'Vo.Bo. DIRECCIÓN', (value) => _nombreEntrega = value),
                _buildSignatureField(
                    'Vo.Bo. JEFE INMEDIATO', (value) => _nombreRecibe = value),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSignatureField(
                    'ENTREGA', (value) => _nombreEntrega = value),
                _buildSignatureField(
                    'RECIBE', (value) => _nombreRecibe = value),
                _buildSignatureField(
                    'VIGILANCIA', (value) => _nombreVigilancia = value),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text('NOMBRE Y FIRMA'),
                const Text('NOMBRE Y FIRMA'),
                const Text('NOMBRE Y FIRMA'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, Function(String) onSaved, String initialValue,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      initialValue: initialValue,
      onSaved: (value) => onSaved(value ?? ''),
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
    );
  }

  Widget _buildDateField(
      String label, Function(String) onSaved, String initialValue) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      controller: TextEditingController(text: initialValue),
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          final formattedDate = DateFormat('yyyy-MM-dd').format(date);
          onSaved(formattedDate);
          setState(() {
            if (label == 'FECHA DE SOLICITUD') {
              _fechaSolicitud = formattedDate;
            } else {
              _fechaEntrega = formattedDate;
            }
          });
        }
      },
    );
  }

  Widget _buildSignatureField(String label, Function(String) onSaved) {
    return SizedBox(
      width: 100,
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const UnderlineInputBorder(),
        ),
        onSaved: (value) => onSaved(value ?? ''),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC0261F),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        ),
        onPressed: _submitForm,
        child: const Text(
          'GUARDAR SALIDA DE ALMACÉN',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _addItem() {
    if (_descripcionBien.isEmpty) {
      _showError('La descripción del bien es requerida');
      return;
    }

    setState(() {
      _items.add({
        'descripcion': _descripcionBien,
        'pozo': _noPozo,
        'unidad': _unidadMedida,
        'solicitada': _cantidadSolicitada,
        'entregada': _cantidadEntregada,
        'observaciones': _observaciones,
      });

      // Limpiar campos después de agregar
      _descripcionBien = '';
      _noPozo = '';
      _unidadMedida = '';
      _cantidadSolicitada = '';
      _cantidadEntregada = '';
      _observaciones = '';
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_items.isEmpty) {
        _showError('Debe agregar al menos un artículo');
        return;
      }

      // Aquí iría la lógica para guardar los datos en la base de datos o API
      _showSuccessDialog();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Éxito'),
          content: const Text(
              'La salida de almacén se ha registrado correctamente.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
