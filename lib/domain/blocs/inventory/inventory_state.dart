import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/inventory_model.dart';

abstract class InventoryState extends Equatable {
  const InventoryState();
  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<InventoryCategoryModel> categories;
  final List<InventoryItemModel> items;

  const InventoryLoaded({
    required this.categories,
    required this.items,
  });

  @override
  List<Object?> get props => [categories, items];
}

class InventoryError extends InventoryState {
  final String message;
  const InventoryError(this.message);
  @override
  List<Object?> get props => [message];
}

class InventoryOperationSuccess extends InventoryState {
  final String message;
  const InventoryOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
