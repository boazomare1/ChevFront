import 'package:chevenergies/models/stop.dart';
import 'package:chevenergies/shared utils/widgets.dart';
import 'package:chevenergies/models/routedata.dart';
import 'package:chevenergies/shared utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class CustomersScreen extends StatefulWidget {
  final String day;
  const CustomersScreen({super.key, required this.day});

  @override
  _CustomersScreenState createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<Stop> _stops = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStops();
  }

  Future<void> _loadStops() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // 1) fetch all routes for the day
      final routes = await Provider.of<AppState>(context, listen: false)
          .getRoutes(widget.day);
      // 2) flatten all stops across routes
      _stops = routes
          .expand<Stop>((r) => r.stops) // StopData is your model for each stop
          .toList();
    } catch (e) {
      setState(() {
        _error = 'Failed to load customers: $e';
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
      appBar: AppBar(
        title: Text('Customers for ${widget.day.capitalize()}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (!_isLoading && _error == null)
              Expanded(
                child: ListView.builder(
                  itemCount: _stops.length,
                  itemBuilder: (ctx, i) {
                    final stop = _stops[i];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: InkWell(
                        onTap: () {
                          // TODO: handle tap
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(Icons.person, size: 40),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stop.shop,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${stop.customer} • ${stop.townName}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Distance: — km', // placeholder
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        ),
                      ),
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
