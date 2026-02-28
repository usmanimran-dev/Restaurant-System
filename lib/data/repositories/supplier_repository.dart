import 'package:restaurant/data/models/supplier_model.dart';
import 'package:restaurant/data/repositories/firestore_repository.dart';

/// Repository for supplier & purchase order management.
class SupplierRepository {
  SupplierRepository(this._firestore);
  final FirestoreRepository _firestore;

  // ── Suppliers ──
  Future<List<SupplierModel>> fetchSuppliers(String restaurantId) async {
    final data = await _firestore.fetchAll('suppliers', restaurantId: restaurantId);
    return data.map((d) => SupplierModel.fromJson(d)).toList();
  }

  Future<void> createSupplier(SupplierModel supplier) async {
    await _firestore.insert('suppliers', supplier.toJson());
  }

  Future<void> updateSupplier(String restaurantId, String supplierId, Map<String, dynamic> data) async {
    await _firestore.update('suppliers', supplierId, data);
  }

  Future<void> deleteSupplier(String restaurantId, String supplierId) async {
    await _firestore.delete('suppliers', supplierId);
  }

  // ── Purchase Orders ──
  Future<List<PurchaseOrderModel>> fetchPurchaseOrders(String restaurantId) async {
    final data = await _firestore.fetchAll('purchase_orders', restaurantId: restaurantId);
    return data.map((d) => PurchaseOrderModel.fromJson(d)).toList();
  }

  Future<void> createPurchaseOrder(PurchaseOrderModel po) async {
    await _firestore.insert('purchase_orders', po.toJson());
  }

  Future<void> updatePurchaseOrder(String restaurantId, String poId, Map<String, dynamic> data) async {
    await _firestore.update('purchase_orders', poId, data);
  }
}
