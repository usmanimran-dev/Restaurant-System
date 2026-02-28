import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/discount_model.dart';

abstract class DiscountEvent extends Equatable {
  const DiscountEvent();
  @override
  List<Object?> get props => [];
}

class LoadDiscounts extends DiscountEvent {
  final String restaurantId;
  const LoadDiscounts(this.restaurantId);
  @override
  List<Object?> get props => [restaurantId];
}

class CreateDiscount extends DiscountEvent {
  final DiscountModel discount;
  const CreateDiscount(this.discount);
  @override
  List<Object?> get props => [discount];
}

class UpdateDiscount extends DiscountEvent {
  final String id;
  final Map<String, dynamic> updates;
  final String restaurantId;
  const UpdateDiscount(this.id, this.updates, this.restaurantId);
  @override
  List<Object?> get props => [id, updates, restaurantId];
}

class DeleteDiscount extends DiscountEvent {
  final String id;
  final String restaurantId;
  const DeleteDiscount(this.id, this.restaurantId);
  @override
  List<Object?> get props => [id, restaurantId];
}

class ValidateCouponCode extends DiscountEvent {
  final String restaurantId;
  final String code;
  const ValidateCouponCode(this.restaurantId, this.code);
  @override
  List<Object?> get props => [restaurantId, code];
}
