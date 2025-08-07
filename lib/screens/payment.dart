import 'dart:convert';
import 'dart:io';
import 'package:chevenergies/services/app_state.dart';
import 'package:chevenergies/shared%20utils/widgets.dart';
import 'package:chevenergies/shared utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  final String invoiceId;
  final double totalAmount;

  const PaymentScreen({
    super.key,
    required this.invoiceId,
    required this.totalAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMode = 'Cash';
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _transcodeCtrl = TextEditingController();
  final TextEditingController _referenceDateCtrl = TextEditingController();
  XFile? _evidenceImage;
  bool _loading = false;

  final List<String> availableModes = ['Cash', 'Mpesa', 'Cheque', 'Invoice'];

  Future<void> _submitPayment() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      showDialog(
        context: context,
        builder: (_) => const ErrorDialog(message: 'Enter a valid amount'),
      );
      return;
    }

    if (_selectedMode == 'Cheque') {
      if (_transcodeCtrl.text.isEmpty || _evidenceImage == null) {
        showDialog(
          context: context,
          builder:
              (_) =>
                  const ErrorDialog(message: 'Provide cheque number and image'),
        );
        return;
      }
    }

    setState(() => _loading = true);

    try {
      // Convert image to base64 if available
      String? evidencePhoto;
      if (_evidenceImage != null) {
        final bytes = await _evidenceImage!.readAsBytes();
        final base64Image = base64Encode(bytes);
        evidencePhoto = 'data:image/jpeg;base64,$base64Image';
      }

      // Get current date for reference_date if not provided
      String? referenceDate =
          _referenceDateCtrl.text.isNotEmpty
              ? _referenceDateCtrl.text
              : DateTime.now().toIso8601String().split('T')[0];

      // Debug logging
      print('Payment Mode: $_selectedMode');
      print('Transcode: ${_transcodeCtrl.text}');
      print('Reference Date: $referenceDate');
      print(
        'Evidence Photo: ${evidencePhoto != null ? 'Present' : 'Not provided'}',
      );

      await Provider.of<AppState>(context, listen: false).createPayment(
        widget.invoiceId,
        amount,
        _selectedMode,
        transcode:
            _selectedMode == 'Cheque' && _transcodeCtrl.text.isNotEmpty
                ? _transcodeCtrl.text
                : null,
        referenceDate: _selectedMode == 'Cheque' ? referenceDate : null,
        evidencePhoto: _selectedMode == 'Cheque' ? evidencePhoto : null,
      );

      if (mounted) {
        // Add a small delay to ensure the API response is fully processed
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          print('Showing payment success dialog');
          showDialog(
            context: context,
            barrierDismissible: false, // Prevent dismissing by tapping outside
            builder:
                (_) => SuccessDialog(
                  message:
                      'Payment successful!\n\nAmount: Ksh ${amount.toStringAsFixed(2)}\nMode: $_selectedMode\nInvoice: ${widget.invoiceId}\n\nPayment Entry: ACC-PAY-2025-00073',
                  onClose: () {
                    print('Payment success dialog closed');
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to previous screen
                  },
                ),
          );
        }
      }
    } catch (e) {
      print('Payment error caught in UI: $e');
      if (mounted) {
        String userFriendlyMessage = 'Payment failed. Please try again.';

        // Try to extract user-friendly message from the error
        if (e.toString().contains('Sales Partner') ||
            e.toString().contains('not found')) {
          userFriendlyMessage =
              'Payment failed: Customer information not found. Please contact support.';
        } else if (e.toString().contains('HTTP 400')) {
          userFriendlyMessage =
              'Payment failed: Invalid request. Please check your payment details.';
        } else if (e.toString().contains('HTTP 500')) {
          userFriendlyMessage =
              'Payment failed: Server error. Please try again later.';
        } else if (e.toString().contains('network')) {
          userFriendlyMessage =
              'Payment failed: Network error. Please check your connection.';
        } else {
          // Use the actual error message from the API if available
          userFriendlyMessage = e.toString().replaceAll('Exception: ', '');
        }

        showDialog(
          context: context,
          builder: (_) => ErrorDialog(message: userFriendlyMessage),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickEvidenceImage() async {
    final ImagePicker picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _evidenceImage = picked);
    }
  }

  @override
  void initState() {
    super.initState();
    _amountCtrl.text = widget.totalAmount.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              // Header section
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withValues(alpha: 0.8),
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
                            color: Colors.white.withValues(alpha: 0.2),
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
                                'PAYMENT',
                                style: AppTheme.headingLarge.copyWith(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                'Complete your payment',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Payment info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.receipt,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Invoice ID',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                                Text(
                                  widget.invoiceId,
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Total Amount',
                                style: AppTheme.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              Text(
                                'Ksh ${widget.totalAmount.toStringAsFixed(0)}',
                                style: AppTheme.headingMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Payment form
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    children: [
                      // Payment mode selection
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.cardDecoration,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.payment,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Payment Method',
                                  style: AppTheme.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.textLight),
                              ),
                              child: DropdownButton<String>(
                                value: _selectedMode,
                                hint: Text(
                                  'Select payment mode',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                isExpanded: true,
                                underline: const SizedBox(),
                                items:
                                    availableModes.map((mode) {
                                      return DropdownMenuItem(
                                        value: mode,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              margin: const EdgeInsets.only(
                                                right: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _getPaymentModeColor(
                                                  mode,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              mode,
                                              style: AppTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (val) {
                                  if (val != null)
                                    setState(() => _selectedMode = val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Amount field
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.cardDecoration,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.successColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.attach_money,
                                    color: AppTheme.successColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Payment Amount',
                                  style: AppTheme.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _amountCtrl,
                              readOnly: true,
                              keyboardType: TextInputType.number,
                              decoration: AppTheme.inputDecoration(
                                label: 'Amount (Ksh)',
                                prefixIcon: Icons.currency_exchange,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Cheque specific fields (only for cheque payments)
                      if (_selectedMode == 'Cheque') ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.cardDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.infoColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.credit_card,
                                      color: AppTheme.infoColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Cheque Details',
                                    style: AppTheme.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _transcodeCtrl,
                                decoration: AppTheme.inputDecoration(
                                  label: 'Cheque Number',
                                  prefixIcon: Icons.numbers,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _referenceDateCtrl,
                                decoration: AppTheme.inputDecoration(
                                  label: 'Reference Date (YYYY-MM-DD)',
                                  prefixIcon: Icons.calendar_today,
                                ),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    _referenceDateCtrl.text =
                                        date.toIso8601String().split('T')[0];
                                  }
                                },
                                readOnly: true,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: _pickEvidenceImage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.camera_alt, size: 20),
                                  label: const Text(
                                    'Capture Cheque Image',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              if (_evidenceImage != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.textLight,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cheque Image:',
                                        style: AppTheme.bodySmall.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(_evidenceImage!.path),
                                          height: 120,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Submit button
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.successColor.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _submitPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successColor,
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
                              const Icon(Icons.check_circle, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'COMPLETE PAYMENT',
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
            ],
          ),
          if (_loading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
            ),
        ],
      ),
    );
  }

  Color _getPaymentModeColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'cash':
        return AppTheme.successColor;
      case 'mpesa':
        return AppTheme.primaryColor;
      case 'cheque':
        return AppTheme.infoColor;
      case 'invoice':
        return AppTheme.warningColor;
      default:
        return AppTheme.textSecondary;
    }
  }
}
