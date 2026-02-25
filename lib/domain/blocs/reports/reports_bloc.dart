import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/data/repositories/reports_repository.dart';
import 'package:restaurant/domain/blocs/reports/reports_event.dart';
import 'package:restaurant/domain/blocs/reports/reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportsRepository _reportsRepository;

  ReportsBloc({required ReportsRepository reportsRepository})
      : _reportsRepository = reportsRepository,
        super(ReportsInitial()) {
    on<LoadReportSummary>(_onLoadReportSummary);
  }

  Future<void> _onLoadReportSummary(LoadReportSummary event, Emitter<ReportsState> emit) async {
    emit(ReportsLoading());
    try {
      final summary = await _reportsRepository.getAggregatedReport(
        event.restaurantId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(ReportSummaryLoaded(summary));
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }
}
