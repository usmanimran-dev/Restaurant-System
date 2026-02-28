import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/discount_model.dart';

abstract class DiscountState extends Equatable {
  const DiscountState();
  @override
  List<Object?> get props => [];
}

class DiscountInitial extends DiscountState {}
class DiscountLoading extends DiscountState {}

class DiscountsLoaded extends DiscountState {
  final List<DiscountModel> discounts;
  const DiscountsLoaded(this.discounts);
  @override
  List<Object?> get props => [discounts];
}

class CouponValidated extends DiscountState {
  final DiscountModel discount;
  const CouponValidated(this.discount);
  @override
  List<Object?> get props => [discount];
}

class CouponInvalid extends DiscountState {
  final String message;
  const CouponInvalid(this.message);
  @override
  List<Object?> get props => [message];
}

class DiscountError extends DiscountState {
  final String message;
  const DiscountError(this.message);
  @override
  List<Object?> get props => [message];
}
