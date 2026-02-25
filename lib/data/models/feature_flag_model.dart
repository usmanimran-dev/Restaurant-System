import 'package:equatable/equatable.dart';

/// Represents a feature flag, optionally scoped to a restaurant.
class FeatureFlagModel extends Equatable {
  const FeatureFlagModel({
    required this.id,
    required this.name,
    this.description,
    this.defaultEnabled = false,
    this.restaurantId,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? description;
  final bool defaultEnabled;
  final String? restaurantId;
  final DateTime? createdAt;

  factory FeatureFlagModel.fromJson(Map<String, dynamic> json) {
    return FeatureFlagModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      defaultEnabled: json['default_enabled'] as bool? ?? false,
      restaurantId: json['restaurant_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'default_enabled': defaultEnabled,
      'restaurant_id': restaurantId,
    };
  }

  @override
  List<Object?> get props =>
      [id, name, description, defaultEnabled, restaurantId, createdAt];
}
