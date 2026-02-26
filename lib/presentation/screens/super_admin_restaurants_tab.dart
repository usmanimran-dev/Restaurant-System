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
import 'package:restaurant/data/models/restaurant_model.dart';
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

class _RestaurantsTabView extends StatefulWidget {
  const _RestaurantsTabView();

  @override
  State<_RestaurantsTabView> createState() => _RestaurantsTabViewState();
}

class _RestaurantsTabViewState extends State<_RestaurantsTabView> {
  String _searchQuery = '';
  String _sortBy = 'name'; // name, date

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
                  'Restaurant Management',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage all tenants, modules, and admins',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _seedDemoData(context),
                  icon: const Icon(Icons.rocket_launch, size: 18),
                  label: const Text('Seed Demo'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(140, 48),
                    backgroundColor: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showCreateDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Restaurant'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(180, 48),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Search & Sort Bar ─────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search restaurants...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              ),
            ),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: _sortBy,
              underline: const SizedBox(),
              icon: const Icon(Icons.sort),
              items: const [
                DropdownMenuItem(value: 'name', child: Text('Sort by Name')),
                DropdownMenuItem(value: 'date', child: Text('Sort by Date')),
              ],
              onChanged: (v) => setState(() => _sortBy = v!),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Content ────────────────────────────────────────────────────
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
                var tenants = state.tenants.toList();

                // Filter
                if (_searchQuery.isNotEmpty) {
                  tenants = tenants.where((t) => 
                    t.name.toLowerCase().contains(_searchQuery) ||
                    (t.address?.toLowerCase().contains(_searchQuery) ?? false) ||
                    (t.contact?.toLowerCase().contains(_searchQuery) ?? false)
                  ).toList();
                }

                // Sort
                if (_sortBy == 'name') {
                  tenants.sort((a, b) => a.name.compareTo(b.name));
                } else {
                  tenants.sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
                }

