import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/data/repositories/role_repository.dart';
import 'package:restaurant/domain/blocs/role/role_event.dart';
import 'package:restaurant/domain/blocs/role/role_state.dart';

class RoleBloc extends Bloc<RoleEvent, RoleState> {
  final RoleRepository _roleRepository;

  RoleBloc({required RoleRepository roleRepository})
      : _roleRepository = roleRepository,
        super(RoleInitial()) {
    on<LoadRoles>(_onLoadRoles);
    on<CreateRole>(_onCreateRole);
    on<UpdateRolePermissions>(_onUpdateRolePermissions);
  }

  Future<void> _onLoadRoles(LoadRoles event, Emitter<RoleState> emit) async {
    emit(RoleLoading());
    try {
      final roles = await _roleRepository.fetchRoles(event.restaurantId);
      emit(RoleLoaded(roles));
    } catch (e) {
      emit(RoleError(e.toString()));
    }
  }

  Future<void> _onCreateRole(CreateRole event, Emitter<RoleState> emit) async {
    emit(RoleLoading());
    try {
      await _roleRepository.createRole(event.role);
      emit(const RoleOperationSuccess('Role created successfully.'));
      if (event.role.restaurantId != null) {
        add(LoadRoles(event.role.restaurantId!));
      }
    } catch (e) {
      emit(RoleError(e.toString()));
    }
  }

  Future<void> _onUpdateRolePermissions(UpdateRolePermissions event, Emitter<RoleState> emit) async {
    try {
      await _roleRepository.updateRole(event.roleId, {'permissions': event.permissions});
      emit(const RoleOperationSuccess('Permissions updated successfully.'));
      add(LoadRoles(event.restaurantId));
    } catch (e) {
      emit(RoleError(e.toString()));
    }
  }
}
