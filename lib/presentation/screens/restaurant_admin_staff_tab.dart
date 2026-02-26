import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/core/di/injection_container.dart';
import 'package:restaurant/data/models/employee_model.dart';
import 'package:restaurant/domain/blocs/auth/auth_bloc.dart';
import 'package:restaurant/domain/blocs/auth/auth_state.dart';
import 'package:restaurant/domain/blocs/employee/employee_bloc.dart';
import 'package:restaurant/domain/blocs/employee/employee_event.dart';
import 'package:restaurant/domain/blocs/employee/employee_state.dart';
import 'package:restaurant/domain/blocs/role/role_bloc.dart';
import 'package:restaurant/domain/blocs/role/role_event.dart';
import 'package:restaurant/domain/blocs/role/role_state.dart';
import 'package:restaurant/presentation/widgets/loading_widget.dart';
import 'package:restaurant/presentation/widgets/permission_guard.dart';

class StaffTab extends StatelessWidget {
  const StaffTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return const SizedBox();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<EmployeeBloc>()..add(LoadEmployees(authState.user.restaurantId!))),
        BlocProvider(create: (_) => sl<RoleBloc>()..add(LoadRoles(authState.user.restaurantId!))),
      ],
      child: _StaffTabView(restaurantId: authState.user.restaurantId!),
    );
  }
}

class _StaffTabView extends StatefulWidget {
  final String restaurantId;
  const _StaffTabView({required this.restaurantId});

  @override
  State<_StaffTabView> createState() => _StaffTabViewState();
}

