import 'package:restaurant/data/models/salary_record_model.dart';
import 'package:restaurant/data/repositories/supabase_repository.dart';

class SalaryRepository {
  SalaryRepository(this._supabaseRepo);

  final SupabaseRepository _supabaseRepo;
  static const String _table = 'salary_records';

  Future<List<SalaryRecordModel>> fetchSalaries(String restaurantId) async {
    final data = await _supabaseRepo.fetchAll(_table, restaurantId: restaurantId);
    return data.map((json) => SalaryRecordModel.fromJson(json)).toList();
  }

  Future<SalaryRecordModel> processSalary(SalaryRecordModel record) async {
    final data = await _supabaseRepo.insert(_table, record.toJson());
    return SalaryRecordModel.fromJson(data);
  }

  Future<SalaryRecordModel> markAsPaid(String id) async {
    final updates = {
      'status': 'paid',
      'payment_date': DateTime.now().toIso8601String(),
    };
    final data = await _supabaseRepo.update(_table, id, updates);
    return SalaryRecordModel.fromJson(data);
  }
}
