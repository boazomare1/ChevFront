import 'package:flutter/material.dart';

class StyledTextField extends StatefulWidget {
  final String label;
  final bool obscureText;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const StyledTextField({
    super.key,
    required this.label,
    this.obscureText = false,
    required this.controller,
    this.keyboardType = TextInputType.text,
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: widget.controller,
        obscureText: _isObscure,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          labelText: widget.label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          filled: true,
          fillColor: const Color.fromARGB(
            255,
            196,
            233,
            198,
          ), // Magenta background
          suffixIcon:
              widget.obscureText
                  ? IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white,
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
      title: const Text('Error'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
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

  const StyledSelectField({
    super.key,
    required this.items,
    required this.label,
    required this.selected,
    required this.onChanged,
    required this.displayString,
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
            title: Text(widget.label),
            content: Container(
              width: double.maxFinite,
              constraints: const BoxConstraints(maxHeight: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search Input
                  TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Search .... ',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filtered List
                  Expanded(
                    child:
                        _filtered.isEmpty
                            ? const Center(child: Text('No matching items'))
                            : ListView.builder(
                              itemCount: _filtered.length,
                              itemBuilder: (_, index) {
                                final item = _filtered[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color.fromARGB(
                                        255,
                                        196,
                                        233,
                                        198,
                                      ), // soft green border
                                      width: 1.5,
                                    ),
                                  ),
                                  child: ListTile(
                                    title: Text(widget.displayString(item)),
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
                child: const Text('CANCEL'),
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
          child: TextField(
            controller: TextEditingController(
              text:
                  widget.selected != null
                      ? widget.displayString(widget.selected!)
                      : '',
            ),
            readOnly: true,
            decoration: InputDecoration(
              labelText: widget.label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: const Color.fromARGB(255, 196, 233, 198),
              suffixIcon: const Icon(Icons.arrow_drop_down),
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
      title: const Text('Success'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            if (onClose != null) onClose!();
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
