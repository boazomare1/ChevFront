import 'package:chevenergies/models/item.dart';
import 'package:chevenergies/screens/payment.dart';
import 'package:chevenergies/services/app_state.dart';
import 'package:chevenergies/shared%20utils/extension.dart';
import 'package:chevenergies/shared%20utils/widgets.dart';
import 'package:chevenergies/shared utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class MakeSaleScreen extends StatefulWidget {
  final String shopName;
  final String routeId;
  final String stopId;
  final String day;
  final double stopLat;
  final double stopLng;
  final VoidCallback? onComplete;

  const MakeSaleScreen({
    super.key,
    required this.shopName,
    required this.routeId,
    required this.stopId,
    required this.day,
    required this.stopLat,
    required this.stopLng,
    required this.onComplete,
  });

  @override
  State<MakeSaleScreen> createState() => _MakeSaleScreenState();
}

class _MakeSaleScreenState extends State<MakeSaleScreen> {
  late double _distanceMeters;
  bool _inRange = false;
  List<Map<String, dynamic>> saleItems = [];
  Position? _currentPosition;
  String? _notAttendingReason;

  double get totalAmount => saleItems.fold(0.0, (sum, itm) {
    final price = itm['price'] as double;
    final qty = itm['qty'] as int;
    final discount = itm['discount'] as double; // Fixed amount in Ksh
    final net = (price - discount) * qty; // Subtract discount per item
    return sum + net;
  });

  final List<String> ticketReasons = [
    'Shop closed',
    'Stocked',
    'Price disputes',
    'Lack of cash',
    'Product disputes',
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _ensureInRange() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      final km = haversineDistanceKm(
        lat1: _currentPosition!.latitude,
        lng1: _currentPosition!.longitude,
        lat2: widget.stopLat,
        lng2: widget.stopLng,
      );
      final meters = km * 1000;
      if (meters > 500) {
        await showDialog(
          context: context,
          builder:
              (_) => ErrorDialog(message: 'Please Move closer to the Shop'),
        );
        return false;
      }
      return true;
    } catch (_) {
      // Could not get location
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Location Error'),
              content: const Text('Unable to determine your location.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return false;
    }
  }

  Future<void> showAddProductDialog() async {
    if (!await _ensureInRange()) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
    );

