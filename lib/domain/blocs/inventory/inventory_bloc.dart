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
    on<UpdateInventoryCategory>(_onUpdateCategory);
    on<DeleteInventoryCategory>(_onDeleteCategory);
    on<UpdateInventoryItem>(_onUpdateItem);
    on<DeleteInventoryItem>(_onDeleteItem);
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

  Future<void> _onUpdateCategory(UpdateInventoryCategory event, Emitter<InventoryState> emit) async {
    final currentState = state;
    if (currentState is InventoryLoaded) {
      try {
        await _inventoryRepository.updateCategory(event.id, event.data);
        emit(const InventoryOperationSuccess('Category updated successfully'));
        add(LoadInventory(event.restaurantId));
      } catch (e) {
        emit(InventoryError(e.toString()));
      }
    }
  }

  Future<void> _onDeleteCategory(DeleteInventoryCategory event, Emitter<InventoryState> emit) async {
    final currentState = state;
    if (currentState is InventoryLoaded) {
      try {
        await _inventoryRepository.deleteCategory(event.id);
        emit(const InventoryOperationSuccess('Category deleted successfully'));
        add(LoadInventory(event.restaurantId));
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

  Future<void> _onUpdateItem(UpdateInventoryItem event, Emitter<InventoryState> emit) async {
    final currentState = state;
    if (currentState is InventoryLoaded) {
      try {
        await _inventoryRepository.updateItem(event.id, event.data);
        emit(const InventoryOperationSuccess('Item updated successfully'));
        add(LoadInventory(event.restaurantId));
      } catch (e) {
        emit(InventoryError(e.toString()));
      }
    }
  }

  Future<void> _onDeleteItem(DeleteInventoryItem event, Emitter<InventoryState> emit) async {
    final currentState = state;
    if (currentState is InventoryLoaded) {
      try {
        await _inventoryRepository.deleteItem(event.id);
        emit(const InventoryOperationSuccess('Item deleted successfully'));
        add(LoadInventory(event.restaurantId));
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
