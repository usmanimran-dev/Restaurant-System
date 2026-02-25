import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/data/repositories/salary_repository.dart';
import 'package:restaurant/domain/blocs/salary/salary_event.dart';
import 'package:restaurant/domain/blocs/salary/salary_state.dart';

class SalaryBloc extends Bloc<SalaryEvent, SalaryState> {
  final SalaryRepository _salaryRepository;

  SalaryBloc({required SalaryRepository salaryRepository})
      : _salaryRepository = salaryRepository,
        super(SalaryInitial()) {
    on<LoadSalaries>(_onLoadSalaries);
    on<ProcessSalary>(_onProcessSalary);
    on<MarkSalaryPaid>(_onMarkSalaryPaid);
  }

  Future<void> _onLoadSalaries(LoadSalaries event, Emitter<SalaryState> emit) async {
    emit(SalaryLoading());
    try {
      final records = await _salaryRepository.fetchSalaries(event.restaurantId);
      emit(SalaryLoaded(records));
    } catch (e) {
      emit(SalaryError(e.toString()));
    }
  }

  Future<void> _onProcessSalary(ProcessSalary event, Emitter<SalaryState> emit) async {
    emit(SalaryLoading());
    try {
      await _salaryRepository.processSalary(event.record);
      emit(const SalaryOperationSuccess('Salary record created successfully.'));
      add(LoadSalaries(event.record.restaurantId));
    } catch (e) {
      emit(SalaryError(e.toString()));
    }
  }

  Future<void> _onMarkSalaryPaid(MarkSalaryPaid event, Emitter<SalaryState> emit) async {
    try {
      await _salaryRepository.markAsPaid(event.recordId);
      emit(const SalaryOperationSuccess('Payment recorded successfully.'));
      add(LoadSalaries(event.restaurantId));
    } catch (e) {
      emit(SalaryError(e.toString()));
    }
  }
}
