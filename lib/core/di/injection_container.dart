import 'package:get_it/get_it.dart';

import 'package:restaurant/data/repositories/auth_repository.dart';
import 'package:restaurant/data/repositories/firestore_repository.dart';
import 'package:restaurant/domain/blocs/auth/auth_bloc.dart';

import 'package:restaurant/data/repositories/tenant_repository.dart';
import 'package:restaurant/domain/blocs/tenant/tenant_bloc.dart';

import 'package:restaurant/data/repositories/employee_repository.dart';
import 'package:restaurant/data/repositories/role_repository.dart';
import 'package:restaurant/data/repositories/menu_repository.dart';
import 'package:restaurant/data/repositories/order_repository.dart';
import 'package:restaurant/data/repositories/salary_repository.dart';
import 'package:restaurant/data/repositories/inventory_repository.dart';
import 'package:restaurant/data/repositories/reports_repository.dart';
import 'package:restaurant/data/repositories/modifier_repository.dart';
import 'package:restaurant/data/repositories/combo_repository.dart';
import 'package:restaurant/data/repositories/discount_repository.dart';
import 'package:restaurant/data/repositories/tax_repository.dart';
import 'package:restaurant/data/repositories/audit_log_repository.dart';

// Phase 2 repositories
import 'package:restaurant/data/repositories/kds_repository.dart';
import 'package:restaurant/data/repositories/delivery_repository.dart';
import 'package:restaurant/data/repositories/supplier_repository.dart';
import 'package:restaurant/data/repositories/attendance_customer_repository.dart';

import 'package:restaurant/domain/blocs/employee/employee_bloc.dart';
import 'package:restaurant/domain/blocs/role/role_bloc.dart';
import 'package:restaurant/domain/blocs/menu/menu_bloc.dart';
import 'package:restaurant/domain/blocs/order/order_bloc.dart';
import 'package:restaurant/domain/blocs/salary/salary_bloc.dart';
import 'package:restaurant/domain/blocs/inventory/inventory_bloc.dart';
import 'package:restaurant/domain/blocs/reports/reports_bloc.dart';
import 'package:restaurant/domain/blocs/modifier/modifier_bloc.dart';
import 'package:restaurant/domain/blocs/combo/combo_bloc.dart';
import 'package:restaurant/domain/blocs/discount/discount_bloc.dart';
import 'package:restaurant/domain/blocs/tax/tax_bloc.dart';
import 'package:restaurant/domain/blocs/audit/audit_log_bloc.dart';

// Phase 2 BLoCs
import 'package:restaurant/domain/blocs/kds/kds_bloc.dart';
import 'package:restaurant/domain/blocs/delivery/delivery_bloc.dart';
import 'package:restaurant/domain/blocs/supplier/supplier_bloc.dart';
import 'package:restaurant/domain/blocs/customer/customer_bloc.dart';
import 'package:restaurant/domain/blocs/cart/cart_bloc.dart';

/// Global service locator instance.
final GetIt sl = GetIt.instance;

/// Registers all dependencies. Must be called **after** [Firebase.initializeApp].
void setupDependencies() {
  // ── Repositories ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(),
  );
  sl.registerLazySingleton<FirestoreRepository>(
    () => FirestoreRepository(),
  );
  sl.registerLazySingleton<TenantRepository>(
    () => TenantRepository(sl<FirestoreRepository>()),
  );
  sl.registerLazySingleton<EmployeeRepository>(
    () => EmployeeRepository(sl<FirestoreRepository>()),
  );
  sl.registerLazySingleton<RoleRepository>(
    () => RoleRepository(sl<FirestoreRepository>()),
  );
  sl.registerLazySingleton<MenuRepository>(
    () => MenuRepository(sl<FirestoreRepository>()),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepository(sl<FirestoreRepository>()),
  );
  sl.registerLazySingleton<SalaryRepository>(
    () => SalaryRepository(sl<FirestoreRepository>()),
  );
  sl.registerLazySingleton<InventoryRepository>(
    () => InventoryRepository(sl<FirestoreRepository>()),
  );
  sl.registerLazySingleton<ReportsRepository>(
    () => ReportsRepository(sl<FirestoreRepository>()),
  );

  // ── Phase 1 Repositories ──────────────────────────────────────────────────
  sl.registerLazySingleton<ModifierRepository>(
    () => ModifierRepository(sl<FirestoreRepository>()),
  );
  sl.registerLazySingleton<ComboRepository>(
    () => ComboRepository(sl<FirestoreRepository>()),
  );
  sl.registerLazySingleton<DiscountRepository>(
    () => DiscountRepository(sl<FirestoreRepository>()),
  );
  sl.registerLazySingleton<TaxRepository>(
    () => TaxRepository(sl<FirestoreRepository>()),
  );
  sl.registerLazySingleton<AuditLogRepository>(
    () => AuditLogRepository(sl<FirestoreRepository>()),
  );

  // ── Phase 2 Repositories ──────────────────────────────────────────────────
  sl.registerLazySingleton<KdsRepository>(
    () => KdsRepository(),
  );
  sl.registerLazySingleton<DeliveryRepository>(
    () => DeliveryRepository(sl<FirestoreRepository>()),
  );
  sl.registerLazySingleton<SupplierRepository>(
    () => SupplierRepository(sl<FirestoreRepository>()),
  );
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepository(sl<FirestoreRepository>()),
  );
  sl.registerLazySingleton<LoanRepository>(
    () => LoanRepository(sl<FirestoreRepository>()),
  );
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepository(sl<FirestoreRepository>()),
  );

  // ── BLoCs ─────────────────────────────────────────────────────────────────
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: sl<AuthRepository>()),
  );
  sl.registerFactory<TenantBloc>(
    () => TenantBloc(tenantRepository: sl<TenantRepository>()),
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

  // ── Phase 1 BLoCs ─────────────────────────────────────────────────────────
  sl.registerFactory<ModifierBloc>(
    () => ModifierBloc(modifierRepository: sl<ModifierRepository>()),
  );
  sl.registerFactory<ComboBloc>(
    () => ComboBloc(comboRepository: sl<ComboRepository>()),
  );
  sl.registerFactory<DiscountBloc>(
    () => DiscountBloc(discountRepository: sl<DiscountRepository>()),
  );
  sl.registerFactory<TaxBloc>(
    () => TaxBloc(taxRepository: sl<TaxRepository>()),
  );
  sl.registerFactory<AuditLogBloc>(
    () => AuditLogBloc(auditLogRepository: sl<AuditLogRepository>()),
  );

  // ── Phase 2 BLoCs ─────────────────────────────────────────────────────────
  sl.registerFactory<KdsBloc>(
    () => KdsBloc(kdsRepository: sl<KdsRepository>()),
  );
  sl.registerFactory<DeliveryBloc>(
    () => DeliveryBloc(deliveryRepository: sl<DeliveryRepository>()),
  );
  sl.registerFactory<SupplierBloc>(
    () => SupplierBloc(supplierRepository: sl<SupplierRepository>()),
  );
  sl.registerFactory<CustomerBloc>(
    () => CustomerBloc(customerRepository: sl<CustomerRepository>()),
  );
  sl.registerFactory<CartBloc>(
    () => CartBloc(orderRepository: sl<OrderRepository>()),
  );
}
