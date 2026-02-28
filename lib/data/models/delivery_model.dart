import 'package:equatable/equatable.dart';

/// Delivery status workflow.
enum DeliveryStatus { ready, packed, assigned, pickedUp, inTransit, delivered, failed }

/// Driver availability status.
enum DriverStatus { available, onDelivery, offline }

/// Delivery tracking model.
class DeliveryModel extends Equatable {
  const DeliveryModel({
    required this.id,
    required this.orderId,
    required this.restaurantId,
    this.driverId,
    this.driverName,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    this.deliveryFee = 0,
    this.status = DeliveryStatus.ready,
    this.estimatedMinutes,
    this.actualMinutes,
    this.zoneId,
    this.createdAt,
    this.deliveredAt,
  });

  final String id;
  final String orderId;
  final String restaurantId;
  final String? driverId;
  final String? driverName;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  final double deliveryFee;
  final DeliveryStatus status;
  final int? estimatedMinutes;
  final int? actualMinutes;
  final String? zoneId;
  final DateTime? createdAt;
  final DateTime? deliveredAt;

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      restaurantId: json['restaurant_id'] as String,
      driverId: json['driver_id'] as String?,
      driverName: json['driver_name'] as String?,
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      deliveryAddress: json['delivery_address'] as String?,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
      status: DeliveryStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'ready'),
        orElse: () => DeliveryStatus.ready,
      ),
      estimatedMinutes: json['estimated_minutes'] as int?,
      actualMinutes: json['actual_minutes'] as int?,
      zoneId: json['zone_id'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'restaurant_id': restaurantId,
        'driver_id': driverId,
        'driver_name': driverName,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'delivery_address': deliveryAddress,
        'delivery_fee': deliveryFee,
        'status': status.name,
        'estimated_minutes': estimatedMinutes,
        'actual_minutes': actualMinutes,
        'zone_id': zoneId,
        'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
        'delivered_at': deliveredAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, orderId, restaurantId, driverId, status, createdAt];
}

/// Driver entity.
class DriverModel extends Equatable {
  const DriverModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.phone,
    this.email,
    this.vehicleType,
    this.licensePlate,
    this.status = DriverStatus.offline,
    this.rating = 5.0,
    this.totalDeliveries = 0,
  });

  final String id;
  final String restaurantId;
  final String name;
  final String phone;
  final String? email;
  final String? vehicleType;
  final String? licensePlate;
  final DriverStatus status;
  final double rating;
  final int totalDeliveries;

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      licensePlate: json['license_plate'] as String?,
      status: DriverStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'offline'),
        orElse: () => DriverStatus.offline,
      ),
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalDeliveries: json['total_deliveries'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'restaurant_id': restaurantId,
        'name': name,
        'phone': phone,
        'email': email,
        'vehicle_type': vehicleType,
        'license_plate': licensePlate,
        'status': status.name,
        'rating': rating,
        'total_deliveries': totalDeliveries,
      };

  @override
  List<Object?> get props => [id, restaurantId, name, phone, status];
}

/// Delivery zone configuration.
class DeliveryZoneModel extends Equatable {
  const DeliveryZoneModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.deliveryFee,
    this.estimatedMinutes = 30,
    this.isActive = true,
  });

  final String id;
  final String restaurantId;
  final String name;
  final double deliveryFee;
  final int estimatedMinutes;
  final bool isActive;

  factory DeliveryZoneModel.fromJson(Map<String, dynamic> json) {
    return DeliveryZoneModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String,
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      estimatedMinutes: json['estimated_minutes'] as int? ?? 30,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'restaurant_id': restaurantId,
        'name': name,
        'delivery_fee': deliveryFee,
        'estimated_minutes': estimatedMinutes,
        'is_active': isActive,
      };

  @override
  List<Object?> get props => [id, restaurantId, name, deliveryFee, isActive];
}
