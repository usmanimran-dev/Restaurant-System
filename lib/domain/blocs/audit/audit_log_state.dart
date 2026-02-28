import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/audit_log_model.dart';

abstract class AuditLogState extends Equatable {
  const AuditLogState();
  @override
  List<Object?> get props => [];
}

class AuditLogInitial extends AuditLogState {}
class AuditLogLoading extends AuditLogState {}

class AuditLogsLoaded extends AuditLogState {
  final List<AuditLogModel> logs;
  const AuditLogsLoaded(this.logs);
  @override
  List<Object?> get props => [logs];
}

class AuditLogRecorded extends AuditLogState {}

class AuditLogError extends AuditLogState {
  final String message;
  const AuditLogError(this.message);
  @override
  List<Object?> get props => [message];
}
