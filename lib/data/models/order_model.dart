import 'package:equatable/equatable.dart';

class OrderItemModel extends Equatable {
  const OrderItemModel({
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.notes,
  });

  final String menuItemId;
  final String name;
  final int quantity;
  final double unitPrice;
  final String? notes;

  double get totalPrice => quantity * unitPrice;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      menuItemId: json['menu_item_id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_item_id': menuItemId,
      'name': name,
      'quantity': quantity,
      'unit_price': unitPrice,
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [menuItemId, name, quantity, unitPrice, notes];
}

class OrderModel extends Equatable {
  const OrderModel({
    required this.id,
    required this.restaurantId,
    required this.employeeId,
    required this.type, // 'dine-in', 'takeaway', 'delivery'
    required this.paymentMethod, // 'cash', 'card'
    required this.status, // 'pending', 'completed', 'cancelled'
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.total,
    this.fbrInvoiceNumber,
    this.createdAt,
  });

  final String id;
  final String restaurantId;
  final String employeeId;
  final String type;
  final String paymentMethod;
  final String status;
  final List<OrderItemModel> items;
  final double subtotal;
  final double taxAmount;
  final double total;
  final String? fbrInvoiceNumber;
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
      fbrInvoiceNumber: json['fbr_invoice_number'] as String?,
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
      'fbr_invoice_number': fbrInvoiceNumber,
    };
  }

  @override
  List<Object?> get props => [
        id, restaurantId, employeeId, type, paymentMethod, status,
        items, subtotal, taxAmount, total, fbrInvoiceNumber, createdAt
      ];
}
