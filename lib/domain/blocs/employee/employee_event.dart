import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/employee_model.dart';

abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();

  @override
  List<Object?> get props => [];
}

class LoadEmployees extends EmployeeEvent {
  final String restaurantId;
  const LoadEmployees(this.restaurantId);

  @override
  List<Object?> get props => [restaurantId];
}

class CreateEmployee extends EmployeeEvent {
  final EmployeeModel employee;
  final String rawPassword; // Standard Supabase auth needs a password payload

  const CreateEmployee(this.employee, this.rawPassword);

  @override
  List<Object?> get props => [employee, rawPassword];
}

class UpdateEmployee extends EmployeeEvent {
  final String employeeId;
  final Map<String, dynamic> updates;

  const UpdateEmployee(this.employeeId, this.updates);

  @override
  List<Object?> get props => [employeeId, updates];
}
