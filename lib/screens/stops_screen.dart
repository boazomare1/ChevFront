import 'package:chevenergies/models/routedata.dart';
import 'package:chevenergies/shared%20utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class StopsScreen extends StatefulWidget {
  final String day;
  const StopsScreen({super.key, required this.day});

  @override
  _StopsScreenState createState() => _StopsScreenState();
}

class _StopsScreenState extends State<StopsScreen> {
  List<RouteData> _routes = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRoutes();
  }

  Future<void> _fetchRoutes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      _routes = await Provider.of<AppState>(context, listen: false).getRoutes(widget.day);
    } catch (e) {
      setState(() {
        _error = 'Failed to load routes: $e';
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
      appBar: AppBar(title: Text('Stops for ${widget.day.capitalize()}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isLoading) const CircularProgressIndicator(),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            Expanded(
              child: ListView.builder(
                itemCount: _routes.length,
                itemBuilder: (context, index) {
                  final route = _routes[index];
                  return ExpansionTile(
                    title: Text('Route: ${route.routeId}'),
                    subtitle: Text('Warehouse: ${route.warehouseName}'),
                    children: route.stops.map((stop) {
                      return ListTile(
                        title: Text(stop.shop),
                        subtitle: Text('${stop.customer} - ${stop.townName}'),
                        trailing: const Icon(Icons.location_on),
                        onTap: () {
                          // Navigate to ItemsScreen or show stop details
                          Navigator.pushNamed(context, '/items', arguments: route.routeId);
                        },
                      );
                    }).toList(),
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