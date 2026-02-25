import 'package:equatable/equatable.dart';

class ReportSummaryModel extends Equatable {
  final double totalRevenue;
  final double totalTaxes;
  final double totalSalaries;
  final double totalPurchases;
  final int orderCount;

  const ReportSummaryModel({
    required this.totalRevenue,
    required this.totalTaxes,
    required this.totalSalaries,
    required this.totalPurchases,
    required this.orderCount,
  });

  double get profitAndLoss => totalRevenue - totalSalaries - totalPurchases;

  @override
  List<Object?> get props => [
        totalRevenue,
        totalTaxes,
        totalSalaries,
        totalPurchases,
        orderCount,
      ];
}
