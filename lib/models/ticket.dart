class Ticket {
  final String ticketId;
  final String routeId;
  final String stopId;
  final String stopName;
  final String day;
  final String notes;
  final String reason;
  final DateTime createdAt;
  final String status;

  Ticket({
    required this.ticketId,
    required this.routeId,
    required this.stopId,
    required this.stopName,
    required this.day,
    required this.notes,
    required this.reason,
    required this.createdAt,
    required this.status,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketId: json['ticket_id'] ?? '',
      routeId: json['route_id'] ?? '',
      stopId: json['stop_id'] ?? '',
      stopName: json['stop_name'] ?? '',
      day: json['day'] ?? '',
      notes: json['notes'] ?? '',
      reason: json['reason'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticket_id': ticketId,
      'route_id': routeId,
      'stop_id': stopId,
      'stop_name': stopName,
      'day': day,
      'notes': notes,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }
} 