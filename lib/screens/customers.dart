import 'package:chevenergies/models/stop.dart';
import 'package:chevenergies/screens/add_customer.dart';
import 'package:chevenergies/screens/make_sale.dart';
import 'package:chevenergies/shared utils/extension.dart';
import 'package:chevenergies/shared%20utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
  final Map<String, String> _stopToRouteMap = {};
  String? _error;
  Position? _currentPosition;

  // NEW: Track completed stops locally
  final Set<String> _servedStopIds = {};

  @override
  void initState() {
    super.initState();
    _initLocationAndData();
  }

  Future<void> _initLocationAndData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _handlePermissions();
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      final routes = await Provider.of<AppState>(
        context,
        listen: false,
      ).getRoutes(widget.day);

      _stops = [];
      _stopToRouteMap.clear();

      for (final route in routes) {
        for (final stop in route.stops) {
          _stops.add(stop);
          _stopToRouteMap[stop.name] = route.routeId;
        }
      }

      // sort by idx
      _stops.sort((a, b) => a.idx.compareTo(b.idx));
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => ErrorDialog(message: 'Failed to load Customers'),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePermissions() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Location services are disabled');
      }
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      throw Exception('Location permissions are denied');
    }
  }

  void _handleServeStop(Stop stop) {
    final routeId = _stopToRouteMap[stop.name] ?? 'unknown';

    // Find the lowest unserved stop
    final nextStop = _stops.firstWhere(
      (s) => !_servedStopIds.contains(s.name),
      orElse: () => stop,
    );

    if (stop.name != nextStop.name) {
      _showOutOfOrderDialog(nextStop.shop);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => MakeSaleScreen(
              shopName: stop.shop,
              routeId: routeId,
              stopId: stop.name,
              day: widget.day,
              stopLat: stop.latitude,
              stopLng: stop.longitude,
              onComplete: () {
                setState(() {
                  _servedStopIds.add(stop.name);
                });
              },
            ),
      ),
    );
  }

  void _showOutOfOrderDialog(String correctCustomer) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Serve in Order'),
            content: Text('Please serve $correctCustomer first.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF228B22),
        elevation: 0,
        leading: IconButton(
          padding: const EdgeInsets.all(10),
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'CUSTOMERS TO SERVE ',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 6),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(20),
          child: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: 70,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.white),
              ),
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _initLocationAndData,
              color: Colors.red,
              child:
                  _error != null
                      ? Center(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                      : _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(color: Colors.red),
                      )
                      : _stops.isEmpty
                      ? const Center(
                        child: Text(
                          'No Customers to be served.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: _stops.length,
                        itemBuilder: (ctx, i) => _buildCustomerCard(_stops[i]),
                      ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddCustomerScreen()),
          );
        },
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCustomerCard(Stop stop) {
    const placeholderAsset = 'assets/gas-cylinder.png';
    String distanceLabel = '—';

    if (_currentPosition != null) {
      final km = haversineDistanceKm(
        lat1: _currentPosition!.latitude,
        lng1: _currentPosition!.longitude,
        lat2: stop.latitude,
        lng2: stop.longitude,
      );
      distanceLabel = km.toStringAsFixed(1);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(placeholderAsset, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  const Icon(Icons.circle, size: 6, color: Colors.blue),
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.black,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                  ),
                  Container(
                    width: 3,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stop.shop.toUpperCase()} (${distanceLabel} KM)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stop.townName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            stop.phone,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _handleServeStop(stop),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            minimumSize: const Size(64, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'NEXT',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
