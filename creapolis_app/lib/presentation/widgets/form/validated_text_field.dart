import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// TextField con validación en tiempo real y feedback visual
class ValidatedTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final bool validateOnType;
  final Duration debounceTime;
  final AutovalidateMode autovalidateMode;

  const ValidatedTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onEditingComplete,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.validateOnType = true,
    this.debounceTime = const Duration(milliseconds: 500),
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  late TextEditingController _controller;
  String? _errorText;
  bool _isValid = false;
  bool _hasInteracted = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    if (!widget.validateOnType || !_hasInteracted) return;

    // Cancelar timer anterior
    _debounce?.cancel();

    // Crear nuevo timer para validación debounced
    _debounce = Timer(widget.debounceTime, () {
      _validate();
    });

    widget.onChanged?.call(_controller.text);
  }

  void _validate() {
    if (widget.validator == null) return;

    setState(() {
      _errorText = widget.validator!(_controller.text);
      _isValid = _errorText == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determinar color del borde según validación
    Color? borderColor;
    if (_hasInteracted && _controller.text.isNotEmpty) {
      borderColor = _isValid ? Colors.green : null;
    }

    return TextFormField(
      controller: _controller,
      enabled: widget.enabled,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      autovalidateMode: widget.autovalidateMode,
      onChanged: (value) {
        if (!_hasInteracted) {
          setState(() => _hasInteracted = true);
        }
        widget.onChanged?.call(value);
      },
      onEditingComplete: widget.onEditingComplete,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helperText,
        errorText: _hasInteracted ? _errorText : null,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: _buildSuffixIcon(colorScheme),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: borderColor != null
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor, width: 2),
              )
            : null,
        focusedBorder: borderColor != null
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor, width: 2),
              )
            : null,
      ),
    );
  }

  Widget? _buildSuffixIcon(ColorScheme colorScheme) {
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }

    // Mostrar icono de validación si ha interactuado y hay texto
    if (_hasInteracted && _controller.text.isNotEmpty) {
      return Icon(
        _isValid ? Icons.check_circle : Icons.error,
        color: _isValid ? Colors.green : colorScheme.error,
      );
    }

    return null;
  }
}

/// Dropdown con validación y feedback visual
class ValidatedDropdown<T> extends StatefulWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? label;
  final String? hint;
  final String? helperText;
  final IconData? prefixIcon;
  final String? Function(T?)? validator;
  final bool enabled;

  const ValidatedDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.validator,
    this.enabled = true,
  });

  @override
  State<ValidatedDropdown<T>> createState() => _ValidatedDropdownState<T>();
}

class _ValidatedDropdownState<T> extends State<ValidatedDropdown<T>> {
  String? _errorText;
  bool _hasInteracted = false;

  void _validate() {
    if (widget.validator == null) return;

    setState(() {
      _errorText = widget.validator!(widget.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: widget.value,
      items: widget.items,
      onChanged: widget.enabled
          ? (value) {
              if (!_hasInteracted) {
                setState(() => _hasInteracted = true);
              }
              widget.onChanged(value);
              _validate();
            }
          : null,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helperText,
        errorText: _hasInteracted ? _errorText : null,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Checkbox con label y validación
class ValidatedCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final String? Function(bool?)? validator;
  final bool enabled;

  const ValidatedCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.validator,
    this.enabled = true,
  });

  @override
  State<ValidatedCheckbox> createState() => _ValidatedCheckboxState();
}

class _ValidatedCheckboxState extends State<ValidatedCheckbox> {
  String? _errorText;
  bool _hasInteracted = false;

  void _validate() {
    if (widget.validator == null) return;

    setState(() {
      _errorText = widget.validator!(widget.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          value: widget.value,
          onChanged: widget.enabled
              ? (value) {
                  if (!_hasInteracted) {
                    setState(() => _hasInteracted = true);
                  }
                  widget.onChanged(value ?? false);
                  _validate();
                }
              : null,
          title: Text(widget.label),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        if (_hasInteracted && _errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              _errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
