import 'package:equatable/equatable.dart';

class InventoryCategoryModel extends Equatable {
  final String id;
  final String restaurantId;
  final String name;

  const InventoryCategoryModel({
    required this.id,
    required this.restaurantId,
    required this.name,
  });

  factory InventoryCategoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryCategoryModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurant_id': restaurantId,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id, restaurantId, name];
}

class InventoryItemModel extends Equatable {
  final String id;
  final String restaurantId;
  final String categoryId;
  final String name;
  final String unit;
  final double quantity;
  final double minimumStock;

  const InventoryItemModel({
    required this.id,
    required this.restaurantId,
    required this.categoryId,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.minimumStock,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      minimumStock: (json['minimum_stock'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'restaurant_id': restaurantId,
      'category_id': categoryId,
      'name': name,
      'unit': unit,
      'quantity': quantity,
      'minimum_stock': minimumStock,
    };
  }

  InventoryItemModel copyWith({
    String? id,
    String? restaurantId,
    String? categoryId,
    String? name,
    String? unit,
    double? quantity,
    double? minimumStock,
  }) {
    return InventoryItemModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      minimumStock: minimumStock ?? this.minimumStock,
    );
  }

  @override
  List<Object?> get props =>
      [id, restaurantId, categoryId, name, unit, quantity, minimumStock];
}

class PurchaseModel extends Equatable {
  final String id;
  final String restaurantId;
  final String itemId;
  final double quantityAdded;
  final double cost;
  final DateTime date;

  const PurchaseModel({
    required this.id,
    required this.restaurantId,
    required this.itemId,
    required this.quantityAdded,
    required this.cost,
    required this.date,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      itemId: json['item_id'] as String,
      quantityAdded: (json['quantity_added'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurant_id': restaurantId,
      'item_id': itemId,
      'quantity_added': quantityAdded,
      'cost': cost,
      'date': date.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, restaurantId, itemId, quantityAdded, cost, date];
}
