import 'package:restaurant/data/models/salary_record_model.dart';
import 'package:restaurant/data/repositories/firestore_repository.dart';

class SalaryRepository {
  SalaryRepository(this._firestoreRepo);

  final FirestoreRepository _firestoreRepo;
  static const String _table = 'salary_records';

  Future<List<SalaryRecordModel>> fetchSalaries(String restaurantId) async {
    final data = await _firestoreRepo.fetchAll(_table, restaurantId: restaurantId);
    return data.map((json) => SalaryRecordModel.fromJson(json)).toList();
  }

  Future<SalaryRecordModel> processSalary(SalaryRecordModel record) async {
    final data = await _firestoreRepo.insert(_table, record.toJson());
    return SalaryRecordModel.fromJson(data);
  }

  Future<SalaryRecordModel> markAsPaid(String id) async {
    final updates = {
      'status': 'paid',
      'payment_date': DateTime.now().toIso8601String(),
    };
    final data = await _firestoreRepo.update(_table, id, updates);
    return SalaryRecordModel.fromJson(data);
  }
}
