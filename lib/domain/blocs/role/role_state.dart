import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/role_model.dart';

abstract class RoleState extends Equatable {
  const RoleState();

  @override
  List<Object?> get props => [];
}

class RoleInitial extends RoleState {}

class RoleLoading extends RoleState {}

class RoleLoaded extends RoleState {
  final List<RoleModel> roles;

  const RoleLoaded(this.roles);

  @override
  List<Object?> get props => [roles];
}

class RoleError extends RoleState {
  final String message;

  const RoleError(this.message);

  @override
  List<Object?> get props => [message];
}

class RoleOperationSuccess extends RoleState {
  final String message;

  const RoleOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
