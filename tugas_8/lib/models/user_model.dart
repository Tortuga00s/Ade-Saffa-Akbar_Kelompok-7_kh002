class User {
  final int id;
  final String name;
  final String email;
  final String city;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.city,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String parsedCity = '';
    if (json['address'] != null && json['address'] is Map) {
      parsedCity = json['address']['city']?.toString() ?? '';
    } else if (json['city'] != null) {
      parsedCity = json['city'].toString();
    }

    return User(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      city: parsedCity,
      email: json['email']?.toString() ?? '',
    );
  }
}
