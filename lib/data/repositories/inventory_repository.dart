import 'package:restaurant/data/models/inventory_model.dart';
import 'package:restaurant/data/repositories/supabase_repository.dart';

class InventoryRepository {
  InventoryRepository(this._supabaseRepo);

  final SupabaseRepository _supabaseRepo;

  // ── Categories ────────────────────────────────────────────────────────────
  Future<List<InventoryCategoryModel>> fetchCategories(String restaurantId) async {
    final data = await _supabaseRepo.fetchAll('inventory_categories', restaurantId: restaurantId);
    return data.map((e) => InventoryCategoryModel.fromJson(e)).toList();
  }

  Future<InventoryCategoryModel> createCategory(InventoryCategoryModel category) async {
    final data = await _supabaseRepo.insert('inventory_categories', category.toJson());
    return InventoryCategoryModel.fromJson(data);
  }

  // ── Items ─────────────────────────────────────────────────────────────────
  Future<List<InventoryItemModel>> fetchItems(String restaurantId) async {
    final data = await _supabaseRepo.fetchAll('inventory_items', restaurantId: restaurantId);
    return data.map((e) => InventoryItemModel.fromJson(e)).toList();
  }

  Future<InventoryItemModel> createItem(InventoryItemModel item) async {
    final data = await _supabaseRepo.insert('inventory_items', item.toJson());
    return InventoryItemModel.fromJson(data);
  }

  Future<void> updateItemStock(String id, double newQuantity) async {
    await _supabaseRepo.update('inventory_items', id, {'quantity': newQuantity});
  }

  // ── Purchases ─────────────────────────────────────────────────────────────
  Future<PurchaseModel> recordPurchase(PurchaseModel purchase) async {
    // 1. Insert purchase record
    final data = await _supabaseRepo.insert('purchases', purchase.toJson());
    // 2. Fetch origin item
    final itemData = await _supabaseRepo.fetchById('inventory_items', purchase.itemId);
    if (itemData != null) {
      final currentQty = (itemData['quantity'] as num?)?.toDouble() ?? 0.0;
      await _supabaseRepo.update('inventory_items', purchase.itemId, {
        'quantity': currentQty + purchase.quantityAdded
      });
    }

    return PurchaseModel.fromJson(data);
  }

  // ── Updates and Deletes ───────────────────────────────────────────────────

  Future<InventoryCategoryModel> updateCategory(String id, Map<String, dynamic> data) async {
    final updated = await _supabaseRepo.update('inventory_categories', id, data);
    return InventoryCategoryModel.fromJson(updated);
  }

  Future<void> deleteCategory(String id) async {
    await _supabaseRepo.delete('inventory_categories', id);
  }

  Future<InventoryItemModel> updateItem(String id, Map<String, dynamic> data) async {
    final updated = await _supabaseRepo.update('inventory_items', id, data);
    return InventoryItemModel.fromJson(updated);
  }

  Future<void> deleteItem(String id) async {
    await _supabaseRepo.delete('inventory_items', id);
  }
}
