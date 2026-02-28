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
  double _taxRate = 0.0; // Configurable tax rate (e.g., 0.17 for 17% GST)
  double _discountAmount = 0.0;
  String? _discountId;
  String? _discountName;


  OrderBloc({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(OrderInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<AddItemToCart>(_onAddItem);
    on<RemoveItemFromCart>(_onRemoveItem);
    on<UpdateCartItemQuantity>(_onUpdateQuantity);
    on<ApplyDiscount>(_onApplyDiscount);
    on<RemoveDiscount>(_onRemoveDiscount);
    on<SetTaxRate>(_onSetTaxRate);
    on<ClearCart>(_onClearCart);
    on<SubmitOrder>(_onSubmitOrder);
  }

  void _recalculateCart(Emitter<OrderState> emit, List<OrderModel> recentOrders) {
    double subtotal = 0;
    for (var item in _cart) {
      subtotal += item.totalPrice;
    }

    double tax = subtotal * _taxRate;
    double total = subtotal - _discountAmount + tax;
    if (total < 0) total = 0;

    emit(OrderLoaded(
      recentOrders: recentOrders,
      currentCart: List.from(_cart),
      cartSubtotal: subtotal,
      cartDiscount: _discountAmount,
      discountId: _discountId,
      discountName: _discountName,
      cartTax: tax,
      taxRate: _taxRate,
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
    // Check if same item with same modifiers already exists
    final existingIndex = _cart.indexWhere((i) =>
        i.menuItemId == event.item.menuItemId &&
        _modifiersMatch(i.modifiers, event.item.modifiers));

    if (existingIndex >= 0) {
      final existing = _cart[existingIndex];
      _cart[existingIndex] = OrderItemModel(
        menuItemId: existing.menuItemId,
        name: existing.name,
        quantity: existing.quantity + event.item.quantity,
        unitPrice: existing.unitPrice,
        notes: event.item.notes ?? existing.notes,
        modifiers: existing.modifiers,
        isCombo: existing.isCombo,
        comboId: existing.comboId,
      );
    } else {
      _cart.add(event.item);
    }

    final currentState = state;
    if (currentState is OrderLoaded) {
      _recalculateCart(emit, currentState.recentOrders);
    }
  }

  bool _modifiersMatch(
      List<SelectedModifierModel> a, List<SelectedModifierModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].name != b[i].name || a[i].groupName != b[i].groupName) {
        return false;
      }
    }
    return true;
  }

  void _onRemoveItem(RemoveItemFromCart event, Emitter<OrderState> emit) {
    _cart.removeWhere((item) => item.menuItemId == event.menuItemId);
    final currentState = state;
    if (currentState is OrderLoaded) {
      _recalculateCart(emit, currentState.recentOrders);
    }
  }

  void _onUpdateQuantity(UpdateCartItemQuantity event, Emitter<OrderState> emit) {
    final index = _cart.indexWhere((i) => i.menuItemId == event.menuItemId);
    if (index >= 0) {
      if (event.newQuantity <= 0) {
        _cart.removeAt(index);
      } else {
        final existing = _cart[index];
        _cart[index] = OrderItemModel(
          menuItemId: existing.menuItemId,
          name: existing.name,
          quantity: event.newQuantity,
          unitPrice: existing.unitPrice,
          notes: existing.notes,
          modifiers: existing.modifiers,
          isCombo: existing.isCombo,
          comboId: existing.comboId,
        );
      }
    }
    final currentState = state;
    if (currentState is OrderLoaded) {
      _recalculateCart(emit, currentState.recentOrders);
    }
  }

  void _onApplyDiscount(ApplyDiscount event, Emitter<OrderState> emit) {
    _discountAmount = event.amount;
    _discountId = event.discountId;
    _discountName = event.discountName;
    final currentState = state;
    if (currentState is OrderLoaded) {
      _recalculateCart(emit, currentState.recentOrders);
    }
  }

  void _onRemoveDiscount(RemoveDiscount event, Emitter<OrderState> emit) {
    _discountAmount = 0;
    _discountId = null;
    _discountName = null;
    final currentState = state;
    if (currentState is OrderLoaded) {
      _recalculateCart(emit, currentState.recentOrders);
    }
  }

  void _onSetTaxRate(SetTaxRate event, Emitter<OrderState> emit) {
    _taxRate = event.rate;
    final currentState = state;
    if (currentState is OrderLoaded) {
      _recalculateCart(emit, currentState.recentOrders);
    }
  }

  void _onClearCart(ClearCart event, Emitter<OrderState> emit) {
    _cart.clear();
    _discountAmount = 0;
    _discountId = null;
    _discountName = null;
    final currentState = state;
    if (currentState is OrderLoaded) {
      _recalculateCart(emit, currentState.recentOrders);
    }
  }

  Future<void> _onSubmitOrder(SubmitOrder event, Emitter<OrderState> emit) async {
    final currentState = state;
    if (currentState is! OrderLoaded || _cart.isEmpty) return;

    final recentOrders = currentState.recentOrders;

    // Final calculation before save
    double subtotal = 0;
    for (var item in _cart) {
      subtotal += item.totalPrice;
    }
    double tax = subtotal * _taxRate;
    double total = subtotal - _discountAmount + tax;
    if (total < 0) total = 0;

    try {
      final newOrder = OrderModel(
        id: '', // Firestore generated
        restaurantId: event.restaurantId,
        employeeId: event.employeeId,
        type: event.type,
        paymentMethod: event.paymentMethod,
        status: 'pending',
        items: List.from(_cart),
        subtotal: subtotal,
        taxAmount: tax,
        total: total,
        discountAmount: _discountAmount,
        discountId: _discountId,
        discountName: _discountName,
        fbrInvoiceNumber: _taxRate > 0
            ? 'FBR-${const Uuid().v4().substring(0, 8).toUpperCase()}'
            : null,
        customerName: event.customerName,
        customerPhone: event.customerPhone,
      );

      final createdOrder = await _orderRepository.createOrder(newOrder);

      // Clear cart
      _cart.clear();
      _discountAmount = 0;
      _discountId = null;
      _discountName = null;

      emit(OrderSubmissionSuccess(createdOrder));
      add(LoadOrders(event.restaurantId));
    } catch (e) {
      emit(OrderError(e.toString()));
      _recalculateCart(emit, recentOrders); // Restore
    }
  }
}
