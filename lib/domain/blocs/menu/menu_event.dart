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
