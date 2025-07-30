import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chevenergies/services/app_state.dart';
import 'package:chevenergies/shared utils/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:chevenergies/screens/add_shop.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final customerNameController = TextEditingController();
  String customerType = "Company";
  String? selectedTerritory;
  List<String> territories = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadTerritories();
  }

  Future<void> _loadTerritories() async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final t = await appState.listTerritories();
      setState(() {
        territories = t;
        selectedTerritory = t.isNotEmpty ? t.first : null;
      });
    } catch (e) {
      _showError("Failed to load territories: $e");
    }
  }

  Future<void> _submitCustomer() async {
    if (!_formKey.currentState!.validate() || selectedTerritory == null) {
      _showError("Please fill all required fields.");
      return;
    }

    setState(() => loading = true);
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final response = await appState.createCustomer(
        name: customerNameController.text,
        type: customerType,
        territory: selectedTerritory!,
      );
      final customerId = response['customer_id'] as String;

      setState(() => loading = false);
      await showDialog(
        context: context,
        builder: (_) => SuccessDialog(
          message:
              "Customer '${customerNameController.text}' created successfully.",
          onClose: () {
            Navigator.pop(context); // close success dialog
          },
        ),
      );

      // Now navigate to AddShopScreen, passing customerId & name
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddShopScreen(
            customerId: customerId,
            customerName: customerNameController.text,
          ),
        ),
      );
    } catch (e) {
      setState(() => loading = false);
      _showError("Failed to create customer: $e");
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => ErrorDialog(message: msg),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Customer")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    StyledTextField(
                      label: "Customer Name",
                      controller: customerNameController,
                    ),
                    const SizedBox(height: 8),
                    StyledSelectField<String>(
                      label: "Territory",
                      items: territories,
                      selected: selectedTerritory,
                      displayString: (s) => s,
                      onChanged: (val) =>
                          setState(() => selectedTerritory = val),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitCustomer,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text("Create Customer"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
