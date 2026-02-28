import 'package:equatable/equatable.dart';

/// Supplier entity.
class SupplierModel extends Equatable {
  const SupplierModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.paymentTerms,
    this.leadTimeDays = 3,
    this.qualityRating = 5.0,
    this.reliabilityRating = 5.0,
    this.isActive = true,
  });

  final String id;
  final String restaurantId;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? paymentTerms;
  final int leadTimeDays;
  final double qualityRating;
  final double reliabilityRating;
  final bool isActive;

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      address: json['address'] as String?,
      paymentTerms: json['payment_terms'] as String?,
      leadTimeDays: json['lead_time_days'] as int? ?? 3,
      qualityRating: (json['quality_rating'] as num?)?.toDouble() ?? 5.0,
      reliabilityRating: (json['reliability_rating'] as num?)?.toDouble() ?? 5.0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'restaurant_id': restaurantId,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'payment_terms': paymentTerms,
        'lead_time_days': leadTimeDays,
        'quality_rating': qualityRating,
        'reliability_rating': reliabilityRating,
        'is_active': isActive,
      };

  @override
  List<Object?> get props => [id, restaurantId, name, phone, isActive];
}

/// Purchase order status workflow.
enum PurchaseOrderStatus { draft, pending, confirmed, partiallyReceived, received, invoiced, paid }

/// Purchase order model.
class PurchaseOrderModel extends Equatable {
  const PurchaseOrderModel({
    required this.id,
    required this.restaurantId,
    required this.supplierId,
    required this.supplierName,
    required this.items,
    this.status = PurchaseOrderStatus.draft,
    this.totalAmount = 0,
    this.expectedDeliveryDate,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String restaurantId;
  final String supplierId;
  final String supplierName;
  final List<PurchaseOrderItemModel> items;
  final PurchaseOrderStatus status;
  final double totalAmount;
  final DateTime? expectedDeliveryDate;
  final String? notes;
  final DateTime? createdAt;

  factory PurchaseOrderModel.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      supplierId: json['supplier_id'] as String,
      supplierName: json['supplier_name'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => PurchaseOrderItemModel.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      status: PurchaseOrderStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'draft'),
        orElse: () => PurchaseOrderStatus.draft,
      ),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      expectedDeliveryDate: json['expected_delivery_date'] != null
          ? DateTime.parse(json['expected_delivery_date'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'restaurant_id': restaurantId,
        'supplier_id': supplierId,
        'supplier_name': supplierName,
        'items': items.map((i) => i.toJson()).toList(),
        'status': status.name,
        'total_amount': totalAmount,
        'expected_delivery_date': expectedDeliveryDate?.toIso8601String(),
        'notes': notes,
        'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      };

  @override
  List<Object?> get props => [id, restaurantId, supplierId, status, totalAmount, createdAt];
}

/// Individual item within a purchase order.
class PurchaseOrderItemModel extends Equatable {
  const PurchaseOrderItemModel({
    required this.inventoryItemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    this.receivedQuantity = 0,
  });

  final String inventoryItemId;
  final String itemName;
  final double quantity;
  final double unitPrice;
  final double receivedQuantity;

  double get totalPrice => quantity * unitPrice;

  factory PurchaseOrderItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItemModel(
      inventoryItemId: json['inventory_item_id'] as String,
      itemName: json['item_name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      receivedQuantity: (json['received_quantity'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'inventory_item_id': inventoryItemId,
        'item_name': itemName,
        'quantity': quantity,
        'unit_price': unitPrice,
        'received_quantity': receivedQuantity,
      };

  @override
  List<Object?> get props => [inventoryItemId, itemName, quantity, unitPrice, receivedQuantity];
}
