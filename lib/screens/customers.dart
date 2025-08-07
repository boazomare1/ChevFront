import 'package:chevenergies/models/stop.dart';
import 'package:chevenergies/screens/add_customer.dart';
import 'package:chevenergies/screens/make_sale.dart';
import 'package:chevenergies/shared utils/extension.dart';
import 'package:chevenergies/shared%20utils/widgets.dart';
import 'package:chevenergies/shared utils/app_theme.dart';
import 'package:chevenergies/widgets/customer_logo.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class CustomersScreen extends StatefulWidget {
  final String? day; // Make day optional
  const CustomersScreen({super.key, this.day});

  @override
  _CustomersScreenState createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  List<Stop> _stops = [];
  bool _isLoading = false;
  final Map<String, String> _stopToRouteMap = {};
  String? _error;
  Position? _currentPosition;

  // NEW: Track completed stops locally
  final Set<String> _servedStopIds = {};
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initLocationAndData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when screen is focused (only after initial load)
    if (_hasInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _refreshOnFocus();
        }
      });
    }
  }

  void _refreshOnFocus() {
    // Refresh data when screen comes into focus
    if (!_isLoading) {
      _initLocationAndData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _hasInitialized) {
      // Refresh data when app comes back to foreground
      _initLocationAndData();
    }
  }

  @override
  bool get wantKeepAlive => false; // Don't keep alive, always refresh

  String _getDayFromDate(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'MONDAY';
      case DateTime.tuesday:
        return 'TUESDAY';
      case DateTime.wednesday:
        return 'WEDNESDAY';
      case DateTime.thursday:
        return 'THURSDAY';
      case DateTime.friday:
        return 'FRIDAY';
      case DateTime.saturday:
        return 'SATURDAY';
      case DateTime.sunday:
        return 'SUNDAY';
      default:
        return 'MONDAY';
    }
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

      // Determine today's route based on current weekday
      final today = _getDayFromDate(DateTime.now());

      final routes = await Provider.of<AppState>(
        context,
        listen: false,
      ).getRoutes(
        widget.day ?? today, // Use today's route if no specific day provided
      );

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

      // Refresh served stops data
      await _refreshServedStops();
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => ErrorDialog(message: 'Failed to load Customers'),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _hasInitialized = true;
      });
    }
  }

  Future<void> _refreshServedStops() async {
    try {
      // Clear current served stops to get fresh data
      _servedStopIds.clear();

      // Get fresh data from the server or local storage
      // This ensures we have the latest served status
      final state = Provider.of<AppState>(context, listen: false);

      // TODO: Add API call here to get served stops if available
      // For now, we'll just clear and let the user mark them again
      // This ensures the list is always fresh when returning to the screen

      setState(() {
        // Trigger rebuild to reflect changes
      });
    } catch (e) {
      // Silently handle refresh errors
      print('Error refreshing served stops: $e');
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
              day: widget.day ?? _getDayFromDate(DateTime.now()),
              stopLat: stop.latitude,
              stopLng: stop.longitude,
              logoUrl: stop.logo,
              onComplete: () {
                setState(() {
                  _servedStopIds.add(stop.name);
                });
                // Refresh data after completing a sale
                _refreshOnFocus();
              },
            ),
      ),
    ).then((_) {
      // Refresh when returning from make sale screen
      if (mounted) {
        _refreshOnFocus();
      }
    });
  }

  void _showOutOfOrderDialog(String correctCustomer) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                Icon(Icons.warning, color: AppTheme.warningColor),
                const SizedBox(width: 8),
                const Text('Serve in Order'),
              ],
            ),
            content: Text('Please serve $correctCustomer first.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              )
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppTheme.errorColor,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : _stops.isEmpty
              ? AppTheme.emptyState(
                icon: Icons.people_outline,
                title: 'No Customers Available',
                subtitle:
                    widget.day != null
                        ? 'No customers to serve for ${widget.day}'
                        : 'No customers to serve today',
              )
              : Column(
                children: [
                  // Header section with stats and back button
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
                                    '${(widget.day ?? 'TODAY').toUpperCase()} ROUTE',
                                    style: AppTheme.headingLarge.copyWith(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    '${_stops.length} customers to serve',
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
                              'Total',
                              _stops.length.toString(),
                              Icons.people,
                            ),
                            AppTheme.statItem(
                              'Served',
                              _servedStopIds.length.toString(),
                              Icons.check_circle,
                            ),
                            AppTheme.statItem(
                              'Pending',
                              (_stops.length - _servedStopIds.length)
                                  .toString(),
                              Icons.schedule,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Customer list
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _initLocationAndData,
                      color: AppTheme.primaryColor,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _stops.length,
                        itemBuilder: (context, index) {
                          final stop = _stops[index];
                          final isServed = _servedStopIds.contains(stop.name);

                          // Find the first unserved customer
                          final firstUnservedIndex = _stops.indexWhere(
                            (s) => !_servedStopIds.contains(s.name),
                          );
                          final isFirstUnserved = index == firstUnservedIndex;

                          return _buildCustomerCard(
                            stop,
                            isServed,
                            index + 1,
                            isFirstUnserved,
                          );
                        },
                      ),
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
            ).then((_) {
              // Refresh when returning from add customer screen
              if (mounted) {
                _refreshOnFocus();
              }
            });
          },
          icon: const Icon(Icons.add),
          label: const Text(
            'ADD CUSTOMER',
            style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(
    Stop stop,
    bool isServed,
    int index,
    bool isFirstUnserved,
  ) {
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isServed ? null : () => _handleServeStop(stop),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Stop number and image
                Column(
                  children: [
                    // Stop number
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            isServed
                                ? AppTheme.successColor.withOpacity(0.1)
                                : AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          index.toString(),
                          style: TextStyle(
                            color:
                                isServed
                                    ? AppTheme.successColor
                                    : AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Customer logo
                    CustomerLogo(
                      logoUrl: stop.logo,
                      width: 60,
                      height: 60,
                      placeholderAsset: 'assets/gas-cylinder.png',
                      shopName: stop.shop,
                      shopLocation: '${stop.townName}, ${stop.countyName}',
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                // Customer info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${stop.shop.toUpperCase()} (${distanceLabel} KM)',
                        style: AppTheme.bodyLarge.copyWith(
                          decoration:
                              isServed ? TextDecoration.lineThrough : null,
                          color:
                              isServed
                                  ? AppTheme.textSecondary
                                  : AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stop.townName.toUpperCase(),
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        stop.phone,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Action button - only show for first unserved customer
                if (isFirstUnserved && !isServed)
                  ElevatedButton(
                    onPressed: () => _handleServeStop(stop),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(64, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'NEXT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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
}
