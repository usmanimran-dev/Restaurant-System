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

class UpdateCartItemQuantity extends OrderEvent {
  final String menuItemId;
  final int newQuantity;
  const UpdateCartItemQuantity(this.menuItemId, this.newQuantity);

  @override
  List<Object?> get props => [menuItemId, newQuantity];
}

class ApplyDiscount extends OrderEvent {
  final double amount;
  final String? discountId;
  final String? discountName;
  const ApplyDiscount({required this.amount, this.discountId, this.discountName});

  @override
  List<Object?> get props => [amount, discountId, discountName];
}

class RemoveDiscount extends OrderEvent {
  const RemoveDiscount();
}

class SetTaxRate extends OrderEvent {
  final double rate; // e.g., 0.17 for 17%
  const SetTaxRate(this.rate);

  @override
  List<Object?> get props => [rate];
}

class ClearCart extends OrderEvent {
  const ClearCart();
}

class SubmitOrder extends OrderEvent {
  final String restaurantId;
  final String employeeId;
  final String type;
  final String paymentMethod;
  final String? customerName;
  final String? customerPhone;

  const SubmitOrder({
    required this.restaurantId,
    required this.employeeId,
    required this.type,
    required this.paymentMethod,
    this.customerName,
    this.customerPhone,
  });

  @override
  List<Object?> get props => [
        restaurantId, employeeId, type, paymentMethod,
        customerName, customerPhone,
      ];
}
