import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:restaurant/data/models/restaurant_model.dart';
import 'package:restaurant/data/repositories/firestore_repository.dart';

class TenantRepository {
  TenantRepository(this._firestoreRepo);

  final FirestoreRepository _firestoreRepo;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  static const String _table = 'restaurants';

  Future<List<RestaurantModel>> fetchAllTenants() async {
    final data = await _firestoreRepo.fetchAll(_table);
    return data.map((json) => RestaurantModel.fromJson(json)).toList();
  }

  Future<RestaurantModel> createTenant(RestaurantModel tenant) async {
    final data = await _firestoreRepo.insert(_table, tenant.toJson());
    return RestaurantModel.fromJson(data);
  }

  Future<RestaurantModel> updateTenant(String id, Map<String, dynamic> updates) async {
    final data = await _firestoreRepo.update(_table, id, updates);
    return RestaurantModel.fromJson(data);
  }

  Future<void> deleteTenant(String id) async {
    await _firestoreRepo.delete(_table, id);
  }

  Future<void> toggleFeatureFlag(String id, String moduleKey, bool isEnabled) async {
    final tenantJson = await _firestoreRepo.fetchById(_table, id);
    if (tenantJson == null) throw Exception('Tenant not found');

    final tenant = RestaurantModel.fromJson(tenantJson);
    final modules = Map<String, dynamic>.from(tenant.enabledModules);
    modules[moduleKey] = isEnabled;

    await _firestoreRepo.update(_table, id, {'enabled_modules': modules});
  }

  /// Seeds comprehensive demo data (menu, orders, KDS, inventory, etc.) via Cloud Function.
  /// Requires super_admin auth.
  Future<void> seedRestaurantData(String restaurantId) async {
    try {
      final callable = _functions.httpsCallable('seedRestaurantData');
      await callable.call({'restaurantId': restaurantId});
    } catch (e) {
      throw Exception('Failed to seed data: $e');
    }
  }

  /// Creates a Firebase Auth user and a Firestore user doc for the restaurant admin.
  Future<void> createRestaurantAdmin({
    required String restaurantId,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Use Cloud Function (Admin SDK) to create the user securely.
      // The caller must be authenticated as super_admin.
      final callable = _functions.httpsCallable('createRestaurantAdmin');
      await callable.call({
        'restaurantId': restaurantId,
        'email': email,
        'password': password,
        'name': name,
      });
    } catch (e) {
      throw Exception('Failed to create restaurant admin: $e');
    }
  }
}
