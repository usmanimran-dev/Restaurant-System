import 'package:restaurant/data/models/menu_model.dart';
import 'package:restaurant/data/repositories/supabase_repository.dart';

class MenuRepository {
  MenuRepository(this._supabaseRepo);

  final SupabaseRepository _supabaseRepo;

  Future<List<MenuCategoryModel>> fetchCategories(String restaurantId) async {
    final data = await _supabaseRepo.fetchAll('menu_categories', restaurantId: restaurantId);
    return data.map((json) => MenuCategoryModel.fromJson(json)).toList();
  }

  Future<List<MenuItemModel>> fetchItems(String restaurantId) async {
    final data = await _supabaseRepo.fetchAll('menu_items', restaurantId: restaurantId);
    return data.map((json) => MenuItemModel.fromJson(json)).toList();
  }

  Future<MenuCategoryModel> createCategory(MenuCategoryModel category) async {
    final data = await _supabaseRepo.insert('menu_categories', category.toJson());
    return MenuCategoryModel.fromJson(data);
  }

  Future<MenuItemModel> createItem(MenuItemModel item) async {
    final data = await _supabaseRepo.insert('menu_items', item.toJson());
    return MenuItemModel.fromJson(data);
  }

  Future<MenuCategoryModel> updateCategory(String id, Map<String, dynamic> data) async {
    final updated = await _supabaseRepo.update('menu_categories', id, data);
    return MenuCategoryModel.fromJson(updated);
  }

  Future<void> deleteCategory(String id) async {
    await _supabaseRepo.delete('menu_categories', id);
  }

  Future<MenuItemModel> updateItem(String id, Map<String, dynamic> data) async {
    final updated = await _supabaseRepo.update('menu_items', id, data);
    return MenuItemModel.fromJson(updated);
  }

  Future<void> deleteItem(String id) async {
    await _supabaseRepo.delete('menu_items', id);
  }
}
