import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/role_model.dart';

abstract class RoleEvent extends Equatable {
  const RoleEvent();

  @override
  List<Object?> get props => [];
}

class LoadRoles extends RoleEvent {
  final String restaurantId;
  const LoadRoles(this.restaurantId);

  @override
  List<Object?> get props => [restaurantId];
}

class CreateRole extends RoleEvent {
  final RoleModel role;
  const CreateRole(this.role);

  @override
  List<Object?> get props => [role];
}

class UpdateRolePermissions extends RoleEvent {
  final String roleId;
  final Map<String, dynamic> permissions;
  final String restaurantId;

  const UpdateRolePermissions(this.roleId, this.permissions, this.restaurantId);

  @override
  List<Object?> get props => [roleId, permissions, restaurantId];
}

class DeleteRole extends RoleEvent {
  final String roleId;
  final String restaurantId;

  const DeleteRole(this.roleId, this.restaurantId);

  @override
  List<Object?> get props => [roleId, restaurantId];
}
