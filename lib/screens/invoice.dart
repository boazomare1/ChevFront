// Invoice Screen
import 'dart:convert';
import 'package:chevenergies/models/item.dart';
import 'package:chevenergies/screens/payment.dart';
import 'package:chevenergies/services/app_state.dart';
import 'package:chevenergies/shared%20utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class InvoiceScreen extends StatefulWidget {
  final String routeId;
  final Item item;
  const InvoiceScreen({super.key, required this.routeId, required this.item});

  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final _stopIdController = TextEditingController();
  final _qtyController = TextEditingController();
  String _selectedDay = 'wednesday'; // Matches current date: July 23, 2025, 10:05 AM EAT
  String? _error;
  String? _invoiceId;
  String? _warning;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Raise Invoice')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Item: ${widget.item.itemName}'),
            Text('Price: ${widget.item.sellingPrice}'),
            TextField(
              controller: _stopIdController,
              decoration: const InputDecoration(labelText: 'Stop ID'),
            ),
            TextField(
              controller: _qtyController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: _selectedDay,
              items: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']
                  .map((day) => DropdownMenuItem(value: day, child: Text(day.capitalize())))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDay = value!;
                });
              },
            ),
            if (_invoiceId != null) Text('Invoice ID: $_invoiceId', style: const TextStyle(color: Colors.green)),
            if (_warning != null) Text(_warning!, style: const TextStyle(color: Colors.orange)),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await Provider.of<AppState>(context, listen: false).raiseInvoice(
                    widget.routeId,
                    _stopIdController.text,
                    _selectedDay,
                    [Item(
                      itemCode: widget.item.itemCode,
                      itemName: widget.item.itemName,
                      description: widget.item.description,
                      quantity: double.parse(_qtyController.text),
                      warehouse: widget.item.warehouse,
                      sellingPrice: widget.item.sellingPrice,
                      amount: widget.item.amount,
                    )],
                  );
                  final response = await http.post(
                    Uri.parse('https://chevenergies.techsavanna.technology/api/method/route_plan.apis.sales.raise_invoice'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer ${Provider.of<AppState>(context, listen: false).apiService.token}',
                    },
                    body: jsonEncode({
                      'route_id': widget.routeId,
                      'stop_id': _stopIdController.text,
                      'day': _selectedDay,
                      'items': [{'item_code': widget.item.itemCode, 'qty': double.parse(_qtyController.text)}],
                    }),
                  );
                  final data = jsonDecode(response.body);
                  setState(() {
                    _invoiceId = data['invoice_id'];
                    if (data['_server_messages'] != null) {
                      final messages = jsonDecode(data['_server_messages']);
                      _warning = messages[0]['message'] ?? 'No warning';
                    }
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(invoiceId: _invoiceId!, totalAmount: 0,),
                    ),
                  );
                } catch (e) {
                  setState(() {
                    _error = 'Failed to raise invoice: $e';
                  });
                }
              },
              child: const Text('Raise Invoice'),
            ),
          ],
        ),
      ),
    );
  }
}
