import 'package:chevenergies/models/stop.dart';
import 'package:chevenergies/shared utils/extension.dart';
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
  String? _error;
  Position? _currentPosition;

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
      // permissions + position
      await _handlePermissions();
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      // load stops
      final routes = await Provider.of<AppState>(
        context,
        listen: false,
      ).getRoutes(widget.day);
      _stops = routes.expand((r) => r.stops).toList();
    } catch (e) {
      _error = 'Failed to load customers: $e';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // no AppBar
      body: Column(
        children: [
          // Green top stripe
          Container(height: 60, color: const Color(0xFF228B22)),
          const SizedBox(height: 10),

          // Title + underline
          Center(
            child: Column(
              children: [
                const Text(
                  'CUSTOMERS',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(width: 70, height: 2, color: Colors.black),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Content
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
                      : Stack(
                        children: [
                          ListView.builder(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: _stops.length,
                            itemBuilder:
                                (ctx, i) => _buildCustomerCard(_stops[i]),
                          ),
                          if (_isLoading)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                        ],
                      ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: navigate to Add Customer screen
        },
        backgroundColor: const Color(0xFF228B22),
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCustomerCard(Stop stop) {
    const placeholderAsset = 'assets/static_shop.png';

    // compute distance
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
              // fixed-size image slot
              SizedBox(
                width: 60,
                height: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(placeholderAsset, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),

              // indicator rail
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

              // main info + phone/button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // shop + distance uppercase & bold
                    Text(
                      '${stop.shop.toUpperCase()} (${distanceLabel} KM)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // town only uppercase
                    Text(
                      stop.townName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // phone + Next button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            stop.phone,
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
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
