import 'package:restaurant/data/models/employee_model.dart';
import 'package:restaurant/data/repositories/supabase_repository.dart';

class EmployeeRepository {
  EmployeeRepository(this._supabaseRepo);

  final SupabaseRepository _supabaseRepo;
  static const String _table = 'users'; // Employees are stored in the users table

  Future<List<EmployeeModel>> fetchEmployees(String restaurantId) async {
    // Select the user fields and the joined role name
    final data = await _supabaseRepo.fetchAll(
      _table, 
      restaurantId: restaurantId, 
      select: '*, roles(name)'
    );
    return data.map((json) => EmployeeModel.fromJson(json)).toList();
  }

  Future<EmployeeModel> createEmployee(EmployeeModel employee) async {
    final data = await _supabaseRepo.insert(_table, employee.toJson());
    return EmployeeModel.fromJson(data);
  }

  Future<EmployeeModel> updateEmployee(String id, Map<String, dynamic> updates) async {
    final data = await _supabaseRepo.update(_table, id, updates);
    return EmployeeModel.fromJson(data);
  }

  Future<void> deleteEmployee(String id) async {
    await _supabaseRepo.delete(_table, id);
  }
}
