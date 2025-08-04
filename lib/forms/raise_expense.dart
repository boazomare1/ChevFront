import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddExpenditureForm extends StatefulWidget {
  const AddExpenditureForm({super.key});

  @override
  State<AddExpenditureForm> createState() => _AddExpenditureFormState();
}

class _AddExpenditureFormState extends State<AddExpenditureForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _commentsController = TextEditingController();

  String _status = 'Pending';
  File? _receiptImage;
  String? _receiptBase64;

  Future<void> _pickReceipt() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) {
      final file = File(picked.path);
      final bytes = await file.readAsBytes();
      setState(() {
        _receiptImage = file;
        _receiptBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final payload = {
        'day': DateFormat.EEEE().format(now),
        'date': DateFormat('yyyy-MM-dd').format(now),
        'name': _nameController.text.trim(),
        'requestedAmount': _amountController.text.trim(),
        'approvedAmount': '0',
        'comments': _commentsController.text.trim(),
        'status': _status,
        'receipt': _receiptBase64 ?? '',
      };

      Navigator.of(context).pop();
      debugPrint('Submitting payload: $payload');

      // TODO: Send to backend
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text(
              'NEW EXPENSE CLAIM',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Claim Title', border: OutlineInputBorder()),
              validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Requested Amount', border: OutlineInputBorder()),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Amount is required';
                if (double.tryParse(val.trim()) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _commentsController,
              decoration: const InputDecoration(labelText: 'Comments (Optional)', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _pickReceipt,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Receipt (Optional)'),
              ),
            ),
            if (_receiptImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(_receiptImage!, height: 100),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send),
              label: const Text('SUBMIT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(45),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
