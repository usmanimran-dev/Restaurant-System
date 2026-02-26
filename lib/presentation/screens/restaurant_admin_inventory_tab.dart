import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/core/di/injection_container.dart';
import 'package:restaurant/data/models/inventory_model.dart';
import 'package:restaurant/domain/blocs/auth/auth_bloc.dart';
import 'package:restaurant/domain/blocs/auth/auth_state.dart';
import 'package:restaurant/domain/blocs/inventory/inventory_bloc.dart';
import 'package:restaurant/domain/blocs/inventory/inventory_event.dart';
import 'package:restaurant/domain/blocs/inventory/inventory_state.dart';
import 'package:restaurant/presentation/widgets/loading_widget.dart';
import 'package:restaurant/presentation/widgets/permission_guard.dart';

class InventoryTab extends StatelessWidget {
  const InventoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated || authState.user.restaurantId == null) return const SizedBox();

    return BlocProvider(
      create: (_) => sl<InventoryBloc>()..add(LoadInventory(authState.user.restaurantId!)),
      child: _InventoryTabView(restaurantId: authState.user.restaurantId!),
    );
  }
}

class _InventoryTabView extends StatelessWidget {
  final String restaurantId;
  const _InventoryTabView({required this.restaurantId});

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
                  'Inventory Management',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage categories, items, and track stock levels',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
            Row(
              children: [
                PermissionGuard(
                  permissionKey: 'inventory.create',
                  fallback: const SizedBox(),
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddCategoryDialog(context),
                    icon: const Icon(Icons.category, size: 18),
                    label: const Text('New Category'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(160, 48), backgroundColor: theme.colorScheme.secondary),
                  ),
                ),
                const SizedBox(width: 16),
                PermissionGuard(
                  permissionKey: 'inventory.create',
                  fallback: const SizedBox(),
                  child: ElevatedButton.icon(
                    onPressed: () => _showItemDialog(context, null),
                    icon: const Icon(Icons.add_box, size: 18),
                    label: const Text('New Item'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(160, 48)),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: BlocConsumer<InventoryBloc, InventoryState>(
            listener: (context, state) {
              if (state is InventoryError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: theme.colorScheme.error));
              }
              if (state is InventoryOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
              }
            },
            builder: (context, state) {
              if (state is InventoryLoading) return const LoadingWidget();
              if (state is InventoryLoaded) {
                if (state.categories.isEmpty) return const Center(child: Text('No categories found. Please create one first.'));

                return ListView.builder(
                  itemCount: state.categories.length,
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    final catItems = state.items.where((i) => i.categoryId == category.id).toList();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 24),
                      elevation: 2,
                      shadowColor: Colors.black.withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  category.name.toUpperCase(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Row(
                                  children: [
                                    PermissionGuard(
                                      permissionKey: 'inventory.edit',
                                      fallback: const SizedBox(),
                                      child: IconButton(
                                        icon: Icon(Icons.edit, size: 18, color: theme.hintColor),
                                        onPressed: () => _showEditCategoryDialog(context, category),
                                      ),
                                    ),
                                    PermissionGuard(
                                      permissionKey: 'inventory.delete',
                                      fallback: const SizedBox(),
                                      child: IconButton(
                                        icon: Icon(Icons.delete, size: 18, color: theme.colorScheme.error),
                                        onPressed: () => _confirmDeleteCategory(context, category),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(),
                            if (catItems.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text('No items in this category.', style: TextStyle(color: theme.hintColor, fontStyle: FontStyle.italic)),
                              )
                            else
                              SizedBox(
                                width: double.infinity,
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.resolveWith((states) => theme.colorScheme.surface),
                                  columns: const [
                                    DataColumn(label: Text('Name')),
                                    DataColumn(label: Text('In Stock')),
                                    DataColumn(label: Text('Unit')),
                                    DataColumn(label: Text('Min Stock')),
                                    DataColumn(label: Text('Status')),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                  rows: catItems.map((item) {
                                    final isLow = item.quantity <= item.minimumStock;
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                        DataCell(Text(item.quantity.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold, color: isLow ? Colors.red : null))),
                                        DataCell(Text(item.unit, style: TextStyle(color: theme.hintColor))),
                                        DataCell(Text(item.minimumStock.toStringAsFixed(2))),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: (isLow ? Colors.red : Colors.green).withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: (isLow ? Colors.red : Colors.green).withValues(alpha: 0.3)),
                                            ),
                                            child: Text(
                                              isLow ? 'LOW STOCK' : 'OK',
                                              style: TextStyle(color: isLow ? Colors.red : Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              PermissionGuard(
                                                permissionKey: 'inventory.edit',
                                                fallback: const SizedBox(width: 32),
                                                child: IconButton(
                                                  icon: const Icon(Icons.add_shopping_cart, size: 18, color: Colors.blue),
                                                  tooltip: 'Record Purchase',
                                                  onPressed: () => _showRecordPurchaseDialog(context, item),
                                                ),
                                              ),
                                              PopupMenuButton<String>(
                                                icon: Icon(Icons.more_vert, size: 18, color: theme.hintColor),
                                                padding: EdgeInsets.zero,
                                                itemBuilder: (context) => [
                                                  const PopupMenuItem(value: 'edit', child: Text('Edit Item')),
                                                  const PopupMenuItem(value: 'delete', child: Text('Delete Item')),
                                                ],
                                                onSelected: (value) {
                                                  if (value == 'edit') {
                                                    _showItemDialog(context, item);
                                                  } else if (value == 'delete') {
                                                    _confirmDeleteItem(context, item);
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
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

  // ── Categories ────────────────────────────────────────────────────────────

  void _showAddCategoryDialog(BuildContext parentContext) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Category Name'),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                parentContext.read<InventoryBloc>().add(
                  CreateInventoryCategory(InventoryCategoryModel(id: '', restaurantId: restaurantId, name: nameCtrl.text)),
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

  void _showEditCategoryDialog(BuildContext parentContext, InventoryCategoryModel cat) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: cat.name);

    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Category Name'),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                parentContext.read<InventoryBloc>().add(
                  UpdateInventoryCategory(cat.id, restaurantId, {'name': nameCtrl.text}),
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

  void _confirmDeleteCategory(BuildContext parentContext, InventoryCategoryModel cat) {
    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: Row(children: [
          Icon(Icons.warning_rounded, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8),
          const Text('Delete Category'),
        ]),
        content: Text('Are you sure you want to delete "${cat.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              parentContext.read<InventoryBloc>().add(DeleteInventoryCategory(cat.id, restaurantId));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── Items ─────────────────────────────────────────────────────────────────

  void _showItemDialog(BuildContext parentContext, InventoryItemModel? item) {
    final state = parentContext.read<InventoryBloc>().state;
    if (state is! InventoryLoaded || state.categories.isEmpty) {
      ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('Please create a category first.')));
      return;
    }

    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final unitCtrl = TextEditingController(text: item?.unit ?? '');
    final minStockCtrl = TextEditingController(text: item?.minimumStock.toString() ?? '');
    String? selectedCategoryId = item?.categoryId ?? state.categories.first.id;

    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Add Inventory Item' : 'Edit Inventory Item'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category)),
                  items: state.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (val) => selectedCategoryId = val,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Item Name', prefixIcon: Icon(Icons.inventory_2)),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: unitCtrl,
                  decoration: const InputDecoration(labelText: 'Unit (e.g., kg, liters, pcs)', prefixIcon: Icon(Icons.scale)),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: minStockCtrl,
                  decoration: const InputDecoration(labelText: 'Minimum Stock Alert Level', prefixIcon: Icon(Icons.warning)),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                if (item == null) {
                  parentContext.read<InventoryBloc>().add(
                    CreateInventoryItem(
                      InventoryItemModel(
                        id: '',
                        restaurantId: restaurantId,
                        categoryId: selectedCategoryId!,
                        name: nameCtrl.text,
                        unit: unitCtrl.text,
                        quantity: 0.0,
                        minimumStock: double.tryParse(minStockCtrl.text) ?? 0.0,
                      ),
                    ),
                  );
                } else {
                  parentContext.read<InventoryBloc>().add(
                    UpdateInventoryItem(item.id, restaurantId, {
                      'category_id': selectedCategoryId,
                      'name': nameCtrl.text,
                      'unit': unitCtrl.text,
                      'minimum_stock': double.tryParse(minStockCtrl.text) ?? 0.0,
                    }),
                  );
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteItem(BuildContext parentContext, InventoryItemModel item) {
    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: Row(children: [
          Icon(Icons.warning_rounded, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8),
          const Text('Delete Inventory Item'),
        ]),
        content: Text('Are you sure you want to delete "${item.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              parentContext.read<InventoryBloc>().add(DeleteInventoryItem(item.id, restaurantId));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showRecordPurchaseDialog(BuildContext parentContext, InventoryItemModel item) {
    final formKey = GlobalKey<FormState>();
    final qtyCtrl = TextEditingController();
    final costCtrl = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: Text('Record Purchase: ${item.name}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: qtyCtrl,
                decoration: InputDecoration(labelText: 'Quantity Added (${item.unit})', prefixIcon: const Icon(Icons.add)),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: costCtrl,
                decoration: const InputDecoration(labelText: 'Total Cost', prefixIcon: Icon(Icons.attach_money)),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                parentContext.read<InventoryBloc>().add(
                  RecordPurchase(
                    PurchaseModel(
                      id: '',
                      restaurantId: restaurantId,
                      itemId: item.id,
                      quantityAdded: double.tryParse(qtyCtrl.text) ?? 0.0,
                      cost: double.tryParse(costCtrl.text) ?? 0.0,
                      date: DateTime.now(),
                    ),
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );
  }
}
