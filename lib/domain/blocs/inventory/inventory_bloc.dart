import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/data/repositories/inventory_repository.dart';
import 'package:restaurant/domain/blocs/inventory/inventory_event.dart';
import 'package:restaurant/domain/blocs/inventory/inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository _inventoryRepository;

  InventoryBloc({required InventoryRepository inventoryRepository})
      : _inventoryRepository = inventoryRepository,
        super(InventoryInitial()) {
    on<LoadInventory>(_onLoadInventory);
    on<CreateInventoryCategory>(_onCreateCategory);
    on<CreateInventoryItem>(_onCreateItem);
    on<RecordPurchase>(_onRecordPurchase);
  }

  Future<void> _onLoadInventory(LoadInventory event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());
    try {
      final categories = await _inventoryRepository.fetchCategories(event.restaurantId);
      final items = await _inventoryRepository.fetchItems(event.restaurantId);
      emit(InventoryLoaded(categories: categories, items: items));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onCreateCategory(CreateInventoryCategory event, Emitter<InventoryState> emit) async {
    final currentState = state;
    if (currentState is InventoryLoaded) {
      try {
        await _inventoryRepository.createCategory(event.category);
        emit(const InventoryOperationSuccess('Category created successfully'));
        add(LoadInventory(event.category.restaurantId));
      } catch (e) {
        emit(InventoryError(e.toString()));
      }
    }
  }

  Future<void> _onCreateItem(CreateInventoryItem event, Emitter<InventoryState> emit) async {
    final currentState = state;
    if (currentState is InventoryLoaded) {
      try {
        await _inventoryRepository.createItem(event.item);
        emit(const InventoryOperationSuccess('Item created successfully'));
        add(LoadInventory(event.item.restaurantId));
      } catch (e) {
        emit(InventoryError(e.toString()));
      }
    }
  }

  Future<void> _onRecordPurchase(RecordPurchase event, Emitter<InventoryState> emit) async {
    final currentState = state;
    if (currentState is InventoryLoaded) {
      try {
        await _inventoryRepository.recordPurchase(event.purchase);
        emit(const InventoryOperationSuccess('Purchase recorded successfully'));
        add(LoadInventory(event.purchase.restaurantId));
      } catch (e) {
        emit(InventoryError(e.toString()));
      }
    }
  }
}
