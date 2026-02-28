import 'package:restaurant/data/models/role_model.dart';
import 'package:restaurant/data/repositories/firestore_repository.dart';

class RoleRepository {
  RoleRepository(this._firestoreRepo);

  final FirestoreRepository _firestoreRepo;
  static const String _table = 'roles';

  Future<List<RoleModel>> fetchRoles(String restaurantId) async {
    final data = await _firestoreRepo.fetchAll(_table, restaurantId: restaurantId);
    return data.map((json) => RoleModel.fromJson(json)).toList();
  }

  Future<RoleModel> createRole(RoleModel role) async {
    final data = await _firestoreRepo.insert(_table, role.toJson());
    return RoleModel.fromJson(data);
  }

  Future<RoleModel> updateRole(String id, Map<String, dynamic> updates) async {
    final data = await _firestoreRepo.update(_table, id, updates);
    return RoleModel.fromJson(data);
  }

  Future<void> deleteRole(String id) async {
    await _firestoreRepo.delete(_table, id);
  }
}
