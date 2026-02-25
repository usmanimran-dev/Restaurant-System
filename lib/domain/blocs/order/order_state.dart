import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/order_model.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<OrderModel> recentOrders;
  final List<OrderItemModel> currentCart;
  final double cartSubtotal;
  final double cartTax; // E.g., FBR 15%
  final double cartTotal;

  const OrderLoaded({
    required this.recentOrders,
    required this.currentCart,
    required this.cartSubtotal,
    required this.cartTax,
    required this.cartTotal,
  });

  @override
  List<Object?> get props => [recentOrders, currentCart, cartSubtotal, cartTax, cartTotal];

  OrderLoaded copyWith({
    List<OrderModel>? recentOrders,
    List<OrderItemModel>? currentCart,
    double? cartSubtotal,
    double? cartTax,
    double? cartTotal,
  }) {
    return OrderLoaded(
      recentOrders: recentOrders ?? this.recentOrders,
      currentCart: currentCart ?? this.currentCart,
      cartSubtotal: cartSubtotal ?? this.cartSubtotal,
      cartTax: cartTax ?? this.cartTax,
      cartTotal: cartTotal ?? this.cartTotal,
    );
  }
}

class OrderError extends OrderState {
  final String message;
  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderSubmissionSuccess extends OrderState {
  final OrderModel order;
  const OrderSubmissionSuccess(this.order);

  @override
  List<Object?> get props => [order];
}
