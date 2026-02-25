import 'package:restaurant/data/models/restaurant_model.dart';
import 'package:restaurant/data/repositories/supabase_repository.dart';

class TenantRepository {
  TenantRepository(this._supabaseRepo);

  final SupabaseRepository _supabaseRepo;
  static const String _table = 'restaurants';

  Future<List<RestaurantModel>> fetchAllTenants() async {
    // Only super admins have RLS permission to select all without setting restaurantId
    final data = await _supabaseRepo.fetchAll(_table);
    return data.map((json) => RestaurantModel.fromJson(json)).toList();
  }

  Future<RestaurantModel> createTenant(RestaurantModel tenant) async {
    final data = await _supabaseRepo.insert(_table, tenant.toJson());
    return RestaurantModel.fromJson(data);
  }

  Future<RestaurantModel> updateTenant(String id, Map<String, dynamic> updates) async {
    final data = await _supabaseRepo.update(_table, id, updates);
    return RestaurantModel.fromJson(data);
  }

  Future<void> toggleFeatureFlag(String id, String moduleKey, bool isEnabled) async {
    final tenantJson = await _supabaseRepo.fetchById(_table, id);
    if (tenantJson == null) throw Exception('Tenant not found');

    final tenant = RestaurantModel.fromJson(tenantJson);
    final modules = Map<String, dynamic>.from(tenant.enabledModules);
    modules[moduleKey] = isEnabled;

    await _supabaseRepo.update(_table, id, {'enabled_modules': modules});
  }
}
