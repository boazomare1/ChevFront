import 'package:chevenergies/shared utils/app_theme.dart';
import 'package:chevenergies/screens/current_stock.dart';
import 'package:chevenergies/services/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Salesperson {
  final String name;
  final String code;
  final String phone;
  final String region;
  final String vehicle;

  Salesperson({
    required this.name,
    required this.code,
    required this.phone,
    required this.region,
    required this.vehicle,
  });

  factory Salesperson.fromJson(Map<String, dynamic> json) {
    return Salesperson(
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      phone: json['phone'] ?? '',
      region: json['region'] ?? '',
      vehicle: json['vehicle'] ?? '',
    );
  }
}

class SalespeopleScreen extends StatefulWidget {
  const SalespeopleScreen({super.key});

  @override
  _SalespeopleScreenState createState() => _SalespeopleScreenState();
}

class _SalespeopleScreenState extends State<SalespeopleScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Salesperson> _allSalespeople = [];
  List<Salesperson> _filteredSalespeople = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSalespeople();
    _searchController.addListener(_filterSalespeople);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSalespeople() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final vehiclesData = await appState.listVehicles();

      _allSalespeople =
          vehiclesData.map((json) => Salesperson.fromJson(json)).toList();

      _filteredSalespeople = List.from(_allSalespeople);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load vehicles: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _filterSalespeople() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSalespeople = List.from(_allSalespeople);
      } else {
        _filteredSalespeople =
            _allSalespeople.where((salesperson) {
              return salesperson.name.toLowerCase().contains(query) ||
                  salesperson.code.toLowerCase().contains(query) ||
                  salesperson.phone.contains(query) ||
                  salesperson.vehicle.toLowerCase().contains(query);
            }).toList();
      }
    });
  }

  void _handleNextAction(Salesperson salesperson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => CurrentStockScreen(
              salespersonName: salesperson.name,
              salespersonCode: salesperson.code,
            ),
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
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/logo_round.png',
                                        height: 24,
                                        width: 24,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'SALESPEOPLE',
                                        style: AppTheme.headingLarge.copyWith(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${_allSalespeople.length} active salespeople',
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
                              _allSalespeople.length.toString(),
                              Icons.people,
                            ),
                            AppTheme.statItem(
                              'Active',
                              _allSalespeople.length.toString(),
                              Icons.check_circle,
                            ),
                            AppTheme.statItem(
                              'Regions',
                              '10',
                              Icons.location_on,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _searchController,
                      decoration: AppTheme.inputDecoration(
                        label: 'Search salesperson',
                        hintText:
                            'Search by name, ID, phone, or vehicle number',
                        prefixIcon: Icons.search,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Salespeople list
                  Expanded(
                    child:
                        _filteredSalespeople.isEmpty
                            ? AppTheme.emptyState(
                              icon: Icons.people_outline,
                              title: 'No Salespeople Found',
                              subtitle:
                                  _searchController.text.isEmpty
                                      ? 'No salespeople available'
                                      : 'No salespeople match your search',
                            )
                            : RefreshIndicator(
                              onRefresh: _loadSalespeople,
                              color: AppTheme.primaryColor,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: _filteredSalespeople.length,
                                itemBuilder: (context, index) {
                                  final salesperson =
                                      _filteredSalespeople[index];
                                  return _buildSalespersonCard(
                                    salesperson,
                                    index,
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
            // TODO: Navigate to add salesperson screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Add Salesperson feature coming soon!'),
                backgroundColor: AppTheme.primaryColor,
              ),
            );
          },
          icon: const Icon(Icons.person_add),
          label: const Text(
            'ADD SALESPERSON',
            style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSalespersonCard(Salesperson salesperson, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration.copyWith(
        color: index % 2 == 0 ? Colors.white : Colors.grey[50],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleNextAction(salesperson),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Salesperson avatar and number
                Column(
                  children: [
                    // Salesperson number
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          (index + 1).toString(),
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Salesperson truck
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.local_shipping,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                // Salesperson info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        salesperson.name,
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${salesperson.code}',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Vehicle: ${salesperson.vehicle}',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        salesperson.phone,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        salesperson.region,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // NEXT button
                ElevatedButton(
                  onPressed: () => _handleNextAction(salesperson),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(80, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'NEXT',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
