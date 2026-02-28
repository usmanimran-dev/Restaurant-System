import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/modifier_model.dart';

abstract class ModifierEvent extends Equatable {
  const ModifierEvent();
  @override
  List<Object?> get props => [];
}

class LoadModifierGroups extends ModifierEvent {
  final String restaurantId;
  const LoadModifierGroups(this.restaurantId);
  @override
  List<Object?> get props => [restaurantId];
}

class LoadModifierItems extends ModifierEvent {
  final String groupId;
  const LoadModifierItems(this.groupId);
  @override
  List<Object?> get props => [groupId];
}

class CreateModifierGroup extends ModifierEvent {
  final ModifierGroupModel group;
  const CreateModifierGroup(this.group);
  @override
  List<Object?> get props => [group];
}

class CreateModifierItem extends ModifierEvent {
  final ModifierItemModel item;
  const CreateModifierItem(this.item);
  @override
  List<Object?> get props => [item];
}

class DeleteModifierGroup extends ModifierEvent {
  final String groupId;
  final String restaurantId;
  const DeleteModifierGroup(this.groupId, this.restaurantId);
  @override
  List<Object?> get props => [groupId, restaurantId];
}

class DeleteModifierItem extends ModifierEvent {
  final String itemId;
  final String groupId;
  const DeleteModifierItem(this.itemId, this.groupId);
  @override
  List<Object?> get props => [itemId, groupId];
}
