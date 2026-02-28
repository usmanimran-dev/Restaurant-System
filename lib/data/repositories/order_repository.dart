import 'package:restaurant/data/models/order_model.dart';
import 'package:restaurant/data/repositories/firestore_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurant/data/models/kds_model.dart';

class OrderRepository {
  OrderRepository(this._firestoreRepo);

  final FirestoreRepository _firestoreRepo;
  static const String _table = 'orders';

  Future<List<OrderModel>> fetchOrders(String restaurantId) async {
    final data = await _firestoreRepo.fetchAll(_table, restaurantId: restaurantId);
    return data.map((json) => OrderModel.fromJson(json)).toList();
  }

  Future<OrderModel> createOrder(OrderModel order) async {
    // 1. Insert into main orders flat collection
    final data = await _firestoreRepo.insert(_table, order.toJson());
    final createdOrder = OrderModel.fromJson(data);

    // 2. Generate KDS formatted order and push to restaurant subcollection
    final kdsOrder = KdsOrderModel(
      orderId: createdOrder.id,
      restaurantId: createdOrder.restaurantId,
      orderNumber: createdOrder.id.substring(0, 6).toUpperCase(),
      orderType: createdOrder.type,
      items: createdOrder.items.map((i) => KdsItemModel(
        menuItemId: i.menuItemId,
        name: i.name,
        quantity: i.quantity,
        modifiers: i.modifiers.map((m) => m.name).toList(),
        notes: i.notes,
      )).toList(),
      customerName: createdOrder.customerName,
      createdAt: createdOrder.createdAt,
    );

    await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(createdOrder.restaurantId)
        .collection('kds_orders')
        .doc(createdOrder.id)
        .set(kdsOrder.toJson());

    return createdOrder;
  }

  Future<OrderModel> updateOrderStatus(String id, String status) async {
    final data = await _firestoreRepo.update(_table, id, {'status': status});
    return OrderModel.fromJson(data);
  }
}
