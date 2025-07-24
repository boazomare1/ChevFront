import 'package:chevenergies/models/item.dart';
import 'package:chevenergies/services/app_state.dart';
import 'package:chevenergies/shared%20utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

class MakeSaleScreen extends StatefulWidget {
  final String shopName;
  final String routeId;
  final String stopId;
  final String day;

  const MakeSaleScreen({
    super.key,
    required this.shopName,
    required this.routeId,
    required this.stopId,
    required this.day,
  });

  @override
  State<MakeSaleScreen> createState() => _MakeSaleScreenState();
}

class _MakeSaleScreenState extends State<MakeSaleScreen> {
  List<Map<String, dynamic>> saleItems = [];
  Position? _currentPosition;
  String? _notAttendingReason;

  double get totalAmount => saleItems.fold(0.0, (sum, itm) {
    final price = itm['price'] as double;
    final qty = itm['qty'] as int;
    final discount = itm['discount'] as double; // 0–100
    final net = price * qty * (1 - discount / 100);
    return sum + net;
  });

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    } catch (_) {}
  }

  Future<void> showAddProductDialog() async {
    final items = await Provider.of<AppState>(
      context,
      listen: false,
    ).listItems(widget.routeId);

    Item? selected;
    final searchCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final discCtrl = TextEditingController(text: '0');
    bool applyDisc = false;

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Add Product'),
            content: StatefulBuilder(
              builder: (ctx, setInner) {
                // maintain a filtered list
                List<Item> filtered =
                    items.where((i) {
                      final name = i.itemName ?? '';
                      final query = searchCtrl.text;
                      return name.toLowerCase().contains(query.toLowerCase());
                    }).toList();

                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 2) Filtered dropdown
                        StyledSelectField<Item>(
                          label: 'Choose Product',
                          items: items,
                          selected: selected,
                          onChanged: (item) => setInner(() => selected = item),
                          displayString:
                              (item) =>
                                  '${item.itemName} (Ksh ${item.sellingPrice})',
                        ),

                        const SizedBox(height: 12),

                        // 3) Quantity
                        StyledTextField(
                          label: 'Quantity',
                          controller: qtyCtrl,
                          keyboardType: TextInputType.number,
                        ),

                        // 4) Discount checkbox + field
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Apply discount?'),
                          value: applyDisc,
                          onChanged:
                              (v) => setInner(() => applyDisc = v ?? false),
                        ),
                        if (applyDisc)
                          StyledTextField(
                            label: 'Discount (%)',
                            controller: discCtrl,
                            keyboardType: TextInputType.number,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selected != null) {
                    final q = int.tryParse(qtyCtrl.text) ?? 1;
                    final d = double.tryParse(discCtrl.text) ?? 0.0;
                    setState(() {
                      saleItems.add({
                        'itemCode': selected!.itemCode,
                        'name': selected!.itemName,
                        'price': selected!.sellingPrice,
                        'qty': q,
                        'discount': applyDisc ? d.clamp(0, 100) : 0.0,
                      });
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('ADD'),
              ),
            ],
          ),
    );
  }

  Future<void> _askNotAttending() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Reason for not serving'),
            content: TextField(
              controller: ctrl,
              decoration: const InputDecoration(hintText: 'Enter reason'),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() => _notAttendingReason = ctrl.text);
                  Navigator.pop(context);
                },
                child: const Text('SUBMIT'),
              ),
            ],
          ),
    );
  }

  void _submitInvoice() async {
    final state = Provider.of<AppState>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
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
              amount: (e['price'] as double) * (e['qty'] as int),
            );
          }).toList();

      final result = await state.raiseInvoice(
        widget.routeId,
        widget.stopId,
        widget.day,
        items,
      );

      Navigator.pop(context); // close loader

      showDialog(
        context: context,
        builder:
            (_) => SuccessDialog(
              message: 'Invoice raised successfully!',
              onClose: () {
                // Optional: clear saleItems, move to next screen, etc.
              },
            ),
      );
    } catch (e) {
      Navigator.pop(context); // close loader

      showDialog(
        context: context,
        builder:
            (_) => ErrorDialog(
              message: 'Failed to raise invoice:\n${e.toString()}',
            ),
      );
    }
  }

  Widget _buildHeader() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(height: 60, color: const Color(0xFF228B22)),
      const SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          'MAKE SALE – ${widget.shopName.toUpperCase()}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.green,
          ),
        ),
      ),
      const SizedBox(height: 4),
      const Padding(
        padding: EdgeInsets.only(left: 10),
        child: SizedBox(
          width: 70,
          height: 2,
          child: DecoratedBox(decoration: BoxDecoration(color: Colors.black)),
        ),
      ),
    ],
  );

  Widget _buildSaleItemsCard() => Card(
    elevation: 3,
    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          if (saleItems.isNotEmpty) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sale Items',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(child: Text('Price', textAlign: TextAlign.center)),
                Expanded(child: Text('Qty', textAlign: TextAlign.center)),
                Expanded(child: Text('Disc', textAlign: TextAlign.center)),
                Expanded(child: Text('Total', textAlign: TextAlign.center)),
              ],
            ),
          ],
          const SizedBox(height: 8),
          if (saleItems.isEmpty)
            Column(
              children: const [
                Icon(Icons.info_outline, size: 40, color: Colors.blueGrey),
                SizedBox(height: 5),
                Text(
                  "No sale item available!",
                  style: TextStyle(color: Colors.blueGrey),
                ),
              ],
            )
          else
            ...saleItems.map((itm) {
              final price = itm['price'] as double;
              final qty = itm['qty'] as int;
              final disc = itm['discount'] as double;
              final total = price * qty * (1 - disc / 100);
              return Row(
                children: [
                  Expanded(flex: 2, child: Text(itm['name'])),
                  Expanded(child: Text('$price', textAlign: TextAlign.center)),
                  Expanded(child: Text('$qty', textAlign: TextAlign.center)),
                  Expanded(
                    child: Text(
                      '${disc.toStringAsFixed(0)}%',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      total.toStringAsFixed(2),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }).toList(),
        ],
      ),
    ),
  );

  Widget _buildPaymentStatusCard() {
    if (saleItems.isEmpty) return const SizedBox.shrink();
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Status',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Goods Worth"),
                Text(
                  "Ksh ${totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [Text("Total Payment"), Text("Ksh 0.00")],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder:
            (_, __) => [SliverToBoxAdapter(child: _buildHeader())],
        body: ListView(
          padding: const EdgeInsets.only(top: 10, bottom: 80),
          children: [
            _buildSaleItemsCard(),
            _buildPaymentStatusCard(),
            if (saleItems.isEmpty) ...[
              Card(
                color: Colors.red.shade50, // subtle red background
                elevation: 4, // raised effect
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _askNotAttending,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: const [
                        Expanded(
                          child: Text(
                            'Not attending? Tap to provide reason',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(Icons.report_problem, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              ),
            ] else
              const SizedBox(height: 10),
            if (_notAttendingReason != null) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Reason: $_notAttendingReason'),
              ),
            ],
            if (saleItems.isNotEmpty) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitInvoice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'PROCEED TO PAYMENT',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddProductDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
