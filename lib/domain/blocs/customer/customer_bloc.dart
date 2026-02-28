import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/payroll_customer_model.dart';
import 'package:restaurant/data/repositories/attendance_customer_repository.dart';

// ── Events ──
abstract class CustomerEvent extends Equatable {
  const CustomerEvent();
  @override
  List<Object?> get props => [];
}
class LoadCustomers extends CustomerEvent {
  const LoadCustomers(this.restaurantId);
  final String restaurantId;
}
class CreateCustomerEvent extends CustomerEvent {
  const CreateCustomerEvent(this.customer);
  final CustomerModel customer;
}
class UpdateCustomerEvent extends CustomerEvent {
  const UpdateCustomerEvent(this.restaurantId, this.customerId, this.data);
  final String restaurantId;
  final String customerId;
  final Map<String, dynamic> data;
}

// ── States ──
abstract class CustomerState extends Equatable {
  const CustomerState();
  @override
  List<Object?> get props => [];
}
class CustomerInitial extends CustomerState {}
class CustomerLoading extends CustomerState {}
class CustomersLoaded extends CustomerState {
  const CustomersLoaded(this.customers);
  final List<CustomerModel> customers;
  @override
  List<Object?> get props => [customers];
}
class CustomerError extends CustomerState {
  const CustomerError(this.message);
  final String message;
}

// ── BLoC ──
class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  CustomerBloc({required this.customerRepository}) : super(CustomerInitial()) {
    on<LoadCustomers>(_onLoad);
    on<CreateCustomerEvent>(_onCreate);
    on<UpdateCustomerEvent>(_onUpdate);
  }
  final CustomerRepository customerRepository;

  Future<void> _onLoad(LoadCustomers event, Emitter<CustomerState> emit) async {
    emit(CustomerLoading());
    try {
      final customers = await customerRepository.fetchCustomers(event.restaurantId);
      emit(CustomersLoaded(customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onCreate(CreateCustomerEvent event, Emitter<CustomerState> emit) async {
    await customerRepository.createCustomer(event.customer);
    add(LoadCustomers(event.customer.restaurantId));
  }

  Future<void> _onUpdate(UpdateCustomerEvent event, Emitter<CustomerState> emit) async {
    await customerRepository.updateCustomer(event.restaurantId, event.customerId, event.data);
    add(LoadCustomers(event.restaurantId));
  }
}
