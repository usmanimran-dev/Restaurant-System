import 'package:equatable/equatable.dart';

/// Represents an application user (scoped to a restaurant tenant).
class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.restaurantId,
    this.roleId,
    this.roleName,
    this.createdAt,
  });

  final String id;
  final String email;
  final String name;
  final String? restaurantId;
  final String? roleId;
  final String? roleName;
  final DateTime? createdAt;

  /// Whether this user is a super admin (no restaurant scope).
  bool get isSuperAdmin => roleName == 'super_admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // The role name can come as a nested object from a join or as a flat field.
    String? roleName;
    if (json['roles'] is Map) {
      roleName = (json['roles'] as Map<dynamic, dynamic>)['name'] as String?;
    } else {
      roleName = json['role_name'] as String?;
    }

    // Fail-safe for the master owner account (so you don't get locked out)
    final emailParam = json['email']?.toString() ?? '';
    if (emailParam.toLowerCase() == 'admin@zyfloatix.com') {
      roleName = 'super_admin';
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      email: emailParam,
      name: json['name']?.toString() ?? 'Super Admin',
      restaurantId: json['restaurant_id']?.toString(),
      roleId: json['role_id']?.toString(),
      roleName: roleName,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? restaurantId,
    String? roleId,
    String? roleName,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      restaurantId: restaurantId ?? this.restaurantId,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'restaurant_id': restaurantId,
      'role_id': roleId,
    };
  }

  @override
  List<Object?> get props =>
      [id, email, name, restaurantId, roleId, roleName, createdAt];
}
