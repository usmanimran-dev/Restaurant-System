import 'package:equatable/equatable.dart';

abstract class AuditLogEvent extends Equatable {
  const AuditLogEvent();
  @override
  List<Object?> get props => [];
}

class LoadAuditLogs extends AuditLogEvent {
  final String restaurantId;
  const LoadAuditLogs(this.restaurantId);
  @override
  List<Object?> get props => [restaurantId];
}

class RecordAuditLog extends AuditLogEvent {
  final String restaurantId;
  final String userId;
  final String userName;
  final String action;
  final String entity;
  final String entityId;
  final String? details;
  final Map<String, dynamic>? oldValue;
  final Map<String, dynamic>? newValue;

  const RecordAuditLog({
    required this.restaurantId,
    required this.userId,
    required this.userName,
    required this.action,
    required this.entity,
    required this.entityId,
    this.details,
    this.oldValue,
    this.newValue,
  });

  @override
  List<Object?> get props => [restaurantId, userId, action, entity, entityId];
}
