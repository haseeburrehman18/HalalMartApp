// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'user' | 'seller' | 'admin'
  final String? photoUrl;
  final String? shopName;
  final DateTime createdAt;
  final bool isEnabled; // Admin can enable/disable users

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.shopName,
    required this.createdAt,
    this.isEnabled = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        uid: map['uid'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        role: map['role'] ?? 'user',
        photoUrl: map['photoUrl'],
        shopName: map['shopName'],
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        isEnabled: map['isEnabled'] ?? true,
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'role': role,
        'photoUrl': photoUrl,
        'shopName': shopName,
        'createdAt': createdAt.toIso8601String(),
        'isEnabled': isEnabled,
      };

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? photoUrl,
    String? shopName,
    DateTime? createdAt,
    bool? isEnabled,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      shopName: shopName ?? this.shopName,
      createdAt: createdAt ?? this.createdAt,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
