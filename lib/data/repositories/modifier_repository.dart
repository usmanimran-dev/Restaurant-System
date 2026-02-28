import 'package:restaurant/data/models/modifier_model.dart';
import 'package:restaurant/data/repositories/firestore_repository.dart';

class ModifierRepository {
  ModifierRepository(this._firestoreRepo);

  final FirestoreRepository _firestoreRepo;

  // ── Modifier Groups ───────────────────────────────────────────────────────
  Future<List<ModifierGroupModel>> fetchGroups(String menuItemId) async {
    final data = await _firestoreRepo.fetchAll('modifier_groups');
    return data
        .where((d) => d['menu_item_id'] == menuItemId)
        .map((json) => ModifierGroupModel.fromJson(json))
        .toList();
  }

  Future<List<ModifierGroupModel>> fetchGroupsByRestaurant(String restaurantId) async {
    final data = await _firestoreRepo.fetchAll('modifier_groups', restaurantId: restaurantId);
    return data.map((json) => ModifierGroupModel.fromJson(json)).toList();
  }

  Future<ModifierGroupModel> createGroup(ModifierGroupModel group) async {
    final data = await _firestoreRepo.insert('modifier_groups', group.toJson());
    return ModifierGroupModel.fromJson(data);
  }

  Future<ModifierGroupModel> updateGroup(String id, Map<String, dynamic> updates) async {
    final data = await _firestoreRepo.update('modifier_groups', id, updates);
    return ModifierGroupModel.fromJson(data);
  }

  Future<void> deleteGroup(String id) async {
    // Also delete all modifier items in this group
    final items = await fetchItems(id);
    for (var item in items) {
      await _firestoreRepo.delete('modifier_items', item.id);
    }
    await _firestoreRepo.delete('modifier_groups', id);
  }

  // ── Modifier Items ────────────────────────────────────────────────────────
  Future<List<ModifierItemModel>> fetchItems(String groupId) async {
    final data = await _firestoreRepo.fetchAll('modifier_items');
    return data
        .where((d) => d['group_id'] == groupId)
        .map((json) => ModifierItemModel.fromJson(json))
        .toList();
  }

  Future<ModifierItemModel> createItem(ModifierItemModel item) async {
    // Firestore rules require restaurant_id; get it from the parent group
    final group = await _firestoreRepo.fetchById('modifier_groups', item.groupId);
    final json = item.toJson();
    if (group != null && group['restaurant_id'] != null) {
      json['restaurant_id'] = group['restaurant_id'];
    }
    final data = await _firestoreRepo.insert('modifier_items', json);
    return ModifierItemModel.fromJson(data);
  }

  Future<ModifierItemModel> updateItem(String id, Map<String, dynamic> updates) async {
    final data = await _firestoreRepo.update('modifier_items', id, updates);
    return ModifierItemModel.fromJson(data);
  }

  Future<void> deleteItem(String id) async {
    await _firestoreRepo.delete('modifier_items', id);
  }
}
