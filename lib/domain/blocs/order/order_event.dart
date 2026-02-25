import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/order_model.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrderEvent {
  final String restaurantId;
  const LoadOrders(this.restaurantId);

  @override
  List<Object?> get props => [restaurantId];
}

class AddItemToCart extends OrderEvent {
  final OrderItemModel item;
  const AddItemToCart(this.item);

  @override
  List<Object?> get props => [item];
}

class RemoveItemFromCart extends OrderEvent {
  final String menuItemId;
  const RemoveItemFromCart(this.menuItemId);

  @override
  List<Object?> get props => [menuItemId];
}

class SubmitOrder extends OrderEvent {
  final String restaurantId;
  final String employeeId;
  final String type;
  final String paymentMethod;
  final bool applyFbrTax;

  const SubmitOrder({
    required this.restaurantId,
    required this.employeeId,
    required this.type,
    required this.paymentMethod,
    this.applyFbrTax = false,
  });

  @override
  List<Object?> get props => [restaurantId, employeeId, type, paymentMethod, applyFbrTax];
}
