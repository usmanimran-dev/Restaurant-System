import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

/// Now backed by Firebase Firestore! (Kept class name for DI compatibility)
class SupabaseRepository {
  SupabaseRepository();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  Future<List<Map<String, dynamic>>> fetchAll(
    String table, {
    String? restaurantId,
    String? select,
  }) async {
    Query query = _firestore.collection(table);
    if (restaurantId != null) {
      query = query.where('restaurant_id', isEqualTo: restaurantId);
    }
    
    final snapshot = await query.get();
    return snapshot.docs.map((d) {
      final docData = d.data() as Map<String, dynamic>;
      docData['id'] = d.id;
      return docData;
    }).toList();
  }

  Future<Map<String, dynamic>?> fetchById(
    String table,
    String id, {
    String? select,
  }) async {
    final doc = await _firestore.collection(table).doc(id).get();
    if (!doc.exists) return null;
    
    final data = doc.data()!;
    data['id'] = doc.id;
    return data;
  }

  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    final newId = (data['id'] == null || data['id'].isEmpty) ? _uuid.v4() : data['id'];
    data['id'] = newId;
    
    await _firestore.collection(table).doc(newId).set(data);
    return data;
  }

  Future<Map<String, dynamic>> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(table).doc(id).update(data);
    
    // Firestore update doesn't return the full doc, so we fetch it
    final doc = await _firestore.collection(table).doc(id).get();
    final updatedData = doc.data()!;
    updatedData['id'] = doc.id;
    return updatedData;
  }

  Future<void> delete(String table, String id) async {
    await _firestore.collection(table).doc(id).delete();
  }
}
