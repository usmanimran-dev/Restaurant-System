import 'package:equatable/equatable.dart';

/// Item included in a combo bundle.
class ComboItemModel extends Equatable {
  const ComboItemModel({
    required this.menuItemId,
    required this.name,
    required this.originalPrice,
    this.quantity = 1,
  });

  final String menuItemId;
  final String name;
  final double originalPrice;
  final int quantity;

  factory ComboItemModel.fromJson(Map<String, dynamic> json) {
    return ComboItemModel(
      menuItemId: json['menu_item_id'] as String,
      name: json['name'] as String,
      originalPrice: (json['original_price'] as num).toDouble(),
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_item_id': menuItemId,
      'name': name,
      'original_price': originalPrice,
      'quantity': quantity,
    };
  }

  @override
  List<Object?> get props => [menuItemId, name, originalPrice, quantity];
}

/// Combo/bundle of menu items offered at a discounted price.
class ComboModel extends Equatable {
  const ComboModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.comboPrice,
    required this.items,
    this.description,
    this.imageUrl,
    this.isAvailable = true,
  });

  final String id;
  final String restaurantId;
  final String name;
  final double comboPrice;
  final List<ComboItemModel> items;
  final String? description;
  final String? imageUrl;
  final bool isAvailable;

  /// Sum of all individual item prices.
  double get originalTotal => items.fold(0.0, (sum, i) => sum + (i.originalPrice * i.quantity));

  /// How much the customer saves with the combo.
  double get savings => originalTotal - comboPrice;

  factory ComboModel.fromJson(Map<String, dynamic> json) {
    return ComboModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String,
      comboPrice: (json['combo_price'] as num).toDouble(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((i) => ComboItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'combo_price': comboPrice,
      'items': items.map((i) => i.toJson()).toList(),
      'description': description,
      'image_url': imageUrl,
      'is_available': isAvailable,
    };
  }

  @override
  List<Object?> get props => [
        id, restaurantId, name, comboPrice, items,
        description, imageUrl, isAvailable,
      ];
}
