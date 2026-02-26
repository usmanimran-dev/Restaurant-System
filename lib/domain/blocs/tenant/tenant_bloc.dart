import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:restaurant/data/models/restaurant_model.dart';
import 'package:restaurant/data/repositories/tenant_repository.dart';
import 'package:restaurant/domain/blocs/tenant/tenant_event.dart';
import 'package:restaurant/domain/blocs/tenant/tenant_state.dart';

class TenantBloc extends Bloc<TenantEvent, TenantState> {
  final TenantRepository _tenantRepository;

  TenantBloc({
    required TenantRepository tenantRepository,
  })  : _tenantRepository = tenantRepository,
        super(TenantInitial()) {
    on<LoadTenants>(_onLoadTenants);
    on<CreateTenant>(_onCreateTenant);
    on<UpdateTenant>(_onUpdateTenant);
    on<DeleteTenant>(_onDeleteTenant);
    on<ToggleModule>(_onToggleModule);
  }

  Future<void> _onLoadTenants(LoadTenants event, Emitter<TenantState> emit) async {
    emit(TenantLoading());
    try {
      final tenants = await _tenantRepository.fetchAllTenants();
      emit(TenantLoaded(tenants));
    } catch (e) {
      emit(TenantError(e.toString()));
    }
  }

  Future<void> _onCreateTenant(CreateTenant event, Emitter<TenantState> emit) async {
    emit(TenantLoading());
    try {
      // Create Restaurant
      final newTenant = RestaurantModel(
        id: '',
        name: event.name,
        address: event.address,
        contact: event.contact,
        enabledModules: const {
          'pos': true,
          'inventory': true,
          'reports': true,
          'salary': true,
        },
      );
      
      final createdTenant = await _tenantRepository.createTenant(newTenant);

      // Automatically create a Restaurant Admin user
      await _tenantRepository.createRestaurantAdmin(
        restaurantId: createdTenant.id,
        email: event.adminEmail,
        password: event.adminPassword,
        name: event.adminName,
      );

      emit(const TenantOperationSuccess('Restaurant & Admin created successfully!'));
      add(LoadTenants());
    } catch (e) {
      emit(TenantError(e.toString()));
      add(LoadTenants());
    }
  }

  Future<void> _onUpdateTenant(UpdateTenant event, Emitter<TenantState> emit) async {
    try {
      await _tenantRepository.updateTenant(event.tenantId, event.updates);
      emit(const TenantOperationSuccess('Restaurant updated successfully.'));
      add(LoadTenants());
    } catch (e) {
      emit(TenantError(e.toString()));
    }
  }

  Future<void> _onDeleteTenant(DeleteTenant event, Emitter<TenantState> emit) async {
    try {
      await _tenantRepository.deleteTenant(event.tenantId);
      emit(const TenantOperationSuccess('Restaurant deleted successfully.'));
      add(LoadTenants());
    } catch (e) {
      emit(TenantError(e.toString()));
    }
  }

  Future<void> _onToggleModule(ToggleModule event, Emitter<TenantState> emit) async {
    try {
      await _tenantRepository.toggleFeatureFlag(event.tenantId, event.moduleKey, event.isEnabled);
      add(LoadTenants());
    } catch (e) {
      emit(TenantError(e.toString()));
    }
  }
}
