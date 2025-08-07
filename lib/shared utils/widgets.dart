import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StyledTextField extends StatefulWidget {
  final String label;
  final bool obscureText;
  final bool readOnly;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Icon? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;

  const StyledTextField({
    super.key,
    required this.label,
    this.obscureText = false,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.readOnly = false,
    this.inputFormatters,
  });

  @override
  _StyledTextFieldState createState() => _StyledTextFieldState();
}

class _StyledTextFieldState extends State<StyledTextField> {
  bool _isObscure = false;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.obscureText;
  }

  @override
  void didUpdateWidget(StyledTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _isObscure = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.obscureText ? _isObscure : false,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        validator: widget.validator,
        readOnly: widget.readOnly,
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: widget.prefixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
          suffixIcon:
              widget.obscureText
                  ? IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  )
                  : null,
        ),
      ),
    );
  }
}

class ErrorDialog extends StatelessWidget {
  final String message;

  const ErrorDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 8),
          const Text('Error'),
        ],
      ),
      content: Text(message, style: TextStyle(color: Colors.grey[800])),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'OK',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
      ],
    );
  }
}

class StyledSelectField<T> extends StatefulWidget {
  final List<T> items;
  final String label;
  final T? selected;
  final void Function(T?) onChanged;
  final String Function(T) displayString;
  final String? Function(T?)? validator;
  final Icon? prefixIcon;

  const StyledSelectField({
    super.key,
    required this.items,
    required this.label,
    required this.selected,
    required this.onChanged,
    required this.displayString,
    this.validator,
    this.prefixIcon,
  });

  @override
  State<StyledSelectField<T>> createState() => _StyledSelectFieldState<T>();
}

class _StyledSelectFieldState<T> extends State<StyledSelectField<T>> {
  late TextEditingController _searchCtrl;
  late List<T> _filtered;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _filtered = widget.items;

    _searchCtrl.addListener(() {
      final query = _searchCtrl.text.toLowerCase();
      setState(() {
        _filtered =
            query.isEmpty
                ? widget.items
                : widget.items.where((item) {
                  final itemText = widget.displayString(item).toLowerCase();
                  return itemText.contains(query);
                }).toList();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openSelectDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                if (widget.prefixIcon != null) ...[
                  widget.prefixIcon!,
                  const SizedBox(width: 8),
                ],
                Text(widget.label),
              ],
            ),
            content: Container(
              width: double.maxFinite,
              constraints: const BoxConstraints(maxHeight: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child:
                        _filtered.isEmpty
                            ? const Center(child: Text('No matching items'))
                            : ListView.builder(
                              itemCount: _filtered.length,
                              itemBuilder: (_, index) {
                                final item = _filtered[index];
                                return Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      widget.displayString(item),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    trailing:
                                        widget.selected == item
                                            ? Icon(
                                              Icons.check,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                            )
                                            : null,
                                    onTap: () {
                                      widget.onChanged(item);
                                      Navigator.pop(context);
                                    },
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openSelectDialog,
      child: AbsorbPointer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            controller: TextEditingController(
              text:
                  widget.selected != null
                      ? widget.displayString(widget.selected!)
                      : '',
            ),
            readOnly: true,
            validator:
                widget.validator != null
                    ? (String? value) {
                      // Convert String? input to T? for the validator
                      return widget.validator!(widget.selected);
                    }
                    : null,
            decoration: InputDecoration(
              labelText: widget.label,
              prefixIcon: widget.prefixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 12,
              ),
              suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
            ),
          ),
        ),
      ),
    );
  }
}

class SuccessDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onClose;

  const SuccessDialog({super.key, required this.message, this.onClose});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[700]),
          const SizedBox(width: 8),
          const Text('Success'),
        ],
      ),
      content: Text(message, style: TextStyle(color: Colors.grey[800])),
      actions: [
        TextButton(
          onPressed: () {
            if (onClose != null) onClose!();
            Navigator.pop(context);
          },
          child: Text(
            'OK',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
      ],
    );
  }
}
