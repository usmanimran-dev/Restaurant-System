import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/kds_model.dart';

abstract class KdsState extends Equatable {
  const KdsState();
  @override
  List<Object?> get props => [];
}

class KdsInitial extends KdsState {}

class KdsLoading extends KdsState {}

class KdsOrdersLoaded extends KdsState {
  const KdsOrdersLoaded(this.orders);
  final List<KdsOrderModel> orders;

  List<KdsOrderModel> get rushOrders => orders.where((o) => o.priority == OrderPriority.rush && !o.isOnHold).toList();
  List<KdsOrderModel> get normalOrders => orders.where((o) => o.priority == OrderPriority.normal && !o.isOnHold).toList();
  List<KdsOrderModel> get heldOrders => orders.where((o) => o.isOnHold).toList();

  @override
  List<Object?> get props => [orders];
}

class KdsError extends KdsState {
  const KdsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
