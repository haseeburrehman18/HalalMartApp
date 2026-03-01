// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'user' | 'seller' | 'admin'
  final String? photoUrl;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        uid: map['uid'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        role: map['role'] ?? 'user',
        photoUrl: map['photoUrl'],
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'role': role,
        'photoUrl': photoUrl,
        'createdAt': createdAt.toIso8601String(),
      };
}
