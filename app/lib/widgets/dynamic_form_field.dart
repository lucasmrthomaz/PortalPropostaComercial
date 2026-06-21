import 'package:flutter/material.dart';
import '../models/proposal_type.dart';
import '../core/constants.dart';

class DynamicFormField extends StatefulWidget {
  final CampoTipoProposta field;
  final dynamic initialValue;
  final ValueChanged<dynamic> onChanged;

  const DynamicFormField({
    super.key,
    required this.field,
    this.initialValue,
    required this.onChanged,
  });

  @override
  State<DynamicFormField> createState() => _DynamicFormFieldState();
}

class _DynamicFormFieldState extends State<DynamicFormField> {
  late TextEditingController _textController;
  bool _boolValue = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.initialValue != null ? widget.initialValue.toString() : '',
    );
    if (widget.field.tipo == 'boolean') {
      _boolValue = widget.initialValue == true || widget.initialValue == 'true';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.field.tipo == 'boolean') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SwitchListTile(
          value: _boolValue,
          onChanged: (val) {
            setState(() {
              _boolValue = val;
            });
            widget.onChanged(val);
          },
          title: Text(widget.field.nome),
          subtitle: widget.field.obrigatorio
              ? const Text('Obrigatório',
                  style: TextStyle(color: Colors.red, fontSize: 11))
              : null,
          contentPadding: EdgeInsets.zero,
          activeThumbColor: AppColors.primary,
        ),
      );
    }

    TextInputType inputType = TextInputType.text;
    if (widget.field.tipo == 'number') {
      inputType = const TextInputType.numberWithOptions(decimal: true);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _textController,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: widget.field.nome + (widget.field.obrigatorio ? ' *' : ''),
          border: OutlineInputBorder(borderRadius: AppStyles.inputRadius),
        ),
        validator: (value) {
          if (widget.field.obrigatorio &&
              (value == null || value.trim().isEmpty)) {
            return 'Este campo é obrigatório';
          }
          if (widget.field.tipo == 'number' &&
              value != null &&
              value.trim().isNotEmpty) {
            if (double.tryParse(value) == null) {
              return 'Insira um valor numérico válido';
            }
          }
          return null;
        },
        onChanged: (val) {
          if (widget.field.tipo == 'number') {
            widget.onChanged(double.tryParse(val) ?? val);
          } else {
            widget.onChanged(val);
          }
        },
      ),
    );
  }
}
