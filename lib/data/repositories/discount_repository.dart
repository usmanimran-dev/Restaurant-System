import 'package:restaurant/data/models/discount_model.dart';
import 'package:restaurant/data/repositories/firestore_repository.dart';

class DiscountRepository {
  DiscountRepository(this._firestoreRepo);

  final FirestoreRepository _firestoreRepo;
  static const String _table = 'discounts';

  Future<List<DiscountModel>> fetchDiscounts(String restaurantId) async {
    final data = await _firestoreRepo.fetchAll(_table, restaurantId: restaurantId);
    return data.map((json) => DiscountModel.fromJson(json)).toList();
  }

  Future<DiscountModel> createDiscount(DiscountModel discount) async {
    final data = await _firestoreRepo.insert(_table, discount.toJson());
    return DiscountModel.fromJson(data);
  }

  Future<DiscountModel> updateDiscount(String id, Map<String, dynamic> updates) async {
    final data = await _firestoreRepo.update(_table, id, updates);
    return DiscountModel.fromJson(data);
  }

  Future<void> deleteDiscount(String id) async {
    await _firestoreRepo.delete(_table, id);
  }

  /// Validates and finds a discount by coupon code.
  Future<DiscountModel?> findByCode(String restaurantId, String code) async {
    final discounts = await fetchDiscounts(restaurantId);
    try {
      return discounts.firstWhere(
        (d) => d.code?.toLowerCase() == code.toLowerCase() && d.isValid,
      );
    } catch (_) {
      return null;
    }
  }

  /// Increments the usage count of a discount.
  Future<void> recordUsage(String discountId) async {
    final data = await _firestoreRepo.fetchById(_table, discountId);
    if (data != null) {
      final currentCount = data['usage_count'] as int? ?? 0;
      await _firestoreRepo.update(_table, discountId, {
        'usage_count': currentCount + 1,
      });
    }
  }
}
