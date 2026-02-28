import 'package:restaurant/data/models/order_model.dart';
import 'package:restaurant/data/models/salary_record_model.dart';
import 'package:restaurant/data/models/inventory_model.dart';
import 'package:restaurant/data/models/report_model.dart';
import 'package:restaurant/data/repositories/firestore_repository.dart';

class ReportsRepository {
  ReportsRepository(this._firestoreRepo);

  final FirestoreRepository _firestoreRepo;

  Future<ReportSummaryModel> getAggregatedReport(String restaurantId, {DateTime? startDate, DateTime? endDate}) async {
    // 1. Fetch Orders
    final ordersJson = await _firestoreRepo.fetchAll('orders', restaurantId: restaurantId);
    final orders = ordersJson.map((e) => OrderModel.fromJson(e)).toList();

    // Filter optionally by dates here in memory for MVP
    final filteredOrders = orders.where((o) {
      if (startDate != null && o.createdAt?.isBefore(startDate) == true) return false;
      if (endDate != null && o.createdAt?.isAfter(endDate) == true) return false;
      return true;
    }).toList();

    double totalRevenue = 0;
    double totalTaxes = 0;
    for (var o in filteredOrders) {
      totalRevenue += o.subtotal;
      totalTaxes += o.taxAmount;
    }

    // 2. Fetch Salaries
    final salariesJson = await _firestoreRepo.fetchAll('salary_records', restaurantId: restaurantId);
    final salaries = salariesJson.map((e) => SalaryRecordModel.fromJson(e)).toList();
    
    double totalSalaries = 0;
    for (var s in salaries) {
      totalSalaries += s.netSalary;
    }

    // 3. Fetch Purchases
    final purchasesJson = await _firestoreRepo.fetchAll('purchases', restaurantId: restaurantId);
    final purchases = purchasesJson.map((e) => PurchaseModel.fromJson(e)).toList();
    
    double totalPurchases = 0;
    for (var p in purchases) {
      if (startDate != null && p.date.isBefore(startDate)) continue;
      if (endDate != null && p.date.isAfter(endDate)) continue;
      totalPurchases += p.cost;
    }

    return ReportSummaryModel(
      totalRevenue: totalRevenue,
      totalTaxes: totalTaxes,
      totalSalaries: totalSalaries,
      totalPurchases: totalPurchases,
      orderCount: filteredOrders.length,
    );
  }
}
