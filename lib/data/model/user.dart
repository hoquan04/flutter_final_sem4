enum UserRole { Customer, Admin }

class User {
  final int userId;
  final String fullName;
  final String email;
  final String? phone;
  final String passwordHash;
  final String? address;
  final UserRole role;
  final DateTime createdAt;

  User({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phone,
    required this.passwordHash,
    this.address,
    required this.role,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    userId: json['userId'],
    fullName: json['fullName'],
    email: json['email'],
    phone: json['phone'],
    passwordHash: json['passwordHash'],
    address: json['address'],
    role: UserRole.values.firstWhere(
            (e) => e.toString().split('.').last == json['role']),
    createdAt: DateTime.parse(json['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'passwordHash': passwordHash,
    'address': address,
    'role': role.toString().split('.').last,
    'createdAt': createdAt.toIso8601String(),
  };
}
