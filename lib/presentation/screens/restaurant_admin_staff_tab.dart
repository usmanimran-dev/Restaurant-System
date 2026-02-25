import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/core/di/injection_container.dart';
import 'package:restaurant/data/models/employee_model.dart';
import 'package:restaurant/domain/blocs/auth/auth_bloc.dart';
import 'package:restaurant/domain/blocs/auth/auth_state.dart';
import 'package:restaurant/domain/blocs/employee/employee_bloc.dart';
import 'package:restaurant/domain/blocs/employee/employee_event.dart';
import 'package:restaurant/domain/blocs/employee/employee_state.dart';
import 'package:restaurant/presentation/widgets/loading_widget.dart';
import 'package:restaurant/presentation/widgets/permission_guard.dart';

class StaffTab extends StatelessWidget {
  const StaffTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return const SizedBox();

    return BlocProvider(
      create: (_) => sl<EmployeeBloc>()..add(LoadEmployees(authState.user.restaurantId!)),
      child: _StaffTabView(restaurantId: authState.user.restaurantId!),
    );
  }
}

class _StaffTabView extends StatelessWidget {
  final String restaurantId;
  const _StaffTabView({required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Staff Directory',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage employees and base salaries',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
            PermissionGuard(
              permissionKey: 'employees.create',
              fallback: const SizedBox(),
              child: ElevatedButton.icon(
                onPressed: () => _showAddEmployeeDialog(context),
                icon: const Icon(Icons.person_add),
                label: const Text('Add Employee'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: BlocConsumer<EmployeeBloc, EmployeeState>(
            listener: (context, state) {
              if (state is EmployeeError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: theme.colorScheme.error));
              }
              if (state is EmployeeOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
              }
            },
            builder: (context, state) {
              if (state is EmployeeLoading) return const LoadingWidget();
              if (state is EmployeeLoaded) {
                if (state.employees.isEmpty) return const Center(child: Text('No employees found.'));
                return ListView.builder(
                  itemCount: state.employees.length,
                  itemBuilder: (context, index) {
                    final emp = state.employees[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                          child: Text(emp.name.substring(0, 1).toUpperCase()),
                        ),
                        title: Text(emp.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        subtitle: Text('${emp.roleName ?? "Unknown Role"} • ${emp.email}'),
                        trailing: Text(
                          '\$${emp.baseSalary.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.secondary),
                        ),
                      ),
                    );
                  },
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
    final passCtrl = TextEditingController();
    final salaryCtrl = TextEditingController();
    String roleVal = 'Cashier';
    final authState = parentContext.read<AuthBloc>().state as Authenticated;

    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('Add Employee'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => !v!.contains('@') ? 'Invalid email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passCtrl,
                  decoration: const InputDecoration(labelText: 'Initial Password (min 6)'),
                  obscureText: true,
                  validator: (v) => v!.length < 6 ? 'Too short' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: roleVal,
                  decoration: const InputDecoration(labelText: 'Role / Designation'),
                  items: ['Manager', 'Cashier', 'Chef', 'Waiter'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) => roleVal = v!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: salaryCtrl,
                  decoration: const InputDecoration(labelText: 'Base Salary'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ],
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
                      restaurantId: authState.user.restaurantId!,
                      name: nameCtrl.text,
                      email: emailCtrl.text,
                      roleId: roleVal.toLowerCase(), // Store a normalized roleId based on the selected role
                      roleName: roleVal,
                      baseSalary: double.tryParse(salaryCtrl.text) ?? 0.0,
                      joiningDate: DateTime.now(),
                    ),
                    passCtrl.text,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
