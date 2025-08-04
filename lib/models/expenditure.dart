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

  // Convert to Map
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

  // Factory method to create Expenditure from JSON
  factory Expenditure.fromJson(Map<String, dynamic> json) {
    // Handle potential field name variations from API
    String getStringField(String fieldName, List<String> possibleNames) {
      for (String name in possibleNames) {
        if (json.containsKey(name) && json[name] != null) {
          return json[name].toString();
        }
      }
      return ''; // Return empty string if field not found
    }

    return Expenditure(
      day: getStringField('day', ['day', 'Day', 'DAY']),
      date: getStringField('date', [
        'date',
        'Date',
        'DATE',
        'created_date',
        'request_date',
      ]),
      name: getStringField('name', [
        'name',
        'Name',
        'NAME',
        'description',
        'title',
        'claim_title',
      ]),
      requestedAmount: getStringField('requestedAmount', [
        'requestedAmount',
        'requested_amount',
        'amount',
        'Amount',
        'AMOUNT',
      ]),
      approvedAmount: getStringField('approvedAmount', [
        'approvedAmount',
        'approved_amount',
        'approved',
      ]),
      comments: getStringField('comments', [
        'comments',
        'Comments',
        'COMMENTS',
        'description',
        'Description',
      ]),
      status: getStringField('status', ['status', 'Status', 'STATUS', 'state']),
    );
  }
}
