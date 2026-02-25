import 'package:equatable/equatable.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class LoadReportSummary extends ReportsEvent {
  final String restaurantId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadReportSummary({
    required this.restaurantId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [restaurantId, startDate, endDate];
}
