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
      appBar: AppBar(
        backgroundColor: const Color(0xFF228B22),
        elevation: 0,
        leading: IconButton(
          padding: const EdgeInsets.all(10),
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'SUMMARY',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.2,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 6),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(20),
          child: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: 70,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
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
