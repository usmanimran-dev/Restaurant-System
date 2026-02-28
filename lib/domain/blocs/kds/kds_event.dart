import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/kds_model.dart';

abstract class KdsEvent extends Equatable {
  const KdsEvent();
  @override
  List<Object?> get props => [];
}

class StreamKdsOrders extends KdsEvent {
  const StreamKdsOrders(this.restaurantId);
  final String restaurantId;
  @override
  List<Object?> get props => [restaurantId];
}

class KdsOrdersUpdated extends KdsEvent {
  const KdsOrdersUpdated(this.orders);
  final List<KdsOrderModel> orders;
  @override
  List<Object?> get props => [orders];
}

class UpdateItemStatus extends KdsEvent {
  const UpdateItemStatus(this.restaurantId, this.orderId, this.itemIndex, this.status);
  final String restaurantId;
  final String orderId;
  final int itemIndex;
  final ItemPrepStatus status;
  @override
  List<Object?> get props => [restaurantId, orderId, itemIndex, status];
}

class CompleteKdsOrder extends KdsEvent {
  const CompleteKdsOrder(this.restaurantId, this.orderId);
  final String restaurantId;
  final String orderId;
  @override
  List<Object?> get props => [restaurantId, orderId];
}

class UpdateOrderPriority extends KdsEvent {
  const UpdateOrderPriority(this.restaurantId, this.orderId, this.priority);
  final String restaurantId;
  final String orderId;
  final OrderPriority priority;
  @override
  List<Object?> get props => [restaurantId, orderId, priority];
}

class ToggleOrderHold extends KdsEvent {
  const ToggleOrderHold(this.restaurantId, this.orderId, this.isOnHold);
  final String restaurantId;
  final String orderId;
  final bool isOnHold;
  @override
  List<Object?> get props => [restaurantId, orderId, isOnHold];
}