    try {
      final items = await Provider.of<AppState>(
        context,
        listen: false,
      ).listItems(widget.routeId);

      Navigator.pop(context); // Close loader

      Item? selected;
      final searchCtrl = TextEditingController();
      final qtyCtrl = TextEditingController(text: '1');
      final discCtrl = TextEditingController(text: '0');
      bool applyDisc = false;

      await showDialog(
        context: context,
        builder:
            (_) => Dialog(
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
                              Icons.add_shopping_cart,
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
                                  'Add Product',
                                  style: AppTheme.headingMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Select product and quantity',
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
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: StatefulBuilder(
                        builder: (ctx, setInner) {
                          List<Item> filtered =
                              items.where((i) {
                                final name = i.itemName ?? '';
                                final query = searchCtrl.text;
                                return name.toLowerCase().contains(
                                  query.toLowerCase(),
                                );
                              }).toList();

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Product selection
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.textLight.withOpacity(0.3),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: StyledSelectField<Item>(
                                  label: 'Choose Product',
                                  items: items,
                                  selected: selected,
                                  onChanged:
                                      (item) => setInner(() => selected = item),
                                  displayString:
                                      (item) =>
                                          '${item.itemName} (Ksh ${item.sellingPrice})',
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Quantity input
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.textLight.withOpacity(0.3),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: StyledTextField(
                                  label: 'Quantity',
                                  controller: qtyCtrl,
                                  keyboardType: TextInputType.number,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Discount section
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.2,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    CheckboxListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                      title: Text(
                                        'Apply discount?',
                                        style: AppTheme.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      value: applyDisc,
                                      onChanged:
                                          (v) => setInner(
                                            () => applyDisc = v ?? false,
                                          ),
                                      activeColor: AppTheme.primaryColor,
                                      checkColor: Colors.white,
                                    ),
                                    if (applyDisc) ...[
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          0,
                                          16,
                                          16,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: AppTheme.primaryColor
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          child: StyledTextField(
                                            label: 'Discount Amount (Ksh)',
                                            controller: discCtrl,
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
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
                                if (selected != null) {
                                  final q = int.tryParse(qtyCtrl.text) ?? 1;
                                  final d =
                                      double.tryParse(discCtrl.text) ?? 0.0;
                                  setState(() {
                                    saleItems.add({
                                      'itemCode': selected!.itemCode,
                                      'name': selected!.itemName,
                                      'price': selected!.sellingPrice,
                                      'qty': q,
                                      'discount':
                                          applyDisc
                                              ? d.clamp(
                                                0,
                                                selected!.sellingPrice as num,
                                              )
                                              : 0.0,
                                    });
                                  });
                                  Navigator.pop(context);
                                }
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
                                  const Icon(Icons.add, size: 18),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'ADD PRODUCT',
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
            ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loader
      showDialog(
        context: context,
        builder:
            (_) => ErrorDialog(
              message: 'Failed to load products:\n${e.toString()}',
            ),
      );
    }
  }

  Future<void> _askNotAttending() async {
    if (!await _ensureInRange()) return;
    String? selectedReason;

    await showDialog(
      context: context,
      builder:
          (_) => Dialog(
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
                    color: AppTheme.warningColor.withOpacity(0.2),
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
                          AppTheme.warningColor,
                          AppTheme.warningColor.withOpacity(0.8),
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
                            Icons.report_problem,
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
                                'Reason for Not Serving',
                                style: AppTheme.headingMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Please select a reason',
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
                        child: StatefulBuilder(
                          builder: (ctx, setInnerState) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children:
                                  ticketReasons.map((reason) {
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
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: RadioListTile<String>(
                                        title: Text(
                                          reason,
                                          style: AppTheme.bodyMedium.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        value: reason,
                                        groupValue: selectedReason,
                                        activeColor: AppTheme.warningColor,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                        onChanged: (val) {
                                          setInnerState(() {
                                            selectedReason = val!;
                                          });
                                        },
                                      ),
                                    );
                                  }).toList(),
                            );
                          },
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
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
                            onPressed: () async {
                              if (selectedReason == null) return;

                              Navigator.pop(context); // Close dialog

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder:
                                    (_) => const Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppTheme.primaryColor,
                                            ),
                                      ),
                                    ),
                              );

                              try {
                                final state = Provider.of<AppState>(
                                  context,
                                  listen: false,
                                );

                                await state.raiseTicket(
                                  widget.routeId,
                                  widget.stopId,
                                  widget.day,
                                  selectedReason!,
                                );

                                Navigator.pop(context); // Close loader

                                // Show success and wait for dialog to close
                                await showDialog(
                                  context: context,
                                  builder:
                                      (_) => SuccessDialog(
                                        message: 'Ticket raised successfully!',
                                        onClose: () {
                                          Navigator.pop(
                                            context,
                                          ); // Close dialog
                                          widget.onComplete
                                              ?.call(); // ✅ Notify parent
                                        },
                                      ),
                                );
                              } catch (e) {
                                Navigator.pop(context); // Close loader

                                showDialog(
                                  context: context,
                                  builder:
                                      (_) => ErrorDialog(
                                        message:
                                            'Failed to raise ticket:\n${e.toString()}',
                                      ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.warningColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.send, size: 18),
                                const SizedBox(width: 8),
                                const Text(
                                  'SUBMIT',
                                  style: TextStyle(fontWeight: FontWeight.w600),
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
          ),
    );
  }

  void _submitInvoice() async {
    if (!await _ensureInRange()) return;
    final state = Provider.of<AppState>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
    );

    try {
      final items =
          saleItems.map((e) {
            return Item(
              itemCode: e['itemCode'],
              itemName: e['name'],
              description: '',
              quantity: (e['qty'] as int).toDouble(),
              warehouse: '',
              sellingPrice: e['price'] as double,
              amount:
                  ((e['price'] as double) - e['discount']) *
                  (e['qty'] as int), // Adjust for fixed discount
            );
          }).toList();

      final result = await state.raiseInvoice(
        widget.routeId,
        widget.stopId,
        widget.day,
        items,
      );

      Navigator.pop(context); // Close loader

      // Show success and wait for dialog to close
      await showDialog(
        context: context,
        builder:
            (_) => SuccessDialog(
              message: 'Invoice raised successfully!',
              onClose: () {
                Navigator.pop(context); // Close dialog
                widget.onComplete?.call(); // ✅ Notify parent
              },
            ),
      );

      // Now navigate to payment screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => PaymentScreen(
                invoiceId: result['invoice_id'],
                totalAmount: totalAmount,
              ),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loader

      showDialog(
        context: context,
        builder:
            (_) => ErrorDialog(
              message: 'Failed to raise invoice:\n${e.toString()}',
            ),
      );
    }
  }

  Widget _buildSaleItemsCard() => Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: AppTheme.cardDecoration,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shopping_cart,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Sale Items',
                style: AppTheme.headingMedium.copyWith(
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (saleItems.isEmpty)
            AppTheme.emptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'No Items Added',
              subtitle: 'Tap the + button to add products to your sale',
            )
          else ...[
            // Header row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Product',
                      style: AppTheme.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Price',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Qty',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Total',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Items list
            ...saleItems.map((itm) {
              final price = itm['price'] as double;
              final qty = itm['qty'] as int;
              final disc = itm['discount'] as double;
              final total = (price - disc) * qty; // Fixed discount calculation
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.textLight.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            itm['name'],
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (disc > 0)
                            Text(
                              'Discount: Ksh ${disc.toStringAsFixed(2)}',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Ksh ${price.toStringAsFixed(0)}',
                        textAlign: TextAlign.center,
                        style: AppTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '$qty',
                        textAlign: TextAlign.center,
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Ksh ${total.toStringAsFixed(0)}',
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    ),
  );

  Widget _buildPaymentStatusCard() {
    if (saleItems.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.payment,
                    color: AppTheme.successColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Payment Summary',
                  style: AppTheme.headingMedium.copyWith(
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Amount", style: AppTheme.bodyMedium),
                      Text(
                        "Ksh ${totalAmount.toStringAsFixed(2)}",
                        style: AppTheme.headingMedium.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Payment Status", style: AppTheme.bodyMedium),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.warningColor),
                        ),
                        child: Text(
                          'PENDING',
                          style: TextStyle(
                            color: AppTheme.warningColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
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
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MAKE SALE',
                            style: AppTheme.headingLarge.copyWith(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            widget.shopName.toUpperCase(),
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AppTheme.statItem(
                      'Items',
                      saleItems.length.toString(),
                      Icons.shopping_cart,
                    ),
                    AppTheme.statItem(
                      'Total',
                      'Ksh ${totalAmount.toStringAsFixed(0)}',
                      Icons.payment,
                    ),
                    AppTheme.statItem(
                      'Status',
                      saleItems.isEmpty ? 'Empty' : 'Ready',
                      Icons.check_circle,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                140,
              ), // Increased bottom padding for FAB
              children: [
                _buildSaleItemsCard(),
                _buildPaymentStatusCard(),

                // Not attending section
                if (saleItems.isEmpty) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.errorColor.withOpacity(0.3),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _askNotAttending,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.errorColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.report_problem,
                                  color: AppTheme.errorColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Not Attending?',
                                      style: AppTheme.bodyLarge.copyWith(
                                        color: AppTheme.errorColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Tap to provide a reason',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.errorColor.withOpacity(
                                          0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: AppTheme.errorColor,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitInvoice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.payment, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'PROCEED TO PAYMENT',
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ), // Extra spacing after payment button
                ],
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          onPressed: showAddProductDialog,
          icon: const Icon(Icons.add),
          label: const Text(
            'ADD PRODUCT',
            style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }
}