class _StaffTabViewState extends State<_StaffTabView> {
  String _searchQuery = '';
  String _sortBy = 'name'; // name, salary, role, date
  String _filterRole = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Staff Directory',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700, color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage employees, roles and salaries',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
            PermissionGuard(
              permissionKey: 'employees.create',
              fallback: const SizedBox(),
              child: ElevatedButton.icon(
                onPressed: () => _showAddEmployeeDialog(context),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Add Employee'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(180, 48)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Search, Filter & Sort Bar ────────────────────────────────
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by name, email, or phone...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: BlocBuilder<EmployeeBloc, EmployeeState>(
                builder: (context, state) {
                  final roles = <String>{'All'};
                  if (state is EmployeeLoaded) {
                    for (var emp in state.employees) {
                      roles.add(emp.roleName ?? 'Unknown');
                    }
                  }
                  return DropdownButtonFormField<String>(
                    value: roles.contains(_filterRole) ? _filterRole : 'All',
                    decoration: InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    isExpanded: true,
                    items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (v) => setState(() => _filterRole = v!),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: _sortBy,
              underline: const SizedBox(),
              icon: const Icon(Icons.sort),
              items: const [
                DropdownMenuItem(value: 'name', child: Text('Name')),
                DropdownMenuItem(value: 'salary', child: Text('Salary')),
                DropdownMenuItem(value: 'role', child: Text('Role')),
                DropdownMenuItem(value: 'date', child: Text('Date')),
              ],
              onChanged: (v) => setState(() => _sortBy = v!),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Employee List ────────────────────────────────────────────
        Expanded(
          child: BlocConsumer<EmployeeBloc, EmployeeState>(
            listener: (context, state) {
              if (state is EmployeeError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: theme.colorScheme.error),
                );
              }
              if (state is EmployeeOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                );
              }
            },
            builder: (context, state) {
              if (state is EmployeeLoading) return const LoadingWidget();
              if (state is EmployeeLoaded) {
                var employees = state.employees.toList();

                // Filter by search
                if (_searchQuery.isNotEmpty) {
                  employees = employees.where((e) =>
                    e.name.toLowerCase().contains(_searchQuery) ||
                    e.email.toLowerCase().contains(_searchQuery) ||
                    (e.phone?.toLowerCase().contains(_searchQuery) ?? false)
                  ).toList();
                }

                // Filter by role
                if (_filterRole != 'All') {
                  employees = employees.where((e) => e.roleName == _filterRole).toList();
                }

                // Sort
                switch (_sortBy) {
                  case 'salary':
                    employees.sort((a, b) => b.baseSalary.compareTo(a.baseSalary));
                    break;
                  case 'role':
                    employees.sort((a, b) => (a.roleName ?? '').compareTo(b.roleName ?? ''));
                    break;
                  case 'date':
                    employees.sort((a, b) => (b.joiningDate ?? DateTime(2000)).compareTo(a.joiningDate ?? DateTime(2000)));
                    break;
                  default:
                    employees.sort((a, b) => a.name.compareTo(b.name));
                }

                if (employees.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: theme.hintColor.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty && _filterRole == 'All'
                              ? 'No employees found'
                              : 'No matching employees',
                          style: TextStyle(color: theme.hintColor, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                // Stats bar
                final totalSalary = employees.fold<double>(0, (sum, e) => sum + e.baseSalary);
                
                return Column(
                  children: [
                    // Stats
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.hintColor.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(icon: Icons.people, label: 'Total', value: '${employees.length}'),
                          _StatItem(icon: Icons.attach_money, label: 'Monthly Payroll', value: '\$${totalSalary.toStringAsFixed(0)}'),
                          _StatItem(
                            icon: Icons.trending_up,
                            label: 'Avg Salary',
                            value: '\$${(totalSalary / employees.length).toStringAsFixed(0)}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // List
                    Expanded(
                      child: ListView.builder(
                        itemCount: employees.length,
                        itemBuilder: (context, index) {
                          final emp = employees[index];
                          return _EmployeeCard(
                            employee: emp,
                            restaurantId: widget.restaurantId,
                            onEdit: () => _showEditEmployeeDialog(context, emp),
                            onDelete: () => _confirmDeleteEmployee(context, emp),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  void _showAddEmployeeDialog(BuildContext parentContext) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final salaryCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String? selectedRoleId;
    String selectedRoleName = 'employee';

    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('Add Employee'),
        content: SizedBox(
          width: 500,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Personal Information', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person)),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email Address *', prefixIcon: Icon(Icons.email)),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => !v!.contains('@') ? 'Enter a valid email' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passCtrl,
                    decoration: const InputDecoration(labelText: 'Password (min 6) *', prefixIcon: Icon(Icons.lock)),
                    obscureText: true,
                    validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 24),
                  Text('Employment Details', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 12),
                  // Role dropdown from BLoC
                  BlocBuilder<RoleBloc, RoleState>(
                    builder: (context, roleState) {
                      final roles = roleState is RoleLoaded ? roleState.roles : [];
                      final dropdownItems = <DropdownMenuItem<String>>[
                        const DropdownMenuItem(value: 'employee', child: Text('Employee (Default)')),
                        ...roles.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))),
                      ];
                      return DropdownButtonFormField<String>(
                        value: selectedRoleId ?? 'employee',
                        decoration: const InputDecoration(labelText: 'Role / Position', prefixIcon: Icon(Icons.badge)),
                        items: dropdownItems,
                        onChanged: (v) {
                          selectedRoleId = v;
                          if (v == 'employee') {
                            selectedRoleName = 'employee';
                          } else {
                            final role = roles.cast().firstWhere((r) => r.id == v, orElse: () => null);
                            selectedRoleName = role?.name ?? 'employee';
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: salaryCtrl,
                    decoration: const InputDecoration(labelText: 'Base Salary *', prefixIcon: Icon(Icons.attach_money)),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                parentContext.read<EmployeeBloc>().add(
                  CreateEmployee(
                    EmployeeModel(
                      id: '',
                      restaurantId: widget.restaurantId,
                      name: nameCtrl.text,
                      email: emailCtrl.text,
                      phone: phoneCtrl.text.isNotEmpty ? phoneCtrl.text : null,
                      roleId: selectedRoleId ?? 'employee',
                      roleName: selectedRoleName,
                      baseSalary: double.tryParse(salaryCtrl.text) ?? 0.0,
                      joiningDate: DateTime.now(),
                    ),
                    passCtrl.text,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create Employee'),
          ),
        ],
      ),
    );
  }

  void _showEditEmployeeDialog(BuildContext parentContext, EmployeeModel emp) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: emp.name);
    final phoneCtrl = TextEditingController(text: emp.phone ?? '');
    final salaryCtrl = TextEditingController(text: emp.baseSalary.toStringAsFixed(2));

    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: Text('Edit ${emp.name}'),
        content: SizedBox(
          width: 450,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person)),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    enabled: false,
                    controller: TextEditingController(text: emp.email),
                    decoration: const InputDecoration(labelText: 'Email (read-only)', prefixIcon: Icon(Icons.email)),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: salaryCtrl,
                    decoration: const InputDecoration(labelText: 'Base Salary *', prefixIcon: Icon(Icons.attach_money)),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                parentContext.read<EmployeeBloc>().add(
                  UpdateEmployee(emp.id, widget.restaurantId, {
                    'name': nameCtrl.text,
                    'phone': phoneCtrl.text,
                    'base_salary': double.tryParse(salaryCtrl.text) ?? 0.0,
                  }),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteEmployee(BuildContext parentContext, EmployeeModel emp) {
    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: Row(children: [
          Icon(Icons.warning_rounded, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8),
          const Text('Delete Employee'),
        ]),
        content: Text('Are you sure you want to remove "${emp.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              parentContext.read<EmployeeBloc>().add(DeleteEmployee(emp.id, widget.restaurantId));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Employee Card ────────────────────────────────────────────────────────────

class _EmployeeCard extends StatelessWidget {
  final EmployeeModel employee;
  final String restaurantId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EmployeeCard({
    required this.employee,
    required this.restaurantId,
    required this.onEdit,
    required this.onDelete,
  });

  Color _roleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'head chef':
      case 'chef':
        return const Color(0xFFFF6B6B);
      case 'sous chef':
        return const Color(0xFFFF9F43);
      case 'manager':
        return const Color(0xFF6C63FF);
      case 'waiter':
      case 'waitress':
        return const Color(0xFF03DAC6);
      case 'bartender':
        return const Color(0xFFFFA726);
      default:
        return const Color(0xFF78909C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roleColor = _roleColor(employee.roleName);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: roleColor.withValues(alpha: 0.2),
              child: Text(
                employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
                style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(employee.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15), overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          employee.roleName ?? 'Unknown',
                          style: TextStyle(color: roleColor, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.email_outlined, size: 13, color: theme.hintColor),
                          const SizedBox(width: 4),
                          Text(employee.email, style: TextStyle(color: theme.hintColor, fontSize: 13), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                      if (employee.phone != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.phone_outlined, size: 13, color: theme.hintColor),
                            const SizedBox(width: 4),
                            Text(employee.phone!, style: TextStyle(color: theme.hintColor, fontSize: 13)),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Salary
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${employee.baseSalary.toStringAsFixed(0)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('/month', style: TextStyle(color: theme.hintColor, fontSize: 11)),
              ],
            ),
            const SizedBox(width: 12),
            // Actions
            PermissionGuard(
              permissionKey: 'employees.edit',
              fallback: const SizedBox(),
              child: IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: 'Edit',
                onPressed: onEdit,
              ),
            ),
            PermissionGuard(
              permissionKey: 'employees.delete',
              fallback: const SizedBox(),
              child: IconButton(
                icon: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
                tooltip: 'Delete',
                onPressed: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats Item ──────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: theme.hintColor, fontSize: 11)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
          ],
        ),
      ],
    );
  }
}
