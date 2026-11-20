class Admin {
  const Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
  });

  final int id;
  final String name;
  final String email;
  final String department;

  factory Admin.fromJson(Map<String, dynamic> json) => Admin(
    id: int.parse(json['id'].toString()),
    name: json['name'] as String,
    email: json['email'] as String,
    department: json['department'] as String,
  );
}
