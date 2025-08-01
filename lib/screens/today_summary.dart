import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TotalSalesScreen extends StatefulWidget {
  const TotalSalesScreen({super.key});

  @override
  State<TotalSalesScreen> createState() => _TotalSalesScreenState();
}

class _TotalSalesScreenState extends State<TotalSalesScreen> {
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
          'TOTAL SALES',
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
        
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    margin: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TOTAL SALES - KDC 378L',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink)),
                          const SizedBox(height: 8),
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
                          const SizedBox(height: 12),
                          const Divider(),
                          _buildSalesTable(),
                          const Divider(),
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Total Sales:     KES 70900',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Summary of Sales Statistics Today',
                    style: TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(child: _buildSummaryCard([
                        'Standard Sales: 22',
                        'Discounted Sales: 0',
                        'Ticket Sales: 40'
                      ])),
                      const SizedBox(width: 12),
                      Expanded(child: _buildSummaryCard([
                        'Total Customers: 58',
                        'Customers Served: 58',
                        'Yet to be served: 0'
                      ])),
                      const SizedBox(width: 12),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text(
                        'CLOSE STOCK',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTable() {
    const headers = ['Id', 'Name', 'Qty', 'Total'];
    final rows = [
      ['4081', 'POWER GAS 6KG CYLINDER', '3', '4650'],
      ['4096', 'POWER GAS 13KG CYLINDER', '2', '2650'],
      ['4099', 'POWER REFIL 6KG', '52', '46800'],
      ['4100', 'POWER REFIL 13KG', '4', '7800'],
      ['4108', 'POWER REFIL 50KG', '1', '7500'],
      ['4120', '#A1 burners', '5', '1500'],
    ];
    return Column(
      children: [
        Row(
          children: headers
              .map((h) => Expanded(
                    flex: h == 'Name' ? 3 : 1,
                    child: Text(h, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),
        ...rows.map((row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: row
                    .asMap()
                    .entries
                    .map((entry) => Expanded(
                          flex: entry.key == 1 ? 3 : 1,
                          child: Text(entry.value),
                        ))
                    .toList(),
              ),
            )),
      ],
    );
  }

  Widget _buildSummaryCard(List<String> lines) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: lines.map((text) => Text(text)).toList()),
      ),
    );
  }
}
