import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/salary_record_model.dart';

abstract class SalaryEvent extends Equatable {
  const SalaryEvent();

  @override
  List<Object?> get props => [];
}

class LoadSalaries extends SalaryEvent {
  final String restaurantId;
  const LoadSalaries(this.restaurantId);

  @override
  List<Object?> get props => [restaurantId];
}

class ProcessSalary extends SalaryEvent {
  final SalaryRecordModel record;
  const ProcessSalary(this.record);

  @override
  List<Object?> get props => [record];
}

class MarkSalaryPaid extends SalaryEvent {
  final String recordId;
  final String restaurantId; // Used strictly to reload
  const MarkSalaryPaid(this.recordId, this.restaurantId);

  @override
  List<Object?> get props => [recordId, restaurantId];
}
