import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/data/models/kds_model.dart';
import 'package:restaurant/data/repositories/kds_repository.dart';
import 'kds_event.dart';
import 'kds_state.dart';

class KdsBloc extends Bloc<KdsEvent, KdsState> {
  KdsBloc({required this.kdsRepository}) : super(KdsInitial()) {
    on<StreamKdsOrders>(_onStream);
    on<KdsOrdersUpdated>(_onUpdated);
    on<UpdateItemStatus>(_onUpdateItemStatus);
    on<CompleteKdsOrder>(_onComplete);
    on<UpdateOrderPriority>(_onPriority);
    on<ToggleOrderHold>(_onToggleHold);
  }

  final KdsRepository kdsRepository;
  StreamSubscription? _subscription;

  void _onStream(StreamKdsOrders event, Emitter<KdsState> emit) {
    emit(KdsLoading());
    _subscription?.cancel();
    _subscription = kdsRepository.streamKdsOrders(event.restaurantId).listen(
      (orders) => add(KdsOrdersUpdated(orders)),
      onError: (e) => add(KdsOrdersUpdated(const [])),
    );
  }

  void _onUpdated(KdsOrdersUpdated event, Emitter<KdsState> emit) {
    // Sort: rush first, then by creation time
    final sorted = List<KdsOrderModel>.from(event.orders)
      ..sort((a, b) {
        if (a.priority == OrderPriority.rush && b.priority != OrderPriority.rush) return -1;
        if (b.priority == OrderPriority.rush && a.priority != OrderPriority.rush) return 1;
        return (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now());
      });
    emit(KdsOrdersLoaded(sorted));
  }

  Future<void> _onUpdateItemStatus(UpdateItemStatus event, Emitter<KdsState> emit) async {
    await kdsRepository.updateItemStatus(event.restaurantId, event.orderId, event.itemIndex, event.status);
  }

  Future<void> _onComplete(CompleteKdsOrder event, Emitter<KdsState> emit) async {
    await kdsRepository.completeOrder(event.restaurantId, event.orderId);
  }

  Future<void> _onPriority(UpdateOrderPriority event, Emitter<KdsState> emit) async {
    await kdsRepository.updatePriority(event.restaurantId, event.orderId, event.priority);
  }

  Future<void> _onToggleHold(ToggleOrderHold event, Emitter<KdsState> emit) async {
    await kdsRepository.toggleHold(event.restaurantId, event.orderId, event.isOnHold);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
