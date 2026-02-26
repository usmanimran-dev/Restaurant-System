import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/inventory_model.dart';

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadInventory extends InventoryEvent {
  final String restaurantId;
  const LoadInventory(this.restaurantId);
  @override
  List<Object?> get props => [restaurantId];
}

class CreateInventoryCategory extends InventoryEvent {
  final InventoryCategoryModel category;
  const CreateInventoryCategory(this.category);
  @override
  List<Object?> get props => [category];
}

class CreateInventoryItem extends InventoryEvent {
  final InventoryItemModel item;
  const CreateInventoryItem(this.item);
  @override
  List<Object?> get props => [item];
}

class RecordPurchase extends InventoryEvent {
  final PurchaseModel purchase;
  const RecordPurchase(this.purchase);
  @override
  List<Object?> get props => [purchase];
}

class UpdateInventoryCategory extends InventoryEvent {
  final String id;
  final String restaurantId;
  final Map<String, dynamic> data;
  const UpdateInventoryCategory(this.id, this.restaurantId, this.data);
  @override
  List<Object?> get props => [id, restaurantId, data];
}

class DeleteInventoryCategory extends InventoryEvent {
  final String id;
  final String restaurantId;
  const DeleteInventoryCategory(this.id, this.restaurantId);
  @override
  List<Object?> get props => [id, restaurantId];
}

class UpdateInventoryItem extends InventoryEvent {
  final String id;
  final String restaurantId;
  final Map<String, dynamic> data;
  const UpdateInventoryItem(this.id, this.restaurantId, this.data);
  @override
  List<Object?> get props => [id, restaurantId, data];
}

class DeleteInventoryItem extends InventoryEvent {
  final String id;
  final String restaurantId;
  const DeleteInventoryItem(this.id, this.restaurantId);
  @override
  List<Object?> get props => [id, restaurantId];
}
