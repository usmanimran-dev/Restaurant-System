import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/cart_model.dart';

abstract class CartState extends Equatable {
  const CartState();
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartActive extends CartState {
  const CartActive(this.cart, {this.isSubmitting = false, this.submissionError, this.submittedOrderId});
  
  final CartModel cart;
  final bool isSubmitting;
  final String? submissionError;
  final String? submittedOrderId;

  CartActive copyWith({
    CartModel? cart,
    bool? isSubmitting,
    String? submissionError,
    String? submittedOrderId,
  }) {
    return CartActive(
      cart ?? this.cart,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionError: submissionError, // Can be null
      submittedOrderId: submittedOrderId, // Can be null
    );
  }

  @override
  List<Object?> get props => [cart, isSubmitting, submissionError, submittedOrderId];
}
