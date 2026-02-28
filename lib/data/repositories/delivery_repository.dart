import 'package:restaurant/data/models/delivery_model.dart';
import 'package:restaurant/data/repositories/firestore_repository.dart';

/// Repository for delivery and driver management.
class DeliveryRepository {
  DeliveryRepository(this._firestore);
  final FirestoreRepository _firestore;

  // ── Deliveries ──
  Future<List<DeliveryModel>> fetchDeliveries(String restaurantId) async {
    final data = await _firestore.fetchAll('deliveries', restaurantId: restaurantId);
    return data.map((d) => DeliveryModel.fromJson(d)).toList();
  }

  Future<void> createDelivery(DeliveryModel delivery) async {
    await _firestore.insert('deliveries', delivery.toJson());
  }

  Future<void> updateDeliveryStatus(String restaurantId, String deliveryId, Map<String, dynamic> data) async {
    await _firestore.update('deliveries', deliveryId, data);
  }

  // ── Drivers ──
  Future<List<DriverModel>> fetchDrivers(String restaurantId) async {
    final data = await _firestore.fetchAll('drivers', restaurantId: restaurantId);
    return data.map((d) => DriverModel.fromJson(d)).toList();
  }

  Future<void> createDriver(DriverModel driver) async {
    await _firestore.insert('drivers', driver.toJson());
  }

  Future<void> updateDriver(String restaurantId, String driverId, Map<String, dynamic> data) async {
    await _firestore.update('drivers', driverId, data);
  }

  // ── Delivery Zones ──
  Future<List<DeliveryZoneModel>> fetchZones(String restaurantId) async {
    final data = await _firestore.fetchAll('delivery_zones', restaurantId: restaurantId);
    return data.map((d) => DeliveryZoneModel.fromJson(d)).toList();
  }

  Future<void> createZone(DeliveryZoneModel zone) async {
    await _firestore.insert('delivery_zones', zone.toJson());
  }
}
