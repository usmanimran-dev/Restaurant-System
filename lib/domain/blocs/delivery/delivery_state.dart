import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/delivery_model.dart';

// ── States ──
abstract class DeliveryState extends Equatable {
  const DeliveryState();
  @override
  List<Object?> get props => [];
}

class DeliveryInitial extends DeliveryState {}
class DeliveryLoading extends DeliveryState {}

class DeliveriesLoaded extends DeliveryState {
  const DeliveriesLoaded({this.deliveries = const [], this.drivers = const [], this.zones = const []});
  final List<DeliveryModel> deliveries;
  final List<DriverModel> drivers;
  final List<DeliveryZoneModel> zones;
  @override
  List<Object?> get props => [deliveries, drivers, zones];
}

class DeliveryError extends DeliveryState {
  const DeliveryError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
