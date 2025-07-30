
class County {
  final String name;
  final List<String> subCounties;

  County({required this.name, required this.subCounties});

  factory County.fromJson(Map<String, dynamic> json) {
    return County(
      name: json['name'],
      subCounties: List<String>.from(json['sub_counties']),
    );
  }
}
