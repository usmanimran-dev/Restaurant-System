import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/combo_model.dart';

abstract class ComboState extends Equatable {
  const ComboState();
  @override
  List<Object?> get props => [];
}

class ComboInitial extends ComboState {}
class ComboLoading extends ComboState {}

class CombosLoaded extends ComboState {
  final List<ComboModel> combos;
  const CombosLoaded(this.combos);
  @override
  List<Object?> get props => [combos];
}

class ComboError extends ComboState {
  final String message;
  const ComboError(this.message);
  @override
  List<Object?> get props => [message];
}
