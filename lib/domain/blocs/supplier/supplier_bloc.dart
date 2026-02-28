import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/supplier_model.dart';
import 'package:restaurant/data/repositories/supplier_repository.dart';

// ── Events ──
abstract class SupplierEvent extends Equatable {
  const SupplierEvent();
  @override
  List<Object?> get props => [];
}
class LoadSuppliers extends SupplierEvent {
  const LoadSuppliers(this.restaurantId);
  final String restaurantId;
}
class CreateSupplierEvent extends SupplierEvent {
  const CreateSupplierEvent(this.supplier);
  final SupplierModel supplier;
}
class LoadPurchaseOrders extends SupplierEvent {
  const LoadPurchaseOrders(this.restaurantId);
  final String restaurantId;
}
class CreatePurchaseOrderEvent extends SupplierEvent {
  const CreatePurchaseOrderEvent(this.po);
  final PurchaseOrderModel po;
}

// ── States ──
abstract class SupplierState extends Equatable {
  const SupplierState();
  @override
  List<Object?> get props => [];
}
class SupplierInitial extends SupplierState {}
class SupplierLoading extends SupplierState {}
class SuppliersLoaded extends SupplierState {
  const SuppliersLoaded({this.suppliers = const [], this.purchaseOrders = const []});
  final List<SupplierModel> suppliers;
  final List<PurchaseOrderModel> purchaseOrders;
  @override
  List<Object?> get props => [suppliers, purchaseOrders];
}
class SupplierError extends SupplierState {
  const SupplierError(this.message);
  final String message;
}

// ── BLoC ──
class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  SupplierBloc({required this.supplierRepository}) : super(SupplierInitial()) {
    on<LoadSuppliers>(_onLoad);
    on<CreateSupplierEvent>(_onCreate);
    on<LoadPurchaseOrders>(_onLoadPO);
    on<CreatePurchaseOrderEvent>(_onCreatePO);
  }
  final SupplierRepository supplierRepository;

  Future<void> _onLoad(LoadSuppliers event, Emitter<SupplierState> emit) async {
    emit(SupplierLoading());
    try {
      final suppliers = await supplierRepository.fetchSuppliers(event.restaurantId);
      final pos = await supplierRepository.fetchPurchaseOrders(event.restaurantId);
      emit(SuppliersLoaded(suppliers: suppliers, purchaseOrders: pos));
    } catch (e) {
      emit(SupplierError(e.toString()));
    }
  }

  Future<void> _onCreate(CreateSupplierEvent event, Emitter<SupplierState> emit) async {
    await supplierRepository.createSupplier(event.supplier);
    add(LoadSuppliers(event.supplier.restaurantId));
  }

  Future<void> _onLoadPO(LoadPurchaseOrders event, Emitter<SupplierState> emit) async {
    try {
      final pos = await supplierRepository.fetchPurchaseOrders(event.restaurantId);
      final cur = state;
      if (cur is SuppliersLoaded) emit(SuppliersLoaded(suppliers: cur.suppliers, purchaseOrders: pos));
    } catch (e) {
      emit(SupplierError(e.toString()));
    }
  }

  Future<void> _onCreatePO(CreatePurchaseOrderEvent event, Emitter<SupplierState> emit) async {
    await supplierRepository.createPurchaseOrder(event.po);
    add(LoadPurchaseOrders(event.po.restaurantId));
  }
}
