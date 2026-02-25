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
      // Create Tenant
      final newTenant = RestaurantModel(
        id: '', // Supabase generated
        name: event.name,
        address: event.address,
        contact: event.contact,
        enabledModules: const {
          'pos': true,
          'inventory': false,
          'reports': true,
          'salary': false,
        },
      );
      
      final createdTenant = await _tenantRepository.createTenant(newTenant);

      // Supabase Edge Functions avoided in local mock mode.
      // Simply log the request (the new restaurant will show up as a tenant).
      print('Mock: Created new restaurant admin for tenant ${createdTenant.id} with email ${event.adminEmail}');

      emit(const TenantOperationSuccess('Tenant created successfully'));
      add(LoadTenants());
    } catch (e) {
      emit(TenantError(e.toString()));
      add(LoadTenants()); // Reload to show previous state
    }
  }

  Future<void> _onToggleModule(ToggleModule event, Emitter<TenantState> emit) async {
    try {
      await _tenantRepository.toggleFeatureFlag(event.tenantId, event.moduleKey, event.isEnabled);
      // We don't emit a separate loading state to avoid flashing the UI. Just reload.
      add(LoadTenants());
    } catch (e) {
      emit(TenantError(e.toString()));
    }
  }
}
