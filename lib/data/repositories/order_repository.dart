import 'package:restaurant/data/models/order_model.dart';
import 'package:restaurant/data/repositories/supabase_repository.dart';

class OrderRepository {
  OrderRepository(this._supabaseRepo);

  final SupabaseRepository _supabaseRepo;
  static const String _table = 'orders';

  Future<List<OrderModel>> fetchOrders(String restaurantId) async {
    final data = await _supabaseRepo.fetchAll(_table, restaurantId: restaurantId);
    return data.map((json) => OrderModel.fromJson(json)).toList();
  }

  Future<OrderModel> createOrder(OrderModel order) async {
    // Note: In Supabase, items list will be stored as JSONB column.
    final data = await _supabaseRepo.insert(_table, order.toJson());
    return OrderModel.fromJson(data);
  }

  Future<OrderModel> updateOrderStatus(String id, String status) async {
    final data = await _supabaseRepo.update(_table, id, {'status': status});
    return OrderModel.fromJson(data);
  }
}
