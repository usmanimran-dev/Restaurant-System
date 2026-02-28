import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:restaurant/data/models/employee_model.dart';
import 'package:restaurant/data/repositories/firestore_repository.dart';

class EmployeeRepository {
  EmployeeRepository(this._firestoreRepo);

  final FirestoreRepository _firestoreRepo;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _table = 'employees';

  Future<List<EmployeeModel>> fetchEmployees(String restaurantId) async {
    final data = await _firestoreRepo.fetchAll(
      _table, 
      restaurantId: restaurantId,
    );
    return data.map((json) => EmployeeModel.fromJson(json)).toList();
  }

  Future<EmployeeModel> createEmployee(EmployeeModel employee) async {
    final data = await _firestoreRepo.insert(_table, employee.toJson());
    return EmployeeModel.fromJson(data);
  }

  /// Creates an employee AND a Firebase Auth account so they can log in.
  Future<EmployeeModel> createEmployeeWithAuth({
    required EmployeeModel employee,
    required String password,
  }) async {
    try {
      // Save current user
      final currentUser = fb_auth.FirebaseAuth.instance.currentUser;

      // Create Firebase Auth user
      final cred = await fb_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: employee.email,
        password: password,
      );

      final newUid = cred.user!.uid;

      // Create the employee doc in Firestore with the auth UID
      final employeeData = employee.toJson();
      employeeData['id'] = newUid;
      employeeData['created_at'] = DateTime.now().toIso8601String();

      await _firestore.collection(_table).doc(newUid).set(employeeData);

      // Also create a user doc so they can authenticate via login
      await _firestore.collection('users').doc(newUid).set({
        'email': employee.email,
        'name': employee.name,
        'restaurant_id': employee.restaurantId,
        'role_id': employee.roleId,
        'role_name': employee.roleName ?? 'employee',
        'roles': {'name': employee.roleName ?? 'employee'},
        'created_at': DateTime.now().toIso8601String(),
      });

      employeeData['id'] = newUid;
      return EmployeeModel.fromJson(employeeData);
    } catch (e) {
      throw Exception('Failed to create employee: $e');
    }
  }

  Future<EmployeeModel> updateEmployee(String id, Map<String, dynamic> updates) async {
    final data = await _firestoreRepo.update(_table, id, updates);
    return EmployeeModel.fromJson(data);
  }

  Future<void> deleteEmployee(String id) async {
    await _firestoreRepo.delete(_table, id);
    // Also remove user doc if it exists
    try {
      await _firestore.collection('users').doc(id).delete();
    } catch (_) {}
  }
}
