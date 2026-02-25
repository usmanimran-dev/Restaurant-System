import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/core/di/injection_container.dart';
import 'package:restaurant/domain/blocs/auth/auth_bloc.dart';
import 'package:restaurant/domain/blocs/auth/auth_state.dart';
import 'package:restaurant/domain/blocs/role/role_bloc.dart';
import 'package:restaurant/domain/blocs/role/role_event.dart';
import 'package:restaurant/domain/blocs/role/role_state.dart';
import 'package:restaurant/data/models/role_model.dart';
import 'package:restaurant/presentation/widgets/loading_widget.dart';
import 'package:restaurant/presentation/widgets/permission_guard.dart';

class RolesTab extends StatelessWidget {
  const RolesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return const SizedBox();

    return BlocProvider(
      create: (_) => sl<RoleBloc>()..add(LoadRoles(authState.user.restaurantId!)),
      child: _RolesTabView(restaurantId: authState.user.restaurantId!),
    );
  }
}

class _RolesTabView extends StatelessWidget {
  final String restaurantId;
  const _RolesTabView({required this.restaurantId});

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
                  'Role Management',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage dynamic roles and permissions',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
            PermissionGuard(
              permissionKey: 'roles.create',
              fallback: const SizedBox(),
              child: ElevatedButton.icon(
                onPressed: () => _showAddRoleDialog(context),
                icon: const Icon(Icons.security),
                label: const Text('New Role'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: BlocConsumer<RoleBloc, RoleState>(
            listener: (context, state) {
              if (state is RoleError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: theme.colorScheme.error));
              }
              if (state is RoleOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
              }
            },
            builder: (context, state) {
              if (state is RoleLoading) return const LoadingWidget();
              if (state is RoleLoaded) {
                if (state.roles.isEmpty) return const Center(child: Text('No custom roles found.'));
                return ListView.builder(
                  itemCount: state.roles.length,
                  itemBuilder: (context, index) {
                    final role = state.roles[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: const Icon(Icons.shield_outlined),
                        title: Text(role.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        subtitle: Text('${role.permissions.length} explicit permissions assigned'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Module Permissions', style: theme.textTheme.titleMedium),
                                const SizedBox(height: 16),
                                _PermissionGrid(
                                  roleId: role.id,
                                  restaurantId: restaurantId,
                                  currentPermissions: role.permissions,
                                ),
                              ],
                            ),
                          )
                        ],
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

  void _showAddRoleDialog(BuildContext parentContext) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final authState = parentContext.read<AuthBloc>().state as Authenticated;

    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('Add Role'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Role Name (e.g., Senior Chef)'),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                parentContext.read<RoleBloc>().add(
                  CreateRole(
                    RoleModel(
                      id: '',
                      restaurantId: authState.user.restaurantId!,
                      name: nameCtrl.text,
                      permissions: const {}, // Start empty
                    ),
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _PermissionGrid extends StatefulWidget {
  final String roleId;
  final String restaurantId;
  final Map<String, dynamic> currentPermissions;

  const _PermissionGrid({
    required this.roleId,
    required this.restaurantId,
    required this.currentPermissions,
  });

  @override
  State<_PermissionGrid> createState() => _PermissionGridState();
}

class _PermissionGridState extends State<_PermissionGrid> {
  late Map<String, dynamic> _localPerms;

  static const _modules = [
    'menu', 'orders', 'inventory', 'employees', 'roles', 'salary', 'reports'
  ];
  static const _actions = ['view', 'create', 'edit', 'delete'];

  @override
  void initState() {
    super.initState();
    _localPerms = Map<String, dynamic>.from(widget.currentPermissions);
  }

  void _togglePerm(String mod, String act, bool? val) {
    setState(() {
      _localPerms['$mod.$act'] = val ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Table(
          border: TableBorder.all(color: theme.hintColor.withValues(alpha: 0.2)),
          children: [
            TableRow(
              decoration: BoxDecoration(color: theme.colorScheme.surface),
              children: [
                const Padding(padding: EdgeInsets.all(8), child: Text('Module', style: TextStyle(fontWeight: FontWeight.bold))),
                for (final act in _actions)
                  Padding(padding: const EdgeInsets.all(8), child: Text(act.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            for (final mod in _modules)
              TableRow(
                children: [
                  Padding(padding: const EdgeInsets.all(12), child: Text(mod.toUpperCase())),
                  for (final act in _actions)
                    Checkbox(
                      value: _localPerms['$mod.$act'] == true,
                      onChanged: (val) => _togglePerm(mod, act, val),
                    ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: PermissionGuard(
            permissionKey: 'roles.edit',
            fallback: const SizedBox(),
            child: ElevatedButton(
              onPressed: () {
                context.read<RoleBloc>().add(
                  UpdateRolePermissions(widget.roleId, _localPerms, widget.restaurantId)
                );
              },
              child: const Text('Save Permissions'),
            ),
          ),
        )
      ],
    );
  }
}
