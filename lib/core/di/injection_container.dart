import 'package:get_it/get_it.dart';

import 'package:restaurant/data/repositories/auth_repository.dart';
import 'package:restaurant/data/repositories/supabase_repository.dart';
import 'package:restaurant/domain/blocs/auth/auth_bloc.dart';

import 'package:restaurant/data/repositories/tenant_repository.dart';
import 'package:restaurant/domain/blocs/tenant/tenant_bloc.dart';

import 'package:restaurant/data/repositories/employee_repository.dart';
import 'package:restaurant/data/repositories/role_repository.dart';
import 'package:restaurant/data/repositories/menu_repository.dart';
import 'package:restaurant/data/repositories/order_repository.dart';
import 'package:restaurant/data/repositories/salary_repository.dart';

import 'package:restaurant/domain/blocs/employee/employee_bloc.dart';
import 'package:restaurant/domain/blocs/role/role_bloc.dart';
import 'package:restaurant/domain/blocs/menu/menu_bloc.dart';
import 'package:restaurant/domain/blocs/order/order_bloc.dart';
import 'package:restaurant/domain/blocs/salary/salary_bloc.dart';
import 'package:restaurant/data/repositories/inventory_repository.dart';
import 'package:restaurant/data/repositories/reports_repository.dart';
import 'package:restaurant/domain/blocs/inventory/inventory_bloc.dart';
import 'package:restaurant/domain/blocs/reports/reports_bloc.dart';

/// Global service locator instance.
final GetIt sl = GetIt.instance;

/// Registers all dependencies. Must be called **after** [Supabase.initialize].
void setupDependencies() {
  // ── External ──────────────────────────────────────────────────────────────
  // Removed SupabaseClient

  // ── Repositories ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(),
  );
  sl.registerLazySingleton<SupabaseRepository>(
    () => SupabaseRepository(),
  );
  sl.registerLazySingleton<TenantRepository>(
    () => TenantRepository(sl<SupabaseRepository>()),
  );
  sl.registerLazySingleton<EmployeeRepository>(
    () => EmployeeRepository(sl<SupabaseRepository>()),
  );
  sl.registerLazySingleton<RoleRepository>(
    () => RoleRepository(sl<SupabaseRepository>()),
  );
  sl.registerLazySingleton<MenuRepository>(
    () => MenuRepository(sl<SupabaseRepository>()),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepository(sl<SupabaseRepository>()),
  );
  sl.registerLazySingleton<SalaryRepository>(
    () => SalaryRepository(sl<SupabaseRepository>()),
  );
  sl.registerLazySingleton<InventoryRepository>(
    () => InventoryRepository(sl<SupabaseRepository>()),
  );
  sl.registerLazySingleton<ReportsRepository>(
    () => ReportsRepository(sl<SupabaseRepository>()),
  );

  // ── BLoCs ─────────────────────────────────────────────────────────────────
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: sl<AuthRepository>()),
  );
  sl.registerFactory<TenantBloc>(
    () => TenantBloc(
      tenantRepository: sl<TenantRepository>(),
    ),
  );
  sl.registerFactory<EmployeeBloc>(
    () => EmployeeBloc(employeeRepository: sl<EmployeeRepository>()),
  );
  sl.registerFactory<RoleBloc>(
    () => RoleBloc(roleRepository: sl<RoleRepository>()),
  );
  sl.registerFactory<MenuBloc>(
    () => MenuBloc(menuRepository: sl<MenuRepository>()),
  );
  sl.registerFactory<OrderBloc>(
    () => OrderBloc(orderRepository: sl<OrderRepository>()),
  );
  sl.registerFactory<SalaryBloc>(
    () => SalaryBloc(salaryRepository: sl<SalaryRepository>()),
  );
  sl.registerFactory<InventoryBloc>(
    () => InventoryBloc(inventoryRepository: sl<InventoryRepository>()),
  );
  sl.registerFactory<ReportsBloc>(
    () => ReportsBloc(reportsRepository: sl<ReportsRepository>()),
  );
}