                if (tenants.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.storefront_outlined, size: 64, color: theme.hintColor.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? 'No restaurants yet' : 'No results found',
                          style: TextStyle(color: theme.hintColor, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: tenants.length,
                  itemBuilder: (context, index) => _RestaurantCard(
                    tenant: tenants[index],
                    onEdit: () => _showEditDialog(context, tenants[index]),
                    onDelete: () => _confirmDelete(context, tenants[index]),
                    onManage: () {
                      context.read<AuthBloc>().add(
                        SwitchRestaurantContext(
                          restaurantId: tenants[index].id,
                          restaurantName: tenants[index].name,
                        ),
                      );
                      Navigator.of(context).pushReplacementNamed(Routes.restaurantAdmin);
                    },
                  ),
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
    final addressCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final adminEmailCtrl = TextEditingController();
    final adminPassCtrl = TextEditingController();
    final adminNameCtrl = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('New Restaurant'),
        content: SizedBox(
          width: 500,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Restaurant Details', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Restaurant Name *', prefixIcon: Icon(Icons.restaurant)),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on)),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: contactCtrl,
                    decoration: const InputDecoration(labelText: 'Contact Number', prefixIcon: Icon(Icons.phone)),
                  ),
                  const SizedBox(height: 24),
                  Text('Admin Account', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 4),
                  Text('An admin user will be auto-created for this restaurant', style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: adminNameCtrl,
                    decoration: const InputDecoration(labelText: 'Admin Name *', prefixIcon: Icon(Icons.person)),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: adminEmailCtrl,
                    decoration: const InputDecoration(labelText: 'Admin Email *', prefixIcon: Icon(Icons.email)),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => !v!.contains('@') ? 'Enter a valid email' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: adminPassCtrl,
                    decoration: const InputDecoration(labelText: 'Admin Password (min 6) *', prefixIcon: Icon(Icons.lock)),
                    obscureText: true,
                    validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
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
                parentContext.read<TenantBloc>().add(
                  CreateTenant(
                    name: nameCtrl.text,
                    address: addressCtrl.text.isNotEmpty ? addressCtrl.text : null,
                    contact: contactCtrl.text.isNotEmpty ? contactCtrl.text : null,
                    adminEmail: adminEmailCtrl.text,
                    adminPassword: adminPassCtrl.text,
                    adminName: adminNameCtrl.text,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create Restaurant'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext parentContext, RestaurantModel tenant) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: tenant.name);
    final addressCtrl = TextEditingController(text: tenant.address ?? '');
    final contactCtrl = TextEditingController(text: tenant.contact ?? '');

    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('Edit Restaurant'),
        content: SizedBox(
          width: 450,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Restaurant Name *', prefixIcon: Icon(Icons.restaurant)),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: contactCtrl,
                  decoration: const InputDecoration(labelText: 'Contact Number', prefixIcon: Icon(Icons.phone)),
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
                parentContext.read<TenantBloc>().add(
                  UpdateTenant(tenant.id, {
                    'name': nameCtrl.text,
                    'address': addressCtrl.text,
                    'contact': contactCtrl.text,
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

  void _confirmDelete(BuildContext parentContext, RestaurantModel tenant) {
    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: Row(children: [
          Icon(Icons.warning_rounded, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8),
          const Text('Delete Restaurant'),
        ]),
        content: Text('Are you sure you want to permanently delete "${tenant.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              parentContext.read<TenantBloc>().add(DeleteTenant(tenant.id));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
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
      final String demoRid = 'demo-restaurant-123';

      await firestore.collection('restaurants').doc(demoRid).set({
        'name': 'Zyfloatix Luxury Dining',
        'address': '123 Elite Street, Tech City',
        'contact': '+1 234 567 890',
        'enabled_modules': {
          'pos': true, 'inventory': true, 'salary': true, 'reports': true,
        },
        'settings': {'currency': 'USD', 'tax_rate': 0.16},
        'created_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      await firestore.collection('restaurants').doc('resto-2').set({
        'name': 'Bella Cucina',
        'address': '456 Gourmet Lane, Food Town',
        'contact': '+1 555 123 456',
        'enabled_modules': {
          'pos': true, 'inventory': true, 'salary': false, 'reports': true,
        },
        'settings': {'currency': 'USD', 'tax_rate': 0.10},
        'created_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      await firestore.collection('restaurants').doc('resto-3').set({
        'name': 'Sakura Sushi Bar',
        'address': '789 Ocean Drive, Seaside',
        'contact': '+1 555 987 654',
        'enabled_modules': {
          'pos': true, 'inventory': false, 'salary': true, 'reports': false,
        },
        'settings': {'currency': 'USD', 'tax_rate': 0.08},
        'created_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo data generated! Refreshing...'), backgroundColor: Colors.green),
        );
        context.read<TenantBloc>().add(LoadTenants());
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: theme.colorScheme.error),
        );
      }
    }
  }
}

// ── Restaurant Card Widget ──────────────────────────────────────────────────

class _RestaurantCard extends StatelessWidget {
  final RestaurantModel tenant;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onManage;

  const _RestaurantCard({
    required this.tenant,
    required this.onEdit,
    required this.onDelete,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final enabledCount = tenant.enabledModules.values.where((v) => v == true).length;
    final totalModules = tenant.enabledModules.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.2),
                    theme.colorScheme.secondary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.restaurant, color: theme.colorScheme.primary, size: 32),
            ),
            const SizedBox(width: 24),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          tenant.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.white,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            tooltip: 'Edit',
                            onPressed: onEdit,
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.error),
                            tooltip: 'Delete',
                            onPressed: onDelete,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (tenant.address != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: theme.hintColor),
                          const SizedBox(width: 4),
                          Text(tenant.address!, style: TextStyle(color: theme.hintColor)),
                        ],
                      ),
                    ),
                  if (tenant.contact != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.phone_outlined, size: 14, color: theme.hintColor),
                          const SizedBox(width: 4),
                          Text(tenant.contact!, style: TextStyle(color: theme.hintColor)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Module badges
                  Row(
                    children: [
                      Text('Modules ($enabledCount/$totalModules)', style: theme.textTheme.labelMedium),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            _FeatureChip(
                              label: 'POS',
                              isEnabled: tenant.enabledModules['pos'] ?? false,
                              onToggle: (val) => context.read<TenantBloc>().add(ToggleModule(tenant.id, 'pos', val)),
                            ),
                            _FeatureChip(
                              label: 'Inventory',
                              isEnabled: tenant.enabledModules['inventory'] ?? false,
                              onToggle: (val) => context.read<TenantBloc>().add(ToggleModule(tenant.id, 'inventory', val)),
                            ),
                            _FeatureChip(
                              label: 'Salary',
                              isEnabled: tenant.enabledModules['salary'] ?? false,
                              onToggle: (val) => context.read<TenantBloc>().add(ToggleModule(tenant.id, 'salary', val)),
                            ),
                            _FeatureChip(
                              label: 'Reports',
                              isEnabled: tenant.enabledModules['reports'] ?? false,
                              onToggle: (val) => context.read<TenantBloc>().add(ToggleModule(tenant.id, 'reports', val)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onManage,
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Manage Restaurant'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onSelected: onToggle,
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isEnabled ? theme.colorScheme.primary : theme.hintColor.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
