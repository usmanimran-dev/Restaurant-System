import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/data/repositories/delivery_repository.dart';
import 'delivery_event.dart';
import 'delivery_state.dart';

class DeliveryBloc extends Bloc<DeliveryEvent, DeliveryState> {
  DeliveryBloc({required this.deliveryRepository}) : super(DeliveryInitial()) {
    on<LoadDeliveries>(_onLoadDeliveries);
    on<CreateDeliveryEvent>(_onCreateDelivery);
    on<UpdateDeliveryStatusEvent>(_onUpdateStatus);
    on<LoadDrivers>(_onLoadDrivers);
    on<CreateDriverEvent>(_onCreateDriver);
    on<LoadZones>(_onLoadZones);
    on<CreateZoneEvent>(_onCreateZone);
  }

  final DeliveryRepository deliveryRepository;

  Future<void> _onLoadDeliveries(LoadDeliveries event, Emitter<DeliveryState> emit) async {
    emit(DeliveryLoading());
    try {
      final deliveries = await deliveryRepository.fetchDeliveries(event.restaurantId);
      final drivers = await deliveryRepository.fetchDrivers(event.restaurantId);
      final zones = await deliveryRepository.fetchZones(event.restaurantId);
      emit(DeliveriesLoaded(deliveries: deliveries, drivers: drivers, zones: zones));
    } catch (e) {
      emit(DeliveryError(e.toString()));
    }
  }

  Future<void> _onCreateDelivery(CreateDeliveryEvent event, Emitter<DeliveryState> emit) async {
    try {
      await deliveryRepository.createDelivery(event.delivery);
      add(LoadDeliveries(event.delivery.restaurantId));
    } catch (e) {
      emit(DeliveryError(e.toString()));
    }
  }

  Future<void> _onUpdateStatus(UpdateDeliveryStatusEvent event, Emitter<DeliveryState> emit) async {
    try {
      await deliveryRepository.updateDeliveryStatus(event.restaurantId, event.deliveryId, event.data);
      add(LoadDeliveries(event.restaurantId));
    } catch (e) {
      emit(DeliveryError(e.toString()));
    }
  }

  Future<void> _onLoadDrivers(LoadDrivers event, Emitter<DeliveryState> emit) async {
    try {
      final drivers = await deliveryRepository.fetchDrivers(event.restaurantId);
      final currentState = state;
      if (currentState is DeliveriesLoaded) {
        emit(DeliveriesLoaded(deliveries: currentState.deliveries, drivers: drivers, zones: currentState.zones));
      }
    } catch (e) {
      emit(DeliveryError(e.toString()));
    }
  }

  Future<void> _onCreateDriver(CreateDriverEvent event, Emitter<DeliveryState> emit) async {
    try {
      await deliveryRepository.createDriver(event.driver);
      add(LoadDrivers(event.driver.restaurantId));
    } catch (e) {
      emit(DeliveryError(e.toString()));
    }
  }

  Future<void> _onLoadZones(LoadZones event, Emitter<DeliveryState> emit) async {
    try {
      final zones = await deliveryRepository.fetchZones(event.restaurantId);
      final currentState = state;
      if (currentState is DeliveriesLoaded) {
        emit(DeliveriesLoaded(deliveries: currentState.deliveries, drivers: currentState.drivers, zones: zones));
      }
    } catch (e) {
      emit(DeliveryError(e.toString()));
    }
  }

  Future<void> _onCreateZone(CreateZoneEvent event, Emitter<DeliveryState> emit) async {
    try {
      await deliveryRepository.createZone(event.zone);
      add(LoadZones(event.zone.restaurantId));
    } catch (e) {
      emit(DeliveryError(e.toString()));
    }
  }
}
