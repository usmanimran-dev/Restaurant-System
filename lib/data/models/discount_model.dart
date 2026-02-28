import 'package:equatable/equatable.dart';

enum DiscountType { percentage, fixedAmount }

/// A discount/coupon that can be applied to an order.
class DiscountModel extends Equatable {
  const DiscountModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.type,
    required this.value,
    this.code,
    this.minOrderAmount = 0,
    this.maxDiscountAmount,
    this.isActive = true,
    this.usageLimit,
    this.usageCount = 0,
    this.startDate,
    this.endDate,
    this.createdAt,
  });

  final String id;
  final String restaurantId;
  final String name;
  final DiscountType type;
  final double value; // percentage (0-100) or fixed amount
  final String? code; // coupon code
  final double minOrderAmount;
  final double? maxDiscountAmount; // cap on percentage discounts
  final bool isActive;
  final int? usageLimit;
  final int usageCount;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;

  /// Calculates actual discount amount for a given subtotal.
  double calculateDiscount(double subtotal) {
    if (subtotal < minOrderAmount) return 0;
    double discount;
    if (type == DiscountType.percentage) {
      discount = subtotal * (value / 100);
      if (maxDiscountAmount != null && discount > maxDiscountAmount!) {
        discount = maxDiscountAmount!;
      }
    } else {
      discount = value;
    }
    return discount > subtotal ? subtotal : discount;
  }

  /// Whether this discount is currently valid.
  bool get isValid {
    if (!isActive) return false;
    if (usageLimit != null && usageCount >= usageLimit!) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String,
      type: json['type'] == 'percentage'
          ? DiscountType.percentage
          : DiscountType.fixedAmount,
      value: (json['value'] as num).toDouble(),
      code: json['code'] as String?,
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble() ?? 0,
      maxDiscountAmount: (json['max_discount_amount'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      usageLimit: json['usage_limit'] as int?,
      usageCount: json['usage_count'] as int? ?? 0,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'type': type == DiscountType.percentage ? 'percentage' : 'fixed_amount',
      'value': value,
      'code': code,
      'min_order_amount': minOrderAmount,
      'max_discount_amount': maxDiscountAmount,
      'is_active': isActive,
      'usage_limit': usageLimit,
      'usage_count': usageCount,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id, restaurantId, name, type, value, code,
        minOrderAmount, maxDiscountAmount, isActive,
        usageLimit, usageCount, startDate, endDate,
      ];
}
