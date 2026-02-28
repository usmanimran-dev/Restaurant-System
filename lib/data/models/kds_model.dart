import 'package:equatable/equatable.dart';

/// Kitchen Display System order priority levels.
enum OrderPriority { rush, normal, delayed }

/// Status of an individual item in the kitchen.
enum ItemPrepStatus { pending, cooking, ready, served }

/// KDS order model — represents an order as it appears in the kitchen queue.
class KdsOrderModel extends Equatable {
  const KdsOrderModel({
    required this.orderId,
    required this.restaurantId,
    required this.orderNumber,
    required this.orderType,
    required this.items,
    this.customerName,
    this.tableNumber,
    this.specialInstructions,
    this.priority = OrderPriority.normal,
    this.isOnHold = false,
    this.estimatedPrepMinutes = 15,
    this.createdAt,
    this.completedAt,
  });

  final String orderId;
  final String restaurantId;
  final String orderNumber;
  final String orderType; // dine-in, takeaway, delivery
  final List<KdsItemModel> items;
  final String? customerName;
  final String? tableNumber;
  final String? specialInstructions;
  final OrderPriority priority;
  final bool isOnHold;
  final int estimatedPrepMinutes;
  final DateTime? createdAt;
  final DateTime? completedAt;

  bool get isComplete => items.every((i) => i.status == ItemPrepStatus.ready || i.status == ItemPrepStatus.served);

  Duration get elapsed => DateTime.now().difference(createdAt ?? DateTime.now());

  factory KdsOrderModel.fromJson(Map<String, dynamic> json) {
    return KdsOrderModel(
      orderId: json['order_id'] as String,
      restaurantId: json['restaurant_id'] as String,
      orderNumber: json['order_number'] as String? ?? '',
      orderType: json['order_type'] as String? ?? 'dine-in',
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => KdsItemModel.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      customerName: json['customer_name'] as String?,
      tableNumber: json['table_number'] as String?,
      specialInstructions: json['special_instructions'] as String?,
      priority: OrderPriority.values.firstWhere(
        (e) => e.name == (json['priority'] as String? ?? 'normal'),
        orElse: () => OrderPriority.normal,
      ),
      isOnHold: json['is_on_hold'] as bool? ?? false,
      estimatedPrepMinutes: json['estimated_prep_minutes'] as int? ?? 15,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'restaurant_id': restaurantId,
        'order_number': orderNumber,
        'order_type': orderType,
        'items': items.map((i) => i.toJson()).toList(),
        'customer_name': customerName,
        'table_number': tableNumber,
        'special_instructions': specialInstructions,
        'priority': priority.name,
        'is_on_hold': isOnHold,
        'estimated_prep_minutes': estimatedPrepMinutes,
        'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [orderId, restaurantId, orderNumber, orderType, items, priority, isOnHold, createdAt];
}

/// Individual item within a KDS order.
class KdsItemModel extends Equatable {
  const KdsItemModel({
    required this.menuItemId,
    required this.name,
    required this.quantity,
    this.modifiers = const [],
    this.notes,
    this.station,
    this.status = ItemPrepStatus.pending,
    this.statusUpdatedAt,
  });

  final String menuItemId;
  final String name;
  final int quantity;
  final List<String> modifiers;
  final String? notes;
  final String? station;
  final ItemPrepStatus status;
  final DateTime? statusUpdatedAt;

  factory KdsItemModel.fromJson(Map<String, dynamic> json) {
    return KdsItemModel(
      menuItemId: json['menu_item_id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int? ?? 1,
      modifiers: (json['modifiers'] as List<dynamic>?)?.cast<String>() ?? [],
      notes: json['notes'] as String?,
      station: json['station'] as String?,
      status: ItemPrepStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'pending'),
        orElse: () => ItemPrepStatus.pending,
      ),
      statusUpdatedAt: json['status_updated_at'] != null ? DateTime.parse(json['status_updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'menu_item_id': menuItemId,
        'name': name,
        'quantity': quantity,
        'modifiers': modifiers,
        'notes': notes,
        'station': station,
        'status': status.name,
        'status_updated_at': statusUpdatedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [menuItemId, name, quantity, modifiers, notes, station, status];
}

/// Kitchen station configuration.
class StationModel extends Equatable {
  const StationModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.color,
    this.sortOrder = 0,
  });

  final String id;
  final String restaurantId;
  final String name;
  final String? color;
  final int sortOrder;

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String,
      color: json['color'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'restaurant_id': restaurantId,
        'name': name,
        'color': color,
        'sort_order': sortOrder,
      };

  @override
  List<Object?> get props => [id, restaurantId, name, color, sortOrder];
}
