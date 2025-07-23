// Payment Screen
import 'package:chevenergies/services/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required String invoiceId});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _invoiceIdController = TextEditingController();
  final _amountController = TextEditingController();
  String _paymentMode = 'Cash';
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Process Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _invoiceIdController,
              decoration: const InputDecoration(labelText: 'Invoice ID'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: _paymentMode,
              items: ['Cash', 'Credit', 'M-Pesa']
                  .map((mode) => DropdownMenuItem(value: mode, child: Text(mode)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _paymentMode = value!;
                });
              },
            ),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await Provider.of<AppState>(context, listen: false).createPayment(
                    _invoiceIdController.text,
                    double.parse(_amountController.text),
                    _paymentMode,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment processed successfully')),
                  );
                } catch (e) {
                  setState(() {
                    _error = 'Failed to process payment: $e';
                  });
                }
              },
              child: const Text('Process Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
