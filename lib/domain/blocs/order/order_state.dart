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
  final double cartDiscount;
  final String? discountId;
  final String? discountName;
  final double cartTax;
  final double taxRate;
  final double cartTotal;

  const OrderLoaded({
    required this.recentOrders,
    required this.currentCart,
    required this.cartSubtotal,
    this.cartDiscount = 0,
    this.discountId,
    this.discountName,
    required this.cartTax,
    this.taxRate = 0,
    required this.cartTotal,
  });

  @override
  List<Object?> get props => [
        recentOrders, currentCart, cartSubtotal, cartDiscount,
        discountId, discountName, cartTax, taxRate, cartTotal,
      ];

  OrderLoaded copyWith({
    List<OrderModel>? recentOrders,
    List<OrderItemModel>? currentCart,
    double? cartSubtotal,
    double? cartDiscount,
    String? discountId,
    String? discountName,
    double? cartTax,
    double? taxRate,
    double? cartTotal,
  }) {
    return OrderLoaded(
      recentOrders: recentOrders ?? this.recentOrders,
      currentCart: currentCart ?? this.currentCart,
      cartSubtotal: cartSubtotal ?? this.cartSubtotal,
      cartDiscount: cartDiscount ?? this.cartDiscount,
      discountId: discountId ?? this.discountId,
      discountName: discountName ?? this.discountName,
      cartTax: cartTax ?? this.cartTax,
      taxRate: taxRate ?? this.taxRate,
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
