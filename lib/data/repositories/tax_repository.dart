import 'package:restaurant/data/models/tax_model.dart';
import 'package:restaurant/data/repositories/firestore_repository.dart';

class TaxRepository {
  TaxRepository(this._firestoreRepo);

  final FirestoreRepository _firestoreRepo;

  // ── Tax Configurations ────────────────────────────────────────────────────
  Future<List<TaxConfigurationModel>> fetchConfigurations(String restaurantId) async {
    final data = await _firestoreRepo.fetchAll('tax_configurations', restaurantId: restaurantId);
    return data.map((json) => TaxConfigurationModel.fromJson(json)).toList();
  }

  Future<TaxConfigurationModel?> getDefaultConfig(String restaurantId) async {
    final configs = await fetchConfigurations(restaurantId);
    try {
      return configs.firstWhere((c) => c.isDefault && c.isActive);
    } catch (_) {
      return configs.isNotEmpty ? configs.first : null;
    }
  }

  Future<TaxConfigurationModel> createConfiguration(TaxConfigurationModel config) async {
    final data = await _firestoreRepo.insert('tax_configurations', config.toJson());
    return TaxConfigurationModel.fromJson(data);
  }

  Future<TaxConfigurationModel> updateConfiguration(String id, Map<String, dynamic> updates) async {
    final data = await _firestoreRepo.update('tax_configurations', id, updates);
    return TaxConfigurationModel.fromJson(data);
  }

  Future<void> deleteConfiguration(String id) async {
    await _firestoreRepo.delete('tax_configurations', id);
  }

  // ── Tax Categories ────────────────────────────────────────────────────────
  Future<List<TaxCategoryModel>> fetchCategories(String restaurantId) async {
    final data = await _firestoreRepo.fetchAll('tax_categories', restaurantId: restaurantId);
    return data.map((json) => TaxCategoryModel.fromJson(json)).toList();
  }

  Future<TaxCategoryModel> createCategory(TaxCategoryModel category) async {
    final data = await _firestoreRepo.insert('tax_categories', category.toJson());
    return TaxCategoryModel.fromJson(data);
  }

  Future<void> deleteCategory(String id) async {
    await _firestoreRepo.delete('tax_categories', id);
  }

  // ── FBR Invoices ──────────────────────────────────────────────────────────
  Future<List<FbrInvoiceModel>> fetchFbrInvoices(String restaurantId) async {
    final data = await _firestoreRepo.fetchAll('fbr_invoices', restaurantId: restaurantId);
    return data.map((json) => FbrInvoiceModel.fromJson(json)).toList();
  }

  Future<FbrInvoiceModel> createFbrInvoice(FbrInvoiceModel invoice) async {
    final data = await _firestoreRepo.insert('fbr_invoices', invoice.toJson());
    return FbrInvoiceModel.fromJson(data);
  }

  Future<FbrInvoiceModel> updateFbrInvoice(String id, Map<String, dynamic> updates) async {
    final data = await _firestoreRepo.update('fbr_invoices', id, updates);
    return FbrInvoiceModel.fromJson(data);
  }
}
