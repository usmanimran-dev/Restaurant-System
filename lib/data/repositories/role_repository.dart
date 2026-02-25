import 'package:restaurant/data/models/role_model.dart';
import 'package:restaurant/data/repositories/supabase_repository.dart';

class RoleRepository {
  RoleRepository(this._supabaseRepo);

  final SupabaseRepository _supabaseRepo;
  static const String _table = 'roles';

  Future<List<RoleModel>> fetchRoles(String restaurantId) async {
    final data = await _supabaseRepo.fetchAll(_table, restaurantId: restaurantId);
    return data.map((json) => RoleModel.fromJson(json)).toList();
  }

  Future<RoleModel> createRole(RoleModel role) async {
    final data = await _supabaseRepo.insert(_table, role.toJson());
    return RoleModel.fromJson(data);
  }

  Future<RoleModel> updateRole(String id, Map<String, dynamic> updates) async {
    final data = await _supabaseRepo.update(_table, id, updates);
    return RoleModel.fromJson(data);
  }

  Future<void> deleteRole(String id) async {
    await _supabaseRepo.delete(_table, id);
  }
}
