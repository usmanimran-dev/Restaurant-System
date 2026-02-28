import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/data/repositories/discount_repository.dart';
import 'package:restaurant/domain/blocs/discount/discount_event.dart';
import 'package:restaurant/domain/blocs/discount/discount_state.dart';

class DiscountBloc extends Bloc<DiscountEvent, DiscountState> {
  final DiscountRepository _discountRepository;

  DiscountBloc({required DiscountRepository discountRepository})
      : _discountRepository = discountRepository,
        super(DiscountInitial()) {
    on<LoadDiscounts>(_onLoad);
    on<CreateDiscount>(_onCreate);
    on<UpdateDiscount>(_onUpdate);
    on<DeleteDiscount>(_onDelete);
    on<ValidateCouponCode>(_onValidateCoupon);
  }

  Future<void> _onLoad(LoadDiscounts event, Emitter<DiscountState> emit) async {
    emit(DiscountLoading());
    try {
      final discounts = await _discountRepository.fetchDiscounts(event.restaurantId);
      emit(DiscountsLoaded(discounts));
    } catch (e) {
      emit(DiscountError(e.toString()));
    }
  }

  Future<void> _onCreate(CreateDiscount event, Emitter<DiscountState> emit) async {
    try {
      await _discountRepository.createDiscount(event.discount);
      add(LoadDiscounts(event.discount.restaurantId));
    } catch (e) {
      emit(DiscountError(e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateDiscount event, Emitter<DiscountState> emit) async {
    try {
      await _discountRepository.updateDiscount(event.id, event.updates);
      add(LoadDiscounts(event.restaurantId));
    } catch (e) {
      emit(DiscountError(e.toString()));
    }
  }

  Future<void> _onDelete(DeleteDiscount event, Emitter<DiscountState> emit) async {
    try {
      await _discountRepository.deleteDiscount(event.id);
      add(LoadDiscounts(event.restaurantId));
    } catch (e) {
      emit(DiscountError(e.toString()));
    }
  }

  Future<void> _onValidateCoupon(ValidateCouponCode event, Emitter<DiscountState> emit) async {
    try {
      final discount = await _discountRepository.findByCode(event.restaurantId, event.code);
      if (discount != null) {
        emit(CouponValidated(discount));
      } else {
        emit(const CouponInvalid('Invalid or expired coupon code.'));
      }
    } catch (e) {
      emit(DiscountError(e.toString()));
    }
  }
}
