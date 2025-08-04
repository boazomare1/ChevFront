import 'dart:io';
import 'package:chevenergies/models/invoice.dart';
import 'package:chevenergies/services/app_state.dart';
import 'package:chevenergies/shared%20utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
class PaymentScreen extends StatefulWidget {
  final String invoiceId;
  final double totalAmount;

  const PaymentScreen({
    super.key,
    required this.invoiceId,
    required this.totalAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMode = 'Cash';
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _chequeNumberCtrl = TextEditingController();
  XFile? _chequeImage;
  bool _loading = false;

  final List<String> availableModes = ['Cash', 'Mpesa', 'Cheque', 'Invoice'];

  Future<void> _submitPayment() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      showDialog(
        context: context,
        builder: (_) => const ErrorDialog(message: 'Enter a valid amount'),
      );
      return;
    }

    if (_selectedMode == 'Cheque') {
      if (_chequeNumberCtrl.text.isEmpty || _chequeImage == null) {
        showDialog(
          context: context,
          builder: (_) => const ErrorDialog(
            message: 'Provide cheque number and image',
          ),
        );
        return;
      }
    }

    setState(() => _loading = true);

    try {
      await Provider.of<AppState>(context, listen: false).createPayment(
        widget.invoiceId,
        amount,
        _selectedMode,
      );

      showDialog(
        context: context,
        builder: (_) => SuccessDialog(
          message: 'Payment successful',
          onClose: () => Navigator.pop(context), // Pop dialog
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => ErrorDialog(message: 'Payment Completion failed'),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickChequeImage() async {
    final ImagePicker picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _chequeImage = picked);
    }
  }

  @override
  void initState() {
    super.initState();
    _amountCtrl.text = widget.totalAmount.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(
                  'Invoice ID: ${widget.invoiceId}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _selectedMode,
                  decoration: const InputDecoration(labelText: 'Payment Mode'),
                  items: availableModes.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(mode),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedMode = val);
                  },
                ),
                const SizedBox(height: 12),

                StyledTextField(
                  label: 'Amount',
                  controller: _amountCtrl,
                  readOnly: true,
                  keyboardType: TextInputType.number,
                ),

                if (_selectedMode == 'Cheque') ...[
                  StyledTextField(
                    label: 'Cheque Number',
                    controller: _chequeNumberCtrl,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _pickChequeImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Capture Cheque Image'),
                  ),
                  if (_chequeImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Image.file(
                        File(_chequeImage!.path),
                        height: 150,
                      ),
                    ),
                ],
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _submitPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('Finish Payment'),
                ),
              ],
            ),
          ),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
