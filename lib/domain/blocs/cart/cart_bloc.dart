import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/data/models/cart_model.dart';
import 'package:restaurant/data/models/order_model.dart';
import 'package:restaurant/data/repositories/order_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';
import 'package:uuid/uuid.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc({required this.orderRepository}) : super(CartInitial()) {
    on<InitCart>(_onInit);
    on<AddToCart>(_onAdd);
    on<UpdateCartItem>(_onUpdate);
    on<RemoveFromCart>(_onRemove);
    on<SetOrderType>(_onSetType);
    on<ClearCart>(_onClear);
    on<SubmitOrder>(_onSubmit);
  }

  final OrderRepository orderRepository;
  final _uuid = const Uuid();

  void _onInit(InitCart event, Emitter<CartState> emit) {
    emit(CartActive(CartModel(
      restaurantId: event.restaurantId,
      tableNumber: event.tableNumber,
    )));
  }

  void _onAdd(AddToCart event, Emitter<CartState> emit) {
    if (state is CartActive) {
      final current = (state as CartActive).cart;
      // If same item structure exists, increment quantity (excluding notes/unique id logic for simplicity here)
      emit(CartActive(current.copyWith(
        items: [...current.items, event.item],
      )));
    }
  }

  void _onUpdate(UpdateCartItem event, Emitter<CartState> emit) {
    if (state is CartActive) {
      final current = (state as CartActive).cart;
      final updatedItems = current.items.map((i) {
        if (i.id == event.itemId) return i.copyWith(quantity: event.quantity);
        return i;
      }).toList();
      emit(CartActive(current.copyWith(items: updatedItems)));
    }
  }

  void _onRemove(RemoveFromCart event, Emitter<CartState> emit) {
    if (state is CartActive) {
      final current = (state as CartActive).cart;
      final updatedItems = current.items.where((i) => i.id != event.itemId).toList();
      emit(CartActive(current.copyWith(items: updatedItems)));
    }
  }

  void _onSetType(SetOrderType event, Emitter<CartState> emit) {
    if (state is CartActive) {
      final current = (state as CartActive).cart;
      emit(CartActive(current.copyWith(orderType: event.orderType)));
    }
  }

  void _onClear(ClearCart event, Emitter<CartState> emit) {
    if (state is CartActive) {
      final current = (state as CartActive).cart;
      emit(CartActive(CartModel(restaurantId: current.restaurantId, tableNumber: current.tableNumber)));
    }
  }

  Future<void> _onSubmit(SubmitOrder event, Emitter<CartState> emit) async {
    if (state is! CartActive) return;
    final currentState = state as CartActive;
    if (currentState.cart.items.isEmpty) return;

    emit(currentState.copyWith(isSubmitting: true, submissionError: null));

    try {
      final orderId = _uuid.v4();
      final items = currentState.cart.items.map((ci) => OrderItemModel(
        menuItemId: ci.menuItem.id,
        name: ci.menuItem.name,
        quantity: ci.quantity,
        unitPrice: ci.menuItem.price,
        notes: ci.notes,
        modifiers: ci.selectedModifiers,
      )).toList();

      final order = OrderModel(
        id: orderId,
        restaurantId: currentState.cart.restaurantId,
        employeeId: 'customer_self_order', // special marker
        type: currentState.cart.orderType,
        paymentMethod: event.paymentMethod,
        status: 'pending',
        items: items,
        subtotal: currentState.cart.subtotal,
        taxAmount: currentState.cart.estimatedTax,
        total: currentState.cart.total,
        customerName: event.customerName,
        customerPhone: event.customerPhone,
        createdAt: DateTime.now(),
      );

      await orderRepository.createOrder(order);
      // Clear cart on success and indicate submission
      emit(CartActive(
        CartModel(restaurantId: currentState.cart.restaurantId, tableNumber: currentState.cart.tableNumber),
        isSubmitting: false,
        submittedOrderId: orderId,
      ));
    } catch (e) {
      emit(currentState.copyWith(isSubmitting: false, submissionError: e.toString()));
    }
  }
}
