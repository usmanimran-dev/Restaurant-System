import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/salary_record_model.dart';

abstract class SalaryState extends Equatable {
  const SalaryState();

  @override
  List<Object?> get props => [];
}

class SalaryInitial extends SalaryState {}

class SalaryLoading extends SalaryState {}

class SalaryLoaded extends SalaryState {
  final List<SalaryRecordModel> records;

  const SalaryLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

class SalaryError extends SalaryState {
  final String message;
  const SalaryError(this.message);

  @override
  List<Object?> get props => [message];
}

class SalaryOperationSuccess extends SalaryState {
  final String message;
  const SalaryOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
