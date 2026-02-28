import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/data/repositories/audit_log_repository.dart';
import 'package:restaurant/domain/blocs/audit/audit_log_event.dart';
import 'package:restaurant/domain/blocs/audit/audit_log_state.dart';

class AuditLogBloc extends Bloc<AuditLogEvent, AuditLogState> {
  final AuditLogRepository _auditLogRepository;

  AuditLogBloc({required AuditLogRepository auditLogRepository})
      : _auditLogRepository = auditLogRepository,
        super(AuditLogInitial()) {
    on<LoadAuditLogs>(_onLoad);
    on<RecordAuditLog>(_onRecord);
  }

  Future<void> _onLoad(LoadAuditLogs event, Emitter<AuditLogState> emit) async {
    emit(AuditLogLoading());
    try {
      final logs = await _auditLogRepository.fetchLogs(event.restaurantId);
      emit(AuditLogsLoaded(logs));
    } catch (e) {
      emit(AuditLogError(e.toString()));
    }
  }

  Future<void> _onRecord(RecordAuditLog event, Emitter<AuditLogState> emit) async {
    try {
      await _auditLogRepository.log(
        restaurantId: event.restaurantId,
        userId: event.userId,
        userName: event.userName,
        action: event.action,
        entity: event.entity,
        entityId: event.entityId,
        details: event.details,
        oldValue: event.oldValue,
        newValue: event.newValue,
      );
      emit(AuditLogRecorded());
    } catch (e) {
      emit(AuditLogError(e.toString()));
    }
  }
}
