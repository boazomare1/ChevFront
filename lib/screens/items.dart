// Items Screen
import 'package:chevenergies/models/item.dart';
import 'package:chevenergies/screens/invoice.dart';
import 'package:chevenergies/services/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemsScreen extends StatefulWidget {
  final String routeId;
  const ItemsScreen({super.key, required this.routeId});

  @override
  _ItemsScreenState createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  List<Item> _items = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      _items = await Provider.of<AppState>(context, listen: false).listItems(widget.routeId);
    } catch (e) {
      setState(() {
        _error = 'Failed to load items: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Items for ${widget.routeId}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isLoading) const CircularProgressIndicator(),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return ListTile(
                    title: Text(item.itemCode),
                    subtitle: Text('Qty: ${item.quantity}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InvoiceScreen(
                            routeId: widget.routeId,
                            item: item,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
