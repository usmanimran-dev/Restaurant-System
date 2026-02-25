import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/menu_model.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object?> get props => [];
}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  final List<MenuCategoryModel> categories;
  final List<MenuItemModel> items;

  const MenuLoaded({required this.categories, required this.items});

  @override
  List<Object?> get props => [categories, items];
}

class MenuError extends MenuState {
  final String message;
  const MenuError(this.message);

  @override
  List<Object?> get props => [message];
}

class MenuOperationSuccess extends MenuState {
  final String message;
  const MenuOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
