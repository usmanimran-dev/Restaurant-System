import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/delivery_model.dart';

// ── Events ──
abstract class DeliveryEvent extends Equatable {
  const DeliveryEvent();
  @override
  List<Object?> get props => [];
}

class LoadDeliveries extends DeliveryEvent {
  const LoadDeliveries(this.restaurantId);
  final String restaurantId;
  @override
  List<Object?> get props => [restaurantId];
}

class CreateDeliveryEvent extends DeliveryEvent {
  const CreateDeliveryEvent(this.delivery);
  final DeliveryModel delivery;
  @override
  List<Object?> get props => [delivery];
}

class UpdateDeliveryStatusEvent extends DeliveryEvent {
  const UpdateDeliveryStatusEvent(this.restaurantId, this.deliveryId, this.data);
  final String restaurantId;
  final String deliveryId;
  final Map<String, dynamic> data;
  @override
  List<Object?> get props => [restaurantId, deliveryId, data];
}

class LoadDrivers extends DeliveryEvent {
  const LoadDrivers(this.restaurantId);
  final String restaurantId;
  @override
  List<Object?> get props => [restaurantId];
}

class CreateDriverEvent extends DeliveryEvent {
  const CreateDriverEvent(this.driver);
  final DriverModel driver;
  @override
  List<Object?> get props => [driver];
}

class LoadZones extends DeliveryEvent {
  const LoadZones(this.restaurantId);
  final String restaurantId;
  @override
  List<Object?> get props => [restaurantId];
}

class CreateZoneEvent extends DeliveryEvent {
  const CreateZoneEvent(this.zone);
  final DeliveryZoneModel zone;
  @override
  List<Object?> get props => [zone];
}
