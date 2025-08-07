import 'package:flutter/material.dart';
import 'package:chevenergies/models/ticket.dart';
import 'package:chevenergies/shared utils/app_theme.dart';
import 'package:intl/intl.dart';

class TicketSalesScreen extends StatefulWidget {
  const TicketSalesScreen({super.key});

  @override
  State<TicketSalesScreen> createState() => _TicketSalesScreenState();
}

class _TicketSalesScreenState extends State<TicketSalesScreen>
    with AutomaticKeepAliveClientMixin {
  List<Ticket> _tickets = [];
  List<Ticket> _filteredTickets = [];
  String _searchQuery = '';
  String? _reasonFilter;
  bool _isLoading = false;

  final List<String> _reasons = [
    'Technical Issue',
    'Customer Complaint',
    'Delivery Problem',
    'Payment Issue',
    'Product Quality',
    'Service Request',
    'Emergency',
    'Other'
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  void _loadTickets() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _tickets = _getHardcodedTickets();
        _filteredTickets = _tickets;
        _isLoading = false;
      });
    });
  }

  List<Ticket> _getHardcodedTickets() {
    return [
      Ticket(
        ticketId: 'TKT-001',
        routeId: 'KDQ 154P',
        stopId: 'STOP-001',
        stopName: 'Mama Sarah Shop',
        day: 'MONDAY',
        notes: 'Customer reported gas cylinder leakage. Immediate attention required.',
        reason: 'Technical Issue',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        status: 'Open',
      ),
      Ticket(
        ticketId: 'TKT-002',
        routeId: 'KDQ 154P',
        stopId: 'STOP-002',
        stopName: 'John\'s Gas Station',
        day: 'TUESDAY',
        notes: 'Payment dispute - customer claims double charging',
        reason: 'Payment Issue',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: 'In Progress',
      ),
      Ticket(
        ticketId: 'TKT-003',
        routeId: 'KDQ 154P',
        stopId: 'STOP-003',
        stopName: 'City Center Mall',
        day: 'WEDNESDAY',
        notes: 'Request for additional gas cylinders for weekend event',
        reason: 'Service Request',
        createdAt: DateTime.now(),
        status: 'Open',
      ),
      Ticket(
        ticketId: 'TKT-004',
        routeId: 'KDQ 154P',
        stopId: 'STOP-004',
        stopName: 'Highway Restaurant',
        day: 'THURSDAY',
        notes: 'Gas cylinder explosion reported. Emergency response needed.',
        reason: 'Emergency',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        status: 'Resolved',
      ),
      Ticket(
        ticketId: 'TKT-005',
        routeId: 'KDQ 154P',
        stopId: 'STOP-005',
        stopName: 'University Campus',
        day: 'FRIDAY',
        notes: 'Customer complaint about gas quality and pressure',
        reason: 'Customer Complaint',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        status: 'In Progress',
      ),
    ];
  }

  void _filterTickets() {
    setState(() {
      _filteredTickets = _tickets.where((ticket) {
        final matchesSearch = ticket.ticketId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            ticket.stopName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            ticket.notes.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            ticket.routeId.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesReason = _reasonFilter == null || ticket.reason == _reasonFilter;

        return matchesSearch && matchesReason;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _reasonFilter = null;
      _filteredTickets = _tickets;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getReasonColor(String reason) {
    switch (reason) {
      case 'Emergency':
        return Colors.red;
      case 'Technical Issue':
        return Colors.orange;
      case 'Customer Complaint':
        return Colors.purple;
      case 'Payment Issue':
        return Colors.amber;
      case 'Delivery Problem':
        return Colors.indigo;
      case 'Service Request':
        return Colors.teal;
      case 'Product Quality':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Ticket Sales',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTickets,
          ),
        ],
      ),
      body: Column(
        children: [
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
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
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

                // Reason Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.textLight),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _reasonFilter,
                      hint: const Text('Filter by Reason'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Reasons'),
                        ),
                        ..._reasons.map((reason) => DropdownMenuItem<String>(
                          value: reason,
                          child: Text(reason),
                        )),
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
                const SizedBox(height: 12),

                // Clear Filters Button
                if (_searchQuery.isNotEmpty || _reasonFilter != null)
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
                              _searchQuery.isNotEmpty || _reasonFilter != null
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
                              _searchQuery.isNotEmpty || _reasonFilter != null
                                  ? 'Try adjusting your search or filters'
                                  : 'Tickets will appear here when created',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Create ticket functionality coming soon!'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTicketCard(Ticket ticket) {
    return Container(
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
      ),
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getStatusColor(ticket.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.receipt_long,
            color: _getStatusColor(ticket.status),
            size: 24,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ticket.ticketId,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              ticket.stopName,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getReasonColor(ticket.reason).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ticket.reason,
                    style: TextStyle(
                      color: _getReasonColor(ticket.reason),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(ticket.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ticket.status,
                    style: TextStyle(
                      color: _getStatusColor(ticket.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Created: ${DateFormat('MMM dd, yyyy - HH:mm').format(ticket.createdAt)}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Route ID', ticket.routeId),
                _buildDetailRow('Stop ID', ticket.stopId),
                _buildDetailRow('Day', ticket.day),
                const SizedBox(height: 12),
                const Text(
                  'Notes:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ticket.notes,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Edit ticket functionality coming soon!'),
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Resolve ticket functionality coming soon!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text('Resolve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
