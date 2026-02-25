import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/data/models/order_model.dart';
import 'package:restaurant/data/repositories/order_repository.dart';
import 'package:restaurant/domain/blocs/order/order_event.dart';
import 'package:restaurant/domain/blocs/order/order_state.dart';
import 'package:uuid/uuid.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _orderRepository;

  // In-memory cart state maintained within the BLoC during an active POS session
  final List<OrderItemModel> _cart = [];
  bool _applyFbr = false;

  OrderBloc({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(OrderInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<AddItemToCart>(_onAddItem);
    on<RemoveItemFromCart>(_onRemoveItem);
    on<SubmitOrder>(_onSubmitOrder);
  }

  void _recalculateCart(Emitter<OrderState> emit, List<OrderModel> recentOrders) {
    double subtotal = 0;
    for (var item in _cart) {
      subtotal += item.totalPrice;
    }
    
    // Example GST/FBR rate of 16% if applied
    double tax = _applyFbr ? (subtotal * 0.16) : 0;
    double total = subtotal + tax;

    emit(OrderLoaded(
      recentOrders: recentOrders,
      currentCart: List.from(_cart),
      cartSubtotal: subtotal,
      cartTax: tax,
      cartTotal: total,
    ));
  }

  Future<void> _onLoadOrders(LoadOrders event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final orders = await _orderRepository.fetchOrders(event.restaurantId);
      _recalculateCart(emit, orders);
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  void _onAddItem(AddItemToCart event, Emitter<OrderState> emit) {
    final existingIndex = _cart.indexWhere((i) => i.menuItemId == event.item.menuItemId);
    
    if (existingIndex >= 0) {
      final existing = _cart[existingIndex];
      _cart[existingIndex] = OrderItemModel(
        menuItemId: existing.menuItemId,
        name: existing.name,
        quantity: existing.quantity + event.item.quantity,
        unitPrice: existing.unitPrice,
        notes: existing.notes ?? event.item.notes,
      );
    } else {
      _cart.add(event.item);
    }

    final currentState = state;
    if (currentState is OrderLoaded) {
      _recalculateCart(emit, currentState.recentOrders);
    }
  }

  void _onRemoveItem(RemoveItemFromCart event, Emitter<OrderState> emit) {
    _cart.removeWhere((item) => item.menuItemId == event.menuItemId);
    final currentState = state;
    if (currentState is OrderLoaded) {
      _recalculateCart(emit, currentState.recentOrders);
    }
  }

  Future<void> _onSubmitOrder(SubmitOrder event, Emitter<OrderState> emit) async {
    final currentState = state;
    if (currentState is! OrderLoaded || _cart.isEmpty) return;
    
    _applyFbr = event.applyFbrTax;
    final recentOrders = currentState.recentOrders;
    
    // final calculation before save
    double subtotal = 0;
    for (var item in _cart) {
      subtotal += item.totalPrice;
    }
    double tax = _applyFbr ? (subtotal * 0.16) : 0;
    double total = subtotal + tax;

    try {
      final newOrder = OrderModel(
        id: '', // Supabase generated
        restaurantId: event.restaurantId,
        employeeId: event.employeeId,
        type: event.type,
        paymentMethod: event.paymentMethod,
        status: 'completed',
        items: _cart,
        subtotal: subtotal,
        taxAmount: tax,
        total: total,
        fbrInvoiceNumber: _applyFbr ? 'FBR-${const Uuid().v4().substring(0, 8).toUpperCase()}' : null,
      );

      final createdOrder = await _orderRepository.createOrder(newOrder);
      
      // Clear cart
      _cart.clear();
      _applyFbr = false;
      
      emit(OrderSubmissionSuccess(createdOrder));
      add(LoadOrders(event.restaurantId));
    } catch (e) {
      emit(OrderError(e.toString()));
      _recalculateCart(emit, recentOrders); // Restore
    }
  }
}
