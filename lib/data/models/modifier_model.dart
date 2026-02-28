import 'package:equatable/equatable.dart';

/// A group of modifiers (e.g., "Size", "Toppings", "Sauce").
class ModifierGroupModel extends Equatable {
  const ModifierGroupModel({
    required this.id,
    required this.restaurantId,
    required this.menuItemId,
    required this.name,
    this.isRequired = false,
    this.maxSelections = 1,
    this.minSelections = 0,
    this.sortOrder = 0,
  });

  final String id;
  final String restaurantId;
  final String menuItemId;
  final String name;
  final bool isRequired;
  final int maxSelections;
  final int minSelections;
  final int sortOrder;

  factory ModifierGroupModel.fromJson(Map<String, dynamic> json) {
    return ModifierGroupModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      menuItemId: json['menu_item_id'] as String,
      name: json['name'] as String,
      isRequired: json['is_required'] as bool? ?? false,
      maxSelections: json['max_selections'] as int? ?? 1,
      minSelections: json['min_selections'] as int? ?? 0,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'menu_item_id': menuItemId,
      'name': name,
      'is_required': isRequired,
      'max_selections': maxSelections,
      'min_selections': minSelections,
      'sort_order': sortOrder,
    };
  }

  @override
  List<Object?> get props => [
        id, restaurantId, menuItemId, name,
        isRequired, maxSelections, minSelections, sortOrder,
      ];
}

/// An individual modifier option (e.g., "Large +100", "Extra Cheese +50").
class ModifierItemModel extends Equatable {
  const ModifierItemModel({
    required this.id,
    required this.groupId,
    required this.name,
    required this.priceAdjustment,
    this.isDefault = false,
    this.sortOrder = 0,
  });

  final String id;
  final String groupId;
  final String name;
  final double priceAdjustment;
  final bool isDefault;
  final int sortOrder;

  factory ModifierItemModel.fromJson(Map<String, dynamic> json) {
    return ModifierItemModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      name: json['name'] as String,
      priceAdjustment: (json['price_adjustment'] as num).toDouble(),
      isDefault: json['is_default'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'name': name,
      'price_adjustment': priceAdjustment,
      'is_default': isDefault,
      'sort_order': sortOrder,
    };
  }

  @override
  List<Object?> get props => [id, groupId, name, priceAdjustment, isDefault, sortOrder];
}
