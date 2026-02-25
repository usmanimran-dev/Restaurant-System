import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/report_model.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportSummaryLoaded extends ReportsState {
  final ReportSummaryModel summary;

  const ReportSummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}
