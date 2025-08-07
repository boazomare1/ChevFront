import 'package:flutter/material.dart';
import 'package:chevenergies/shared utils/app_theme.dart';
import 'package:chevenergies/services/app_state.dart';
import 'package:chevenergies/screens/make_sale.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class TicketSalesScreen extends StatefulWidget {
  const TicketSalesScreen({super.key});

  @override
  State<TicketSalesScreen> createState() => _TicketSalesScreenState();
}

class _TicketSalesScreenState extends State<TicketSalesScreen>
    with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> _tickets = [];
  List<Map<String, dynamic>> _filteredTickets = [];
  String _searchQuery = '';
  String? _statusFilter;
  String? _reasonFilter;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  final List<String> _statuses = ['Pending', 'Approved', 'Rejected'];
  final List<String> _reasons = [
    'Shop closed',
    'Stocked',
    'Price disputes',
    'Lack of cash',
    'Product disputes',
  ];

  // Status counts
  int _pendingCount = 0;
  int _approvedCount = 0;
  int _rejectedCount = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

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

  void _loadTickets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final state = Provider.of<AppState>(context, listen: false);
      final user = state.user;
      
      if (user == null || user.routes.isEmpty) {
        // Fallback to hardcoded data if no user/routes
        _loadHardcodedTickets();
        return;
      }

      final routeId = user.routes.first.routeId;
      final day = _getDayFromDate(_selectedDate);
      final date = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final tickets = await state.listTickets(
        routeId: routeId,
        day: day,
        date: date,
      );

      setState(() {
        _tickets = tickets;
        _filteredTickets = tickets;
        _isLoading = false;
      });

      _updateStatusCounts();
    } catch (e) {
      print('Error loading tickets: $e');
      // Fallback to hardcoded data on error
      _loadHardcodedTickets();
    }
  }

  void _loadHardcodedTickets() {
    setState(() {
      _tickets = _getHardcodedTickets();
      _filteredTickets = _tickets;
      _isLoading = false;
    });
    _updateStatusCounts();
  }

  List<Map<String, dynamic>> _getHardcodedTickets() {
    return [
      {
        'id': 'TKT-001',
        'routeId': 'KDQ 154P',
        'stopId': 'STOP-001',
        'stopName': 'Mama Sarah Shop',
        'day': 'MONDAY',
        'reason': 'Shop closed',
        'status': 'Pending',
        'createdAt': DateTime.now().subtract(const Duration(days: 2)),
        'notes': 'Customer reported shop was closed during visit',
        'stopInfo': {
          'stopId': 'STOP-001',
          'name': 'Mama Sarah Shop',
          'latitude': -1.263049,
          'longitude': 36.803552,
        },
      },
      {
        'id': 'TKT-002',
        'routeId': 'KDQ 154P',
        'stopId': 'STOP-002',
        'stopName': 'John\'s Gas Station',
        'day': 'TUESDAY',
        'reason': 'Price disputes',
        'status': 'Approved',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
        'notes': 'Customer disagreed with gas cylinder pricing',
        'stopInfo': {
          'stopId': 'STOP-002',
          'name': 'John\'s Gas Station',
          'latitude': -1.263049,
          'longitude': 36.803552,
        },
      },
      {
        'id': 'TKT-003',
        'routeId': 'KDQ 154P',
        'stopId': 'STOP-003',
        'stopName': 'City Center Mall',
        'day': 'WEDNESDAY',
        'reason': 'Stocked',
        'status': 'Rejected',
        'createdAt': DateTime.now(),
        'notes': 'Customer already had sufficient stock',
        'stopInfo': {
          'stopId': 'STOP-003',
          'name': 'City Center Mall',
          'latitude': -1.263049,
          'longitude': 36.803552,
        },
      },
      {
        'id': 'TKT-004',
        'routeId': 'KDQ 154P',
        'stopId': 'STOP-004',
        'stopName': 'Highway Restaurant',
        'day': 'THURSDAY',
        'reason': 'Lack of cash',
        'status': 'Pending',
        'createdAt': DateTime.now().subtract(const Duration(hours: 6)),
        'notes': 'Customer had insufficient cash for purchase',
        'stopInfo': {
          'stopId': 'STOP-004',
          'name': 'Highway Restaurant',
          'latitude': -1.263049,
          'longitude': 36.803552,
        },
      },
      {
        'id': 'TKT-005',
        'routeId': 'KDQ 154P',
        'stopId': 'STOP-005',
        'stopName': 'University Campus',
        'day': 'FRIDAY',
        'reason': 'Product disputes',
        'status': 'Approved',
        'createdAt': DateTime.now().subtract(const Duration(hours: 12)),
        'notes': 'Customer complained about gas quality',
        'stopInfo': {
          'stopId': 'STOP-005',
          'name': 'University Campus',
          'latitude': -1.263049,
          'longitude': 36.803552,
        },
      },
      {
        'id': 'TKT-006',
        'routeId': 'KDQ 154P',
        'stopId': 'STOP-006',
        'stopName': 'Industrial Zone',
        'day': 'SATURDAY',
        'reason': 'Shop closed',
        'status': 'Rejected',
        'createdAt': DateTime.now().subtract(const Duration(days: 3)),
        'notes': 'Shop was actually open, salesperson error',
        'stopInfo': {
          'stopId': 'STOP-006',
          'name': 'Industrial Zone',
          'latitude': -1.263049,
          'longitude': 36.803552,
        },
      },
    ];
  }

  void _updateStatusCounts() {
    _pendingCount = _tickets.where((ticket) => ticket['status'] == 'Pending').length;
    _approvedCount = _tickets.where((ticket) => ticket['status'] == 'Approved').length;
    _rejectedCount = _tickets.where((ticket) => ticket['status'] == 'Rejected').length;
  }

  void _filterTickets() {
    setState(() {
      _filteredTickets = _tickets.where((ticket) {
        final matchesSearch = ticket['id'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
            ticket['stopName'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
            ticket['notes'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
            ticket['routeId'].toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesStatus = _statusFilter == null || ticket['status'] == _statusFilter;
        final matchesReason = _reasonFilter == null || ticket['reason'] == _reasonFilter;

        return matchesSearch && matchesStatus && matchesReason;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _statusFilter = null;
      _reasonFilter = null;
      _filteredTickets = _tickets;
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _loadTickets();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.schedule;
      case 'Approved':
        return Icons.check_circle;
      case 'Rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  void _makeResaleFromTicket(Map<String, dynamic> ticket) {
    if (ticket['stopInfo'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stop information not available for resale'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final stopInfo = ticket['stopInfo'];
    final defaultLat = -1.263049;
    final defaultLng = 36.803552;

    final stopLat = stopInfo['latitude'] ?? defaultLat;
    final stopLng = stopInfo['longitude'] ?? defaultLng;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MakeSaleScreen(
          shopName: ticket['stopName'],
          routeId: ticket['routeId'],
          stopId: ticket['stopId'],
          day: _getDayFromDate(DateTime.now()),
          stopLat: stopLat,
          stopLng: stopLng,
          logoUrl: '', // Will be handled by make sale screen
          onComplete: () {
            // Refresh the ticket list after resale
            _loadTickets();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Ticket Sales',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTickets),
        ],
      ),
      body: Column(
        children: [
          // Status Count Cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatusCard('Pending', _pendingCount, Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusCard('Approved', _approvedCount, Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusCard('Rejected', _rejectedCount, Colors.red),
                ),
              ],
            ),
          ),

          // Date Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.textLight),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate),
                        style: AppTheme.bodyMedium,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterTickets();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search tickets...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppTheme.textSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.textLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.textLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Row
                Row(
                  children: [
                    // Status Filter
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.textLight),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _statusFilter,
                            hint: const Text('Status'),
                            isExpanded: true,
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('All Status'),
                              ),
                              ..._statuses.map(
                                (status) => DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(status),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _statusFilter = value;
                              });
                              _filterTickets();
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Reason Filter
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.textLight),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _reasonFilter,
                            hint: const Text('Reason'),
                            isExpanded: true,
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('All Reasons'),
                              ),
                              ..._reasons.map(
                                (reason) => DropdownMenuItem<String>(
                                  value: reason,
                                  child: Text(reason),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _reasonFilter = value;
                              });
                              _filterTickets();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Clear Filters Button
                if (_searchQuery.isNotEmpty ||
                    _statusFilter != null ||
                    _reasonFilter != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear, size: 18),
                      label: const Text('Clear Filters'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Tickets List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  )
                : _filteredTickets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty ||
                                      _statusFilter != null ||
                                      _reasonFilter != null
                                  ? 'No tickets found'
                                  : 'No tickets available',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isNotEmpty ||
                                      _statusFilter != null ||
                                      _reasonFilter != null
                                  ? 'Try adjusting your search or filters'
                                  : 'Tickets will appear here when raised',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredTickets.length,
                        itemBuilder: (context, index) {
                          final ticket = _filteredTickets[index];
                          return _buildTicketCard(ticket);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String status, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(status),
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    final isRejected = ticket['status'] == 'Rejected';
    
    return GestureDetector(
      onTap: isRejected ? () => _makeResaleFromTicket(ticket) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: isRejected ? Border.all(color: Colors.red.withOpacity(0.3), width: 2) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Status Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(ticket['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusIcon(ticket['status']),
                      color: _getStatusColor(ticket['status']),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Ticket Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket['id'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          ticket['stopName'],
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(ticket['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(ticket['status']).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      ticket['status'],
                      style: TextStyle(
                        color: _getStatusColor(ticket['status']),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Details Row
              Row(
                children: [
                  Expanded(child: _buildDetailItem('Route', ticket['routeId'])),
                  Expanded(child: _buildDetailItem('Day', ticket['day'])),
                ],
              ),

              const SizedBox(height: 8),

              // Reason
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ticket['reason'],
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Notes
              if (ticket['notes'] != null && ticket['notes'].isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ticket['notes'],
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // Date
              Text(
                'Created: ${DateFormat('MMM dd, yyyy - HH:mm').format(ticket['createdAt'])}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),

              // Resale hint for rejected tickets
              if (isRejected) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.touch_app, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Tap to make a sale',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
