import 'package:equatable/equatable.dart';

/// Represents a selected modifier applied to an order item.
class SelectedModifierModel extends Equatable {
  const SelectedModifierModel({
    required this.groupName,
    required this.name,
    required this.priceAdjustment,
  });

  final String groupName;
  final String name;
  final double priceAdjustment;

  factory SelectedModifierModel.fromJson(Map<String, dynamic> json) {
    return SelectedModifierModel(
      groupName: json['group_name'] as String,
      name: json['name'] as String,
      priceAdjustment: (json['price_adjustment'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_name': groupName,
      'name': name,
      'price_adjustment': priceAdjustment,
    };
  }

  @override
  List<Object?> get props => [groupName, name, priceAdjustment];
}

class OrderItemModel extends Equatable {
  const OrderItemModel({
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.notes,
    this.modifiers = const [],
    this.isCombo = false,
    this.comboId,
  });

  final String menuItemId;
  final String name;
  final int quantity;
  final double unitPrice;
  final String? notes;
  final List<SelectedModifierModel> modifiers;
  final bool isCombo;
  final String? comboId;

  /// Unit price including modifier adjustments.
  double get adjustedUnitPrice =>
      unitPrice + modifiers.fold(0.0, (sum, m) => sum + m.priceAdjustment);

  /// Total price for this line including modifiers × quantity.
  double get totalPrice => quantity * adjustedUnitPrice;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      menuItemId: json['menu_item_id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      notes: json['notes'] as String?,
      modifiers: (json['modifiers'] as List<dynamic>?)
              ?.map((m) => SelectedModifierModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      isCombo: json['is_combo'] as bool? ?? false,
      comboId: json['combo_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_item_id': menuItemId,
      'name': name,
      'quantity': quantity,
      'unit_price': unitPrice,
      'notes': notes,
      'modifiers': modifiers.map((m) => m.toJson()).toList(),
      'is_combo': isCombo,
      'combo_id': comboId,
    };
  }

  @override
  List<Object?> get props => [
        menuItemId, name, quantity, unitPrice, notes,
        modifiers, isCombo, comboId,
      ];
}

class OrderModel extends Equatable {
  const OrderModel({
    required this.id,
    required this.restaurantId,
    required this.employeeId,
    required this.type,
    required this.paymentMethod,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.total,
    this.discountAmount = 0,
    this.discountId,
    this.discountName,
    this.fbrInvoiceNumber,
    this.customerName,
    this.customerPhone,
    this.createdAt,
  });

  final String id;
  final String restaurantId;
  final String employeeId;
  final String type; // 'dine-in', 'takeaway', 'delivery'
  final String paymentMethod; // 'cash', 'card', 'jazzcash', 'easypaisa', 'bank_transfer'
  final String status; // 'pending', 'completed', 'cancelled'
  final List<OrderItemModel> items;
  final double subtotal;
  final double taxAmount;
  final double total;
  final double discountAmount;
  final String? discountId;
  final String? discountName;
  final String? fbrInvoiceNumber;
  final String? customerName;
  final String? customerPhone;
  final DateTime? createdAt;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      employeeId: json['employee_id'] as String,
      type: json['type'] as String,
      paymentMethod: json['payment_method'] as String,
      status: json['status'] as String,
      items: (json['items'] as List<dynamic>)
          .map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      discountId: json['discount_id'] as String?,
      discountName: json['discount_name'] as String?,
      fbrInvoiceNumber: json['fbr_invoice_number'] as String?,
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'employee_id': employeeId,
      'type': type,
      'payment_method': paymentMethod,
      'status': status,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'total': total,
      'discount_amount': discountAmount,
      'discount_id': discountId,
      'discount_name': discountName,
      'fbr_invoice_number': fbrInvoiceNumber,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id, restaurantId, employeeId, type, paymentMethod, status,
        items, subtotal, taxAmount, total, discountAmount,
        discountId, discountName, fbrInvoiceNumber,
        customerName, customerPhone, createdAt,
      ];
}
