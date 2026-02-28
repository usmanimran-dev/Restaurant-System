import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/modifier_model.dart';

abstract class ModifierState extends Equatable {
  const ModifierState();
  @override
  List<Object?> get props => [];
}

class ModifierInitial extends ModifierState {}

class ModifierLoading extends ModifierState {}

class ModifierGroupsLoaded extends ModifierState {
  final List<ModifierGroupModel> groups;
  const ModifierGroupsLoaded(this.groups);
  @override
  List<Object?> get props => [groups];
}

class ModifierItemsLoaded extends ModifierState {
  final List<ModifierItemModel> items;
  final String groupId;
  const ModifierItemsLoaded(this.items, this.groupId);
  @override
  List<Object?> get props => [items, groupId];
}

class ModifierError extends ModifierState {
  final String message;
  const ModifierError(this.message);
  @override
  List<Object?> get props => [message];
}
