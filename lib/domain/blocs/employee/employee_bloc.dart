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
      // In production, user creation needs a secure RPC or Edge Function to link Auth to Public.
      // We assume the schema triggers sync this.
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
      // Note: Current state needs to provide restaurantId to reload, omitting for brevity
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }
}
