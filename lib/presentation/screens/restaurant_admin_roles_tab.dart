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

class _RolesTabView extends StatefulWidget {
  final String restaurantId;
  const _RolesTabView({required this.restaurantId});

  @override
  State<_RolesTabView> createState() => _RolesTabViewState();
}

class _RolesTabViewState extends State<_RolesTabView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Role Management',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700, color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create roles and assign granular permissions per module',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
            PermissionGuard(
              permissionKey: 'roles.create',
              fallback: const SizedBox(),
              child: ElevatedButton.icon(
                onPressed: () => _showAddRoleDialog(context),
                icon: const Icon(Icons.add_moderator, size: 18),
                label: const Text('New Role'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(160, 48)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Search ──────────────────────────────────────────────────────
        TextField(
          decoration: InputDecoration(
            hintText: 'Search roles...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        ),
        const SizedBox(height: 24),

        // ── Content ─────────────────────────────────────────────────────
        Expanded(
          child: BlocConsumer<RoleBloc, RoleState>(
            listener: (context, state) {
              if (state is RoleError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: theme.colorScheme.error),
                );
              }
              if (state is RoleOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                );
              }
            },
            builder: (context, state) {
              if (state is RoleLoading) return const LoadingWidget();
              if (state is RoleLoaded) {
                var roles = state.roles.toList();

                if (_searchQuery.isNotEmpty) {
                  roles = roles.where((r) => r.name.toLowerCase().contains(_searchQuery)).toList();
                }

                if (roles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.security_outlined, size: 64, color: theme.hintColor.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? 'No roles created yet' : 'No matching roles',
                          style: TextStyle(color: theme.hintColor, fontSize: 16),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Create a role to define custom permissions for your staff',
                            style: TextStyle(color: theme.hintColor.withValues(alpha: 0.6), fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: roles.length,
                  itemBuilder: (context, index) {
                    final role = roles[index];
                    final grantedCount = role.permissions.values.where((v) => v == true).length;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.shield_outlined, color: theme.colorScheme.primary, size: 20),
                        ),
                        title: Text(role.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        subtitle: Text(
                          '$grantedCount permissions granted',
                          style: TextStyle(color: theme.hintColor, fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PermissionGuard(
                              permissionKey: 'roles.delete',
                              fallback: const SizedBox(),
                              child: IconButton(
                                icon: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
                                tooltip: 'Delete Role',
                                onPressed: () => _confirmDeleteRole(context, role),
                              ),
                            ),
                            const Icon(Icons.expand_more),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.grid_view, size: 16, color: theme.colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Text('Permission Matrix', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Toggle permissions per module (view, create, edit, delete)',
                                  style: TextStyle(color: theme.hintColor, fontSize: 12),
                                ),
                                const SizedBox(height: 16),
                                _PermissionGrid(
                                  roleId: role.id,
                                  restaurantId: widget.restaurantId,
                                  currentPermissions: role.permissions,
                                ),
                              ],
                            ),
                          ),
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
    final descCtrl = TextEditingController();
    final authState = parentContext.read<AuthBloc>().state as Authenticated;

    // Initial permissions – all false
    final Map<String, dynamic> initialPerms = {};
    for (var mod in _PermissionGridState._modules) {
      for (var act in _PermissionGridState._actions) {
        initialPerms['$mod.$act'] = false;
      }
    }

    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('Create New Role'),
        content: SizedBox(
          width: 500,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Role Name *',
                      hintText: 'e.g., Senior Chef, Floor Manager',
                      prefixIcon: Icon(Icons.badge),
                    ),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You can configure permissions after creating the role.',
                    style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
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
                parentContext.read<RoleBloc>().add(
                  CreateRole(
                    RoleModel(
                      id: '',
                      restaurantId: authState.user.restaurantId!,
                      name: nameCtrl.text,
                      permissions: initialPerms,
                    ),
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create Role'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteRole(BuildContext parentContext, RoleModel role) {
    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: Row(children: [
          Icon(Icons.warning_rounded, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8),
          const Text('Delete Role'),
        ]),
        content: Text('Are you sure you want to delete the "${role.name}" role? Employees assigned this role may lose their permissions.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              parentContext.read<RoleBloc>().add(DeleteRole(role.id, widget.restaurantId));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Permission Grid ─────────────────────────────────────────────────────────

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
  bool _hasChanges = false;

  static const _modules = [
    'menu', 'orders', 'inventory', 'employees', 'roles', 'salary', 'reports'
  ];
  static const _actions = ['view', 'create', 'edit', 'delete'];

  static const _moduleIcons = {
    'menu': Icons.restaurant_menu,
    'orders': Icons.receipt_long,
    'inventory': Icons.inventory_2,
    'employees': Icons.people,
    'roles': Icons.security,
    'salary': Icons.request_quote,
    'reports': Icons.analytics,
  };

  @override
  void initState() {
    super.initState();
    _localPerms = Map<String, dynamic>.from(widget.currentPermissions);
  }

  void _togglePerm(String mod, String act, bool? val) {
    setState(() {
      _localPerms['$mod.$act'] = val ?? false;
      _hasChanges = true;
    });
  }

  void _toggleAll(String mod, bool val) {
    setState(() {
      for (var act in _actions) {
        _localPerms['$mod.$act'] = val;
      }
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Matrix table
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.hintColor.withValues(alpha: 0.15)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Table(
              border: TableBorder.all(color: theme.hintColor.withValues(alpha: 0.1)),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
                5: FlexColumnWidth(1),
              },
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text('Module', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    for (final act in _actions)
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          act[0].toUpperCase() + act.substring(1),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text('All', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
                // Module rows
                for (final mod in _modules)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Row(
                          children: [
                            Icon(_moduleIcons[mod] ?? Icons.extension, size: 16, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              mod[0].toUpperCase() + mod.substring(1),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      for (final act in _actions)
                        Center(
                          child: Checkbox(
                            value: _localPerms['$mod.$act'] == true,
                            onChanged: (val) => _togglePerm(mod, act, val),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      // Toggle All
                      Center(
                        child: Checkbox(
                          value: _actions.every((act) => _localPerms['$mod.$act'] == true),
                          tristate: true,
                          onChanged: (val) => _toggleAll(mod, val ?? false),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Save button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_hasChanges)
              Text(
                'Unsaved changes',
                style: TextStyle(color: theme.colorScheme.secondary, fontSize: 12, fontStyle: FontStyle.italic),
              )
            else
              const SizedBox(),
            PermissionGuard(
              permissionKey: 'roles.edit',
              fallback: const SizedBox(),
              child: ElevatedButton.icon(
                onPressed: _hasChanges ? () {
                  context.read<RoleBloc>().add(
                    UpdateRolePermissions(widget.roleId, _localPerms, widget.restaurantId),
                  );
                  setState(() => _hasChanges = false);
                } : null,
                icon: const Icon(Icons.save, size: 18),
                label: const Text('Save Permissions'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
