import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/data/repositories/employee_repository.dart';
import 'package:restaurant/domain/blocs/employee/employee_event.dart';
import 'package:restaurant/domain/blocs/employee/employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final EmployeeRepository _employeeRepository;

  EmployeeBloc({required EmployeeRepository employeeRepository})
      : _employeeRepository = employeeRepository,
        super(EmployeeInitial()) {
    on<LoadEmployees>(_onLoadEmployees);
    on<CreateEmployee>(_onCreateEmployee);
    on<UpdateEmployee>(_onUpdateEmployee);
    on<DeleteEmployee>(_onDeleteEmployee);
  }

  Future<void> _onLoadEmployees(LoadEmployees event, Emitter<EmployeeState> emit) async {
    emit(EmployeeLoading());
    try {
      final employees = await _employeeRepository.fetchEmployees(event.restaurantId);
      emit(EmployeeLoaded(employees));
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  Future<void> _onCreateEmployee(CreateEmployee event, Emitter<EmployeeState> emit) async {
    emit(EmployeeLoading());
    try {
      await _employeeRepository.createEmployee(event.employee);
      emit(const EmployeeOperationSuccess('Employee added successfully.'));
      add(LoadEmployees(event.employee.restaurantId));
    } catch (e) {
      emit(EmployeeError(e.toString()));
      add(LoadEmployees(event.employee.restaurantId));
    }
  }

  Future<void> _onUpdateEmployee(UpdateEmployee event, Emitter<EmployeeState> emit) async {
    try {
      await _employeeRepository.updateEmployee(event.employeeId, event.updates);
      emit(const EmployeeOperationSuccess('Employee updated successfully.'));
      add(LoadEmployees(event.restaurantId));
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  Future<void> _onDeleteEmployee(DeleteEmployee event, Emitter<EmployeeState> emit) async {
    try {
      await _employeeRepository.deleteEmployee(event.employeeId);
      emit(const EmployeeOperationSuccess('Employee deleted successfully.'));
      add(LoadEmployees(event.restaurantId));
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }
}
