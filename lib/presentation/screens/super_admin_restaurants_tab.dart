import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/config/router.dart';
import 'package:restaurant/core/di/injection_container.dart';
import 'package:restaurant/domain/blocs/auth/auth_bloc.dart';
import 'package:restaurant/domain/blocs/auth/auth_event.dart';
import 'package:restaurant/domain/blocs/tenant/tenant_bloc.dart';
import 'package:restaurant/domain/blocs/tenant/tenant_event.dart';
import 'package:restaurant/domain/blocs/tenant/tenant_state.dart';
import 'package:restaurant/presentation/widgets/loading_widget.dart';

class RestaurantsTab extends StatelessWidget {
  const RestaurantsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TenantBloc>()..add(LoadTenants()),
      child: const _RestaurantsTabView(),
    );
  }
}

class _RestaurantsTabView extends StatelessWidget {
  const _RestaurantsTabView();

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
                  'Restaurants',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage all tenants and feature flags',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _seedDemoData(context),
                  icon: const Icon(Icons.rocket_launch),
                  label: const Text('Generate Demo Data'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 48),
                    backgroundColor: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showCreateDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Restaurant'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 48),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: BlocConsumer<TenantBloc, TenantState>(
            listener: (context, state) {
              if (state is TenantError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: theme.colorScheme.error),
                );
              }
              if (state is TenantOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                );
              }
            },
            builder: (context, state) {
              if (state is TenantLoading) {
                return const LoadingWidget(message: 'Loading restaurants...');
              }
              
              if (state is TenantLoaded) {
                if (state.tenants.isEmpty) {
                  return const Center(child: Text('No restaurants found.'));
                }

                return ListView.builder(
                  itemCount: state.tenants.length,
                  itemBuilder: (context, index) {
                    final tenant = state.tenants[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 64, height: 64,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.restaurant, color: theme.colorScheme.primary, size: 32),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tenant.name,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (tenant.address != null) ...[
                                    const SizedBox(height: 4),
                                    Text(tenant.address!, style: TextStyle(color: theme.hintColor)),
                                  ],
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text('Modules', style: theme.textTheme.labelLarge),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _FeatureChip(
                                        label: 'POS & Orders',
                                        isEnabled: tenant.enabledModules['pos'] ?? false,
                                        onToggle: (val) => context.read<TenantBloc>().add(ToggleModule(tenant.id, 'pos', val)),
                                      ),
                                      _FeatureChip(
                                        label: 'Inventory',
                                        isEnabled: tenant.enabledModules['inventory'] ?? false,
                                        onToggle: (val) => context.read<TenantBloc>().add(ToggleModule(tenant.id, 'inventory', val)),
                                      ),
                                      _FeatureChip(
                                        label: 'Salary & HR',
                                        isEnabled: tenant.enabledModules['salary'] ?? false,
                                        onToggle: (val) => context.read<TenantBloc>().add(ToggleModule(tenant.id, 'salary', val)),
                                      ),
                                      _FeatureChip(
                                        label: 'Reports & Analytics',
                                        isEnabled: tenant.enabledModules['reports'] ?? false,
                                        onToggle: (val) => context.read<TenantBloc>().add(ToggleModule(tenant.id, 'reports', val)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // ── Manage Button ──────────────────────
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        context.read<AuthBloc>().add(
                                          SwitchRestaurantContext(
                                            restaurantId: tenant.id,
                                            restaurantName: tenant.name,
                                          ),
                                        );
                                        Navigator.of(context).pushReplacementNamed(
                                          Routes.restaurantAdmin,
                                        );
                                      },
                                      icon: const Icon(Icons.open_in_new),
                                      label: const Text('Manage Restaurant'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        backgroundColor: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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

  void _showCreateDialog(BuildContext parentContext) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final adminEmailCtrl = TextEditingController();
    final adminPassCtrl = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('New Restaurant'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Restaurant Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: adminEmailCtrl,
                decoration: const InputDecoration(labelText: 'Admin Email'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: adminPassCtrl,
                decoration: const InputDecoration(labelText: 'Admin Password (min 6)'),
                obscureText: true,
                validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                parentContext.read<TenantBloc>().add(
                  CreateTenant(
                    name: nameCtrl.text,
                    adminEmail: adminEmailCtrl.text,
                    adminPassword: adminPassCtrl.text,
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

  Future<void> _seedDemoData(BuildContext context) async {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating Demo Data...')),
    );

    try {
      final firestore = FirebaseFirestore.instance;
      final String demoUid = 'Zvt5eVRmM2MPeFR8Sj9WnghLjdW2'; // Master UID
      final String demoRid = 'demo-restaurant-123';

      // 1. Ensure Restaurant exists
      await firestore.collection('restaurants').doc(demoRid).set({
        'name': 'Zyfloatix Luxury Dining',
        'address': '123 Elite Street, Tech City',
        'contact': '+1 234 567 890',
        'enabled_modules': {
          'pos': true,
          'inventory': true,
          'salary': true,
          'reports': true,
        },
        'settings': {'currency': 'USD', 'tax_rate': 0.16},
        'created_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      // 2. Ensure User (Super Admin) exists
      await firestore.collection('users').doc(demoUid).set({
        'email': 'admin@zyfloatix.com',
        'name': 'Master Admin',
        'restaurant_id': null, 
        'role_id': 'super_admin_role',
        'role_name': 'super_admin',
        'roles': {'name': 'super_admin'}, 
        'created_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      // 3. Seed Menu Categories
      await firestore.collection('menu_categories').doc('cat-1').set({
        'restaurant_id': demoRid,
        'name': 'Main Course',
      }, SetOptions(merge: true));

      // 4. Seed Menu Items
      await firestore.collection('menu_items').doc('item-1').set({
        'restaurant_id': demoRid,
        'category_id': 'cat-1',
        'name': 'Wagyu Steak',
        'price': 45.0,
        'description': 'Premium wagyu beef served with truffle mash',
        'is_available': true,
      }, SetOptions(merge: true));
      await firestore.collection('menu_items').doc('item-2').set({
        'restaurant_id': demoRid,
        'category_id': 'cat-1',
        'name': 'Atlantic Salmon',
        'price': 32.0,
        'description': 'Fresh salmon with lemon butter sauce',
        'is_available': true,
      }, SetOptions(merge: true));

      // 5. Seed Inventory Categories
      await firestore.collection('inventory_categories').doc('inv-cat-1').set({
        'restaurant_id': demoRid,
        'name': 'Kitchen Supplies',
      }, SetOptions(merge: true));

      // 6. Seed Inventory Items
      await firestore.collection('inventory_items').doc('inv-item-1').set({
        'restaurant_id': demoRid,
        'category_id': 'inv-cat-1',
        'name': 'Premium Beef',
        'unit': 'kg',
        'quantity': 25.0,
        'minimum_stock': 5.0,
      }, SetOptions(merge: true));

      // 7. Seed Employees
      await firestore.collection('employees').doc('emp-1').set({
        'restaurant_id': demoRid,
        'name': 'John Doe',
        'role': 'Chef',
        'base_salary': 3500.0,
        'joining_date': '2024-01-15',
      }, SetOptions(merge: true));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo Data successfully generated! Refreshing...'), backgroundColor: Colors.green),
        );
        context.read<TenantBloc>().add(LoadTenants());
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate demo data: $e'), backgroundColor: theme.colorScheme.error),
        );
      }
    }
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const _FeatureChip({
    required this.label,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilterChip(
      selected: isEnabled,
      label: Text(label),
      onSelected: onToggle,
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isEnabled ? theme.colorScheme.primary : theme.hintColor.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
