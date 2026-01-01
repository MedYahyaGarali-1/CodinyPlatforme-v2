import '../../core/enums/user_role.dart';

class User {
  final String id;
  final String name;
  final UserRole role;

  const User({
    required this.id,
    required this.name,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'],
      role: UserRole.values.byName(json['role']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role.name,
    };
  }
}

