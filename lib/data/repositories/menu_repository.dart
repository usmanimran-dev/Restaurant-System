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
}
