// expenditure_screen.dart
import 'package:chevenergies/forms/raise_expense.dart';
import 'package:chevenergies/models/expenditure.dart';
import 'package:chevenergies/screens/expenditure_detail.dart';
import 'package:flutter/material.dart';

class ExpenditureScreen extends StatefulWidget {
  const ExpenditureScreen({super.key});

  @override
  State<ExpenditureScreen> createState() => _ExpenditureScreenState();
}

class _ExpenditureScreenState extends State<ExpenditureScreen> {
  final List<Expenditure> _expenditures = [
    Expenditure(
      day: 'Monday',
      date: '2025-08-01',
      name: 'Samson Safari',
      requestedAmount: 'KES 5,000',
      approvedAmount: 'KES 4,000',
      comments: 'Fuel and meals',
      status: 'APPROVED',
    ),
    Expenditure(
      day: 'Tuesday',
      date: '2025-08-02',
      name: 'Mercy Mutua',
      requestedAmount: 'KES 3,500',
      approvedAmount: 'KES 3,500',
      comments: 'Transport refund',
      status: 'APPROVED',
    ),
    Expenditure(
      day: 'Wednesday',
      date: '2025-08-03',
      name: 'James Mwangi',
      requestedAmount: 'KES 2,000',
      approvedAmount: 'KES 0',
      comments: 'Unclear receipt',
      status: 'REJECTED',
    ),
  ];

  bool _loading = false;

  Future<void> _refresh() async {
    setState(() => _loading = true);
    // TODO: fetch data from API
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);
  }

  void _addExpenditure() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddExpenditureForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'EXPENDITURE',
          style: TextStyle(color: Colors.white, letterSpacing: 0.2),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // decorative white divider (80dp × 2dp)
          const SizedBox(height: 15),
          Center(child: Container(width: 80, height: 2, color: Colors.white)),
          const SizedBox(height: 20),

          // list with pull-to-refresh
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child:
                  _expenditures.isEmpty && !_loading
                      ? _buildEmptyState()
                      : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _expenditures.length,
                        itemBuilder: (_, i) {
                          final exp = _expenditures[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.attach_money),
                              title: Text(exp.name),
                              subtitle: Text('${exp.date} • ${exp.status}'),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ExpenditureDetailScreen(
                                          expenditure: exp,
                                        ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
            ),
          ),
        ],
      ),

      // centered bottom FAB
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        onPressed: _addExpenditure,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.info, size: 60, color: Colors.black54),
          SizedBox(height: 10),
          Text(
            'No expenditure available!',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
