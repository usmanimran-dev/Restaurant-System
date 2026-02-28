import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/cart_model.dart';
import 'package:restaurant/data/models/order_model.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class InitCart extends CartEvent {
  const InitCart(this.restaurantId, {this.tableNumber});
  final String restaurantId;
  final String? tableNumber;
  @override
  List<Object?> get props => [restaurantId, tableNumber];
}

class AddToCart extends CartEvent {
  const AddToCart(this.item);
  final CartItemModel item;
  @override
  List<Object?> get props => [item];
}

class UpdateCartItem extends CartEvent {
  const UpdateCartItem(this.itemId, this.quantity);
  final String itemId;
  final int quantity;
  @override
  List<Object?> get props => [itemId, quantity];
}

class RemoveFromCart extends CartEvent {
  const RemoveFromCart(this.itemId);
  final String itemId;
  @override
  List<Object?> get props => [itemId];
}

class SetOrderType extends CartEvent {
  const SetOrderType(this.orderType);
  final String orderType;
  @override
  List<Object?> get props => [orderType];
}

class ClearCart extends CartEvent {}

class SubmitOrder extends CartEvent {
  const SubmitOrder({required this.customerName, required this.customerPhone, required this.paymentMethod});
  final String customerName;
  final String customerPhone;
  final String paymentMethod;
  @override
  List<Object?> get props => [customerName, customerPhone, paymentMethod];
}
