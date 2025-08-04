class Expenditure {
  final String day;
  final String date;
  final String name;
  final String requestedAmount;
  final String approvedAmount;
  final String comments;
  final String status;

  Expenditure({
    required this.day,
    required this.date,
    required this.name,
    required this.requestedAmount,
    required this.approvedAmount,
    required this.comments,
    required this.status,
  });

  Map<String, String> toMap() {
    return {
      'day': day,
      'date': date,
      'name': name,
      'requestedAmount': requestedAmount,
      'approvedAmount': approvedAmount,
      'comments': comments,
      'status': status,
    };
  }
}
  