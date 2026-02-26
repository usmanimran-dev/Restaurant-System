import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/menu_model.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

class LoadMenu extends MenuEvent {
  final String restaurantId;
  const LoadMenu(this.restaurantId);

  @override
  List<Object?> get props => [restaurantId];
}

class CreateCategory extends MenuEvent {
  final MenuCategoryModel category;
  const CreateCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class CreateMenuItem extends MenuEvent {
  final MenuItemModel item;
  const CreateMenuItem(this.item);

  @override
  List<Object?> get props => [item];
}

class UpdateCategory extends MenuEvent {
  final String id;
  final String restaurantId;
  final Map<String, dynamic> data;
  const UpdateCategory(this.id, this.restaurantId, this.data);

  @override
  List<Object?> get props => [id, restaurantId, data];
}

class DeleteCategory extends MenuEvent {
  final String id;
  final String restaurantId;
  const DeleteCategory(this.id, this.restaurantId);

  @override
  List<Object?> get props => [id, restaurantId];
}

class UpdateMenuItem extends MenuEvent {
  final String id;
  final String restaurantId;
  final Map<String, dynamic> data;
  const UpdateMenuItem(this.id, this.restaurantId, this.data);

  @override
  List<Object?> get props => [id, restaurantId, data];
}

class DeleteMenuItem extends MenuEvent {
  final String id;
  final String restaurantId;
  const DeleteMenuItem(this.id, this.restaurantId);

  @override
  List<Object?> get props => [id, restaurantId];
}
