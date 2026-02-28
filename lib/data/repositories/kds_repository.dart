import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurant/data/models/kds_model.dart';

/// Repository for Kitchen Display System operations.
class KdsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream KDS orders in real-time for a restaurant.
  Stream<List<KdsOrderModel>> streamKdsOrders(String restaurantId) {
    return _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('kds_orders')
        .where('completed_at', isNull: true)
        .orderBy('created_at', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => KdsOrderModel.fromJson({...d.data(), 'order_id': d.id}))
            .toList());
  }

  /// Push an order to the KDS queue.
  Future<void> pushToKds(String restaurantId, KdsOrderModel order) async {
    await _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('kds_orders')
        .doc(order.orderId)
        .set(order.toJson());
  }

  /// Update item status in a KDS order.
  Future<void> updateItemStatus(String restaurantId, String orderId, int itemIndex, ItemPrepStatus status) async {
    final docRef = _firestore.collection('restaurants').doc(restaurantId).collection('kds_orders').doc(orderId);
    final doc = await docRef.get();
    if (!doc.exists) return;
    final data = doc.data()!;
    final items = List<Map<String, dynamic>>.from(data['items'] as List);
    if (itemIndex < items.length) {
      items[itemIndex]['status'] = status.name;
      items[itemIndex]['status_updated_at'] = DateTime.now().toIso8601String();
    }
    await docRef.update({'items': items});
  }

  /// Mark entire order as complete in both KDS and Main Orders collection.
  Future<void> completeOrder(String restaurantId, String orderId) async {
    final batch = _firestore.batch();
    
    // 1. Complete in KDS
    final kdsRef = _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('kds_orders')
        .doc(orderId);
    batch.update(kdsRef, {'completed_at': DateTime.now().toIso8601String()});

    // 2. Update status in master orders collection
    final orderRef = _firestore.collection('orders').doc(orderId);
    batch.update(orderRef, {'status': 'completed'});

    await batch.commit();
  }

  /// Update order priority.
  Future<void> updatePriority(String restaurantId, String orderId, OrderPriority priority) async {
    await _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('kds_orders')
        .doc(orderId)
        .update({'priority': priority.name});
  }

  /// Toggle hold on an order.
  Future<void> toggleHold(String restaurantId, String orderId, bool isOnHold) async {
    await _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('kds_orders')
        .doc(orderId)
        .update({'is_on_hold': isOnHold});
  }

  /// Fetch stations for a restaurant.
  Future<List<StationModel>> fetchStations(String restaurantId) async {
    final snap = await _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('stations')
        .orderBy('sort_order')
        .get();
    return snap.docs.map((d) => StationModel.fromJson({...d.data(), 'id': d.id})).toList();
  }
}
