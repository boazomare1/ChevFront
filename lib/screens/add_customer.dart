import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chevenergies/services/app_state.dart';
import 'package:chevenergies/shared utils/widgets.dart';
import 'package:chevenergies/screens/add_shop.dart';
import 'package:flutter/services.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  bool loadingTerritories = true;
  final _formKey = GlobalKey<FormState>();
  final customerNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  String customerType = "Company";
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  String? selectedTerritory;
  List<String> territories = [];
  List<String> selectedPaymentMethods = [];
  bool loading = false;

  // Available payment methods
  final List<String> paymentMethods = ['Cash', 'Mpesa', 'Cheque', 'Invoice'];

  @override
  void initState() {
    super.initState();
    _loadTerritories();
  }

  Future<void> _loadTerritories() async {
    try {
      setState(() => loadingTerritories = true);
      final appState = Provider.of<AppState>(context, listen: false);
      final t = await appState.listTerritories();
      setState(() {
        territories = t;
        selectedTerritory = t.isNotEmpty ? t.first : null;
        loadingTerritories = false;
      });
    } catch (e) {
      setState(() => loadingTerritories = false);
      _showError("Failed to load territories: $e");
    }
  }

  Future<void> _submitCustomer() async {
    setState(() {
      _autoValidateMode = AutovalidateMode.onUserInteraction;
    });

    final isValid = _formKey.currentState!.validate();

    if (!isValid ||
        selectedTerritory == null ||
        selectedPaymentMethods.isEmpty) {
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
        builder:
            (_) => SuccessDialog(
              message:
                  "Customer '${customerNameController.text}' created successfully.",
              onClose: () {
                Navigator.pop(context);
              },
            ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => AddShopScreen(
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showPaymentMethodsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        List<String> tempSelected = List.from(selectedPaymentMethods);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Payment Methods'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      paymentMethods.map((method) {
                        return CheckboxListTile(
                          title: Text(method),
                          value: tempSelected.contains(method),
                          onChanged: (bool? value) {
                            setDialogState(() {
                              if (value == true) {
                                tempSelected.add(method);
                              } else {
                                tempSelected.remove(method);
                              }
                            });
                          },
                        );
                      }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedPaymentMethods = tempSelected;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Customer"),
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 14, 160, 19),
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autoValidateMode,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customer Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        StyledTextField(
                          label: "Customer Name *",
                          controller: customerNameController,
                          validator:
                              (value) =>
                                  value!.isEmpty ? 'Name is required' : null,
                          prefixIcon: const Icon(Icons.person),
                        ),
                        const SizedBox(height: 16),
                        StyledTextField(
                          label: "Phone Number *",
                          controller: phoneNumberController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (value) {
                            if (value!.isEmpty)
                              return 'Phone number is required';
                            if (!RegExp(
                              r'^07\d{8}$|^01\d{8}$',
                            ).hasMatch(value)) {
                              return 'Enter valid Kenyan phone number (07/01xxxxxxxx)';
                            }
                            return null;
                          },
                          prefixIcon: const Icon(Icons.phone),
                        ),
                        const SizedBox(height: 16),
                        loadingTerritories
                            ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : territories.isNotEmpty
                            ? StyledSelectField<String>(
                              label: "Territory *",
                              items: territories,
                              selected: selectedTerritory,
                              displayString: (s) => s,
                              onChanged:
                                  (val) =>
                                      setState(() => selectedTerritory = val),
                              validator:
                                  (value) =>
                                      value == null
                                          ? 'Territory is required'
                                          : null,
                              prefixIcon: const Icon(Icons.location_on),
                            )
                            : const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                'No territories available',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),

                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _showPaymentMethodsDialog,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Payment Methods *',
                              prefixIcon: const Icon(Icons.payment),
                              border: const OutlineInputBorder(),
                              errorText:
                                  selectedPaymentMethods.isEmpty &&
                                          _autoValidateMode ==
                                              AutovalidateMode.onUserInteraction
                                      ? 'Select at least one payment method'
                                      : null,
                            ),
                            child: Text(
                              selectedPaymentMethods.isEmpty
                                  ? 'Select payment methods'
                                  : selectedPaymentMethods.join(', '),
                              style: TextStyle(
                                color:
                                    selectedPaymentMethods.isEmpty
                                        ? Colors.grey
                                        : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _submitCustomer,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            "Create Customer",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  @override
  void dispose() {
    customerNameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }
}
