import 'package:flutter/material.dart';
import 'package:chevenergies/models/expenditure.dart';

class ExpenditureDetailScreen extends StatelessWidget {
  final Expenditure expenditure;
  const ExpenditureDetailScreen({super.key, required this.expenditure});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'EXPENDITURE DETAILS',
          style: TextStyle(color: Colors.white, letterSpacing: 0.5),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildDetailTile('Name', expenditure.name),
          _buildDetailTile('Day', expenditure.day),
          _buildDetailTile('Date', expenditure.date),
          _buildDetailTile('Requested Amount', expenditure.requestedAmount),
          _buildDetailTile('Approved Amount', expenditure.approvedAmount),
          _buildDetailTile('Status', expenditure.status),
          _buildDetailTile('Comments', expenditure.comments),
        ],
      ),
    );
  }

  Widget _buildDetailTile(String title, String value) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontSize: 13,
            letterSpacing: 0.8,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
