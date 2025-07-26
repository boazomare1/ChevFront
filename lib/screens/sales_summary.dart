import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesSummaryScreen extends StatefulWidget {
  const SalesSummaryScreen({super.key});

  @override
  State<SalesSummaryScreen> createState() => _SalesSummaryScreenState();
}

class _SalesSummaryScreenState extends State<SalesSummaryScreen> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  String formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            color: Colors.green[800],
            padding: const EdgeInsets.only(top: 50, bottom: 16),
            width: double.infinity,
            child: const Column(
              children: [
                Text('SUMMARY',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 4),
                Text('―', style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SUMMARY - KDC 378L',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.pink)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Start Date'),
                            InkWell(
                              onTap: () => _pickDate(isStart: true),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                ),
                                child: Text(formatDate(startDate)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('End Date'),
                            InkWell(
                              onTap: () => _pickDate(isStart: false),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                ),
                                child: Text(formatDate(endDate)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                        ),
                        child: const Text('SUBMIT'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow('Outlets Visited / Beat-Plan', '0 / 10'),
                  _buildSummaryRow('Active Sale / Ticketing', '0 / 10'),
                  _buildSummaryRow('Productivity', '0'),
                  _buildSummaryRow('Total Discount Allowed', '0'),
                  _buildSummaryRow('New Customer Created', '0'),
                  _buildSummaryRow('Perfect Store', 'null'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(':  $value'),
        ],
      ),
    );
  }
}
