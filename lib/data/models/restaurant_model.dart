import 'package:equatable/equatable.dart';

/// Represents a restaurant (tenant) in the system.
class RestaurantModel extends Equatable {
  const RestaurantModel({
    required this.id,
    required this.name,
    this.address,
    this.contact,
    this.enabledModules = const {},
    this.settings = const {},
    this.createdAt,
  });

  final String id;
  final String name;
  final String? address;
  final String? contact;
  final Map<String, dynamic> enabledModules;
  final Map<String, dynamic> settings;
  final DateTime? createdAt;

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      contact: json['contact'] as String?,
      enabledModules:
          (json['enabled_modules'] as Map<String, dynamic>?) ?? const {},
      settings: (json['settings'] as Map<String, dynamic>?) ?? const {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'contact': contact,
      'enabled_modules': enabledModules,
      'settings': settings,
    };
  }

  @override
  List<Object?> get props =>
      [id, name, address, contact, enabledModules, settings, createdAt];
}
