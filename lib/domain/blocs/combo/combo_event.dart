import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/combo_model.dart';

abstract class ComboEvent extends Equatable {
  const ComboEvent();
  @override
  List<Object?> get props => [];
}

class LoadCombos extends ComboEvent {
  final String restaurantId;
  const LoadCombos(this.restaurantId);
  @override
  List<Object?> get props => [restaurantId];
}

class CreateCombo extends ComboEvent {
  final ComboModel combo;
  const CreateCombo(this.combo);
  @override
  List<Object?> get props => [combo];
}

class UpdateCombo extends ComboEvent {
  final String id;
  final Map<String, dynamic> updates;
  final String restaurantId;
  const UpdateCombo(this.id, this.updates, this.restaurantId);
  @override
  List<Object?> get props => [id, updates, restaurantId];
}

class DeleteCombo extends ComboEvent {
  final String id;
  final String restaurantId;
  const DeleteCombo(this.id, this.restaurantId);
  @override
  List<Object?> get props => [id, restaurantId];
}
