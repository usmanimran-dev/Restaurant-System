import 'package:equatable/equatable.dart';

/// Immutable audit trail entry for critical actions.
class AuditLogModel extends Equatable {
  const AuditLogModel({
    required this.id,
    required this.restaurantId,
    required this.userId,
    required this.userName,
    required this.action,
    required this.entity,
    required this.entityId,
    this.details,
    this.oldValue,
    this.newValue,
    this.timestamp,
  });

  final String id;
  final String restaurantId;
  final String userId;
  final String userName;
  final String action; // 'create', 'update', 'delete', 'login', 'logout'
  final String entity; // 'menu_item', 'order', 'employee', 'inventory', etc.
  final String entityId;
  final String? details; // Human-readable description
  final Map<String, dynamic>? oldValue;
  final Map<String, dynamic>? newValue;
  final DateTime? timestamp;

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      action: json['action'] as String,
      entity: json['entity'] as String,
      entityId: json['entity_id'] as String,
      details: json['details'] as String?,
      oldValue: json['old_value'] as Map<String, dynamic>?,
      newValue: json['new_value'] as Map<String, dynamic>?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'user_id': userId,
      'user_name': userName,
      'action': action,
      'entity': entity,
      'entity_id': entityId,
      'details': details,
      'old_value': oldValue,
      'new_value': newValue,
      'timestamp': (timestamp ?? DateTime.now()).toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id, restaurantId, userId, userName, action,
        entity, entityId, details, timestamp,
      ];
}
