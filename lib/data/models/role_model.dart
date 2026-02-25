import 'package:equatable/equatable.dart';

/// Represents a role with dynamic JSON permissions.
class RoleModel extends Equatable {
  const RoleModel({
    required this.id,
    required this.name,
    this.restaurantId,
    this.permissions = const {},
    this.createdAt,
  });

  final String id;
  final String name;
  final String? restaurantId;
  final Map<String, dynamic> permissions;
  final DateTime? createdAt;

  /// Check if this role has a specific permission.
  bool hasPermission(String key) {
    return permissions[key] == true;
  }

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      restaurantId: json['restaurant_id'] as String?,
      permissions:
          (json['permissions'] as Map<String, dynamic>?) ?? const {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'restaurant_id': restaurantId,
      'permissions': permissions,
    };
  }

  @override
  List<Object?> get props =>
      [id, name, restaurantId, permissions, createdAt];
}
