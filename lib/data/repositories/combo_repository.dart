import 'package:restaurant/data/models/combo_model.dart';
import 'package:restaurant/data/repositories/firestore_repository.dart';

class ComboRepository {
  ComboRepository(this._firestoreRepo);

  final FirestoreRepository _firestoreRepo;
  static const String _table = 'combos';

  Future<List<ComboModel>> fetchCombos(String restaurantId) async {
    final data = await _firestoreRepo.fetchAll(_table, restaurantId: restaurantId);
    return data.map((json) => ComboModel.fromJson(json)).toList();
  }

  Future<ComboModel> createCombo(ComboModel combo) async {
    final data = await _firestoreRepo.insert(_table, combo.toJson());
    return ComboModel.fromJson(data);
  }

  Future<ComboModel> updateCombo(String id, Map<String, dynamic> updates) async {
    final data = await _firestoreRepo.update(_table, id, updates);
    return ComboModel.fromJson(data);
  }

  Future<void> deleteCombo(String id) async {
    await _firestoreRepo.delete(_table, id);
  }
}
