import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chevenergies/services/app_state.dart';
import 'package:chevenergies/shared utils/widgets.dart';
import 'package:chevenergies/shared utils/app_theme.dart';
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
        phoneNumber: phoneNumberController.text,
        paymentMethods: selectedPaymentMethods,
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
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.grey[50]!],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.payment,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Payment Methods',
                                  style: AppTheme.headingMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Select preferred payment options',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content section
                    Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children:
                                paymentMethods.map((method) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.textLight.withOpacity(
                                          0.3,
                                        ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: CheckboxListTile(
                                      title: Text(
                                        method,
                                        style: AppTheme.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      value: tempSelected.contains(method),
                                      activeColor: AppTheme.primaryColor,
                                      checkColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                      onChanged: (bool? value) {
                                        setDialogState(() {
                                          if (value == true) {
                                            tempSelected.add(method);
                                          } else {
                                            tempSelected.remove(method);
                                          }
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ),

                    // Action buttons
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.textSecondary,
                                side: BorderSide(color: AppTheme.textSecondary),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'CANCEL',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedPaymentMethods = tempSelected;
                                });
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check, size: 18),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'CONFIRM',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body:
          loading
              ? Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
              : Column(
                children: [
                  // Header section
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                    child: Column(
                      children: [
                        // Back button and title row
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ADD CUSTOMER',
                                    style: AppTheme.headingLarge.copyWith(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    'Create new customer profile',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Form content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: _autoValidateMode,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section header
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.person_add,
                                        color: AppTheme.primaryColor,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Customer Details',
                                      style: AppTheme.headingMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Customer Name
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: StyledTextField(
                                  label: "Customer Name *",
                                  controller: customerNameController,
                                  validator:
                                      (value) =>
                                          value!.isEmpty
                                              ? 'Name is required'
                                              : null,
                                  prefixIcon: const Icon(Icons.person),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Phone Number
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: StyledTextField(
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
                              ),
                              const SizedBox(height: 16),

                              // Territory
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child:
                                    loadingTerritories
                                        ? const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                        )
                                        : territories.isNotEmpty
                                        ? StyledSelectField<String>(
                                          label: "Territory *",
                                          items: territories,
                                          selected: selectedTerritory,
                                          displayString: (s) => s,
                                          onChanged:
                                              (val) => setState(
                                                () => selectedTerritory = val,
                                              ),
                                          validator:
                                              (value) =>
                                                  value == null
                                                      ? 'Territory is required'
                                                      : null,
                                          prefixIcon: const Icon(
                                            Icons.location_on,
                                          ),
                                        )
                                        : Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                color: AppTheme.errorColor,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'No territories available',
                                                style: TextStyle(
                                                  color: AppTheme.errorColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                              ),

                              const SizedBox(height: 16),

                              // Payment Methods
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: _showPaymentMethodsDialog,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Payment Methods *',
                                      prefixIcon: const Icon(Icons.payment),
                                      border: const OutlineInputBorder(),
                                      errorText:
                                          selectedPaymentMethods.isEmpty &&
                                                  _autoValidateMode ==
                                                      AutovalidateMode
                                                          .onUserInteraction
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
                              ),
                              const SizedBox(height: 32),

                              // Submit Button
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _submitCustomer,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size.fromHeight(56),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.person_add, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        "CREATE CUSTOMER",
                                        style: AppTheme.bodyLarge.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
