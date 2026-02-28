import 'package:restaurant/data/models/audit_log_model.dart';
import 'package:restaurant/data/repositories/firestore_repository.dart';

class AuditLogRepository {
  AuditLogRepository(this._firestoreRepo);

  final FirestoreRepository _firestoreRepo;
  static const String _table = 'audit_logs';

  Future<List<AuditLogModel>> fetchLogs(String restaurantId) async {
    final data = await _firestoreRepo.fetchAll(_table, restaurantId: restaurantId);
    final logs = data.map((json) => AuditLogModel.fromJson(json)).toList();
    // Sort newest first
    logs.sort((a, b) => (b.timestamp ?? DateTime(2000)).compareTo(a.timestamp ?? DateTime(2000)));
    return logs;
  }

  Future<void> log({
    required String restaurantId,
    required String userId,
    required String userName,
    required String action,
    required String entity,
    required String entityId,
    String? details,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
  }) async {
    final entry = AuditLogModel(
      id: '',
      restaurantId: restaurantId,
      userId: userId,
      userName: userName,
      action: action,
      entity: entity,
      entityId: entityId,
      details: details,
      oldValue: oldValue,
      newValue: newValue,
      timestamp: DateTime.now(),
    );
    await _firestoreRepo.insert(_table, entry.toJson());
  }
}
