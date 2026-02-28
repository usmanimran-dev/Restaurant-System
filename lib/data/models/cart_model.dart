import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/menu_model.dart';
import 'package:restaurant/data/models/order_model.dart';

/// Represents an item in the customer's shopping cart.
class CartItemModel extends Equatable {
  const CartItemModel({
    required this.id,
    required this.menuItem,
    required this.quantity,
    this.selectedModifiers = const [],
    this.notes,
  });

  final String id; // Unique ID for the cart item instance
  final MenuItemModel menuItem;
  final int quantity;
  final List<SelectedModifierModel> selectedModifiers;
  final String? notes;

  double get unitPrice =>
      menuItem.price + selectedModifiers.fold(0.0, (sum, m) => sum + m.priceAdjustment);

  double get totalPrice => unitPrice * quantity;

  CartItemModel copyWith({
    int? quantity,
    List<SelectedModifierModel>? selectedModifiers,
    String? notes,
  }) {
    return CartItemModel(
      id: id,
      menuItem: menuItem,
      quantity: quantity ?? this.quantity,
      selectedModifiers: selectedModifiers ?? this.selectedModifiers,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [id, menuItem, quantity, selectedModifiers, notes];
}

/// Represents the customer's current shopping session.
class CartModel extends Equatable {
  const CartModel({
    required this.restaurantId,
    this.items = const [],
    this.orderType = 'dine-in',
    this.tableNumber,
  });

  final String restaurantId;
  final List<CartItemModel> items;
  final String orderType; // 'dine-in', 'takeaway', 'delivery'
  final String? tableNumber;

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  // Tax logic could be moved here or calculated server-side
  double get estimatedTax => subtotal * 0.16; // Example 16% GST
  double get total => subtotal + estimatedTax;

  CartModel copyWith({
    String? restaurantId,
    List<CartItemModel>? items,
    String? orderType,
    String? tableNumber,
  }) {
    return CartModel(
      restaurantId: restaurantId ?? this.restaurantId,
      items: items ?? this.items,
      orderType: orderType ?? this.orderType,
      tableNumber: tableNumber ?? this.tableNumber,
    );
  }

  @override
  List<Object?> get props => [restaurantId, items, orderType, tableNumber];
}
