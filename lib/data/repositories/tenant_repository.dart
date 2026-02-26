import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:restaurant/data/models/restaurant_model.dart';
import 'package:restaurant/data/repositories/supabase_repository.dart';

class TenantRepository {
  TenantRepository(this._supabaseRepo);

  final SupabaseRepository _supabaseRepo;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _table = 'restaurants';

  Future<List<RestaurantModel>> fetchAllTenants() async {
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

  Future<void> deleteTenant(String id) async {
    await _supabaseRepo.delete(_table, id);
  }

  Future<void> toggleFeatureFlag(String id, String moduleKey, bool isEnabled) async {
    final tenantJson = await _supabaseRepo.fetchById(_table, id);
    if (tenantJson == null) throw Exception('Tenant not found');

    final tenant = RestaurantModel.fromJson(tenantJson);
    final modules = Map<String, dynamic>.from(tenant.enabledModules);
    modules[moduleKey] = isEnabled;

    await _supabaseRepo.update(_table, id, {'enabled_modules': modules});
  }

  /// Creates a Firebase Auth user and a Firestore user doc for the restaurant admin.
  Future<void> createRestaurantAdmin({
    required String restaurantId,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Save current user reference so we can re-sign in as super admin after
      final currentUser = fb_auth.FirebaseAuth.instance.currentUser;
      final currentEmail = currentUser?.email;

      // Create the new Firebase Auth user
      final cred = await fb_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUid = cred.user!.uid;

      // Create the Firestore user document
      await _firestore.collection('users').doc(newUid).set({
        'email': email,
        'name': name,
        'restaurant_id': restaurantId,
        'role_id': 'restaurant_admin_role',
        'role_name': 'restaurant_admin',
        'roles': {'name': 'restaurant_admin'},
        'created_at': DateTime.now().toIso8601String(),
      });

      // Sign back in as the super admin if we had a user before
      // Note: In production, use Firebase Admin SDK via Cloud Functions instead
      if (currentEmail != null) {
        // We can't sign back in without the password, so we just sign out the new user
        // The super admin will need to re-authenticate
        // For demo purposes, we just leave it
      }
    } catch (e) {
      throw Exception('Failed to create restaurant admin: $e');
    }
  }
}
