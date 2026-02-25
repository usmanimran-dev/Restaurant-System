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
    if (authState is! Authenticated || authState.user.restaurantId == null) {
      return const Center(child: Text('Invalid restaurant context'));
    }

    return BlocProvider(
      create: (_) => sl<InventoryBloc>()..add(LoadInventory(authState.user.restaurantId!)),
      child: const _InventoryTabView(),
    );
  }
}

class _InventoryTabView extends StatelessWidget {
  const _InventoryTabView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Inventory Management'),
        backgroundColor: Colors.transparent,
        actions: [
          PermissionGuard(
            permissionKey: 'inventory.create',
            child: ElevatedButton.icon(
              onPressed: () => _showAddCategoryDialog(context),
              icon: const Icon(Icons.category),
              label: const Text('New Category'),
            ),
          ),
          const SizedBox(width: 16),
          PermissionGuard(
            permissionKey: 'inventory.create',
            child: ElevatedButton.icon(
              onPressed: () => _showAddItemDialog(context),
              icon: const Icon(Icons.add_box),
              label: const Text('New Item'),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocConsumer<InventoryBloc, InventoryState>(
        listener: (context, state) {
          if (state is InventoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: theme.colorScheme.error),
            );
          }
          if (state is InventoryOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
          if (state is InventoryLoading) {
            return const LoadingWidget(message: 'Loading inventory...');
          }

          if (state is InventoryLoaded) {
            if (state.categories.isEmpty) {
              return const Center(child: Text('No categories found. Please create one first.'));
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  final catItems = state.items.where((i) => i.categoryId == category.id).toList();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Divider(),
                          if (catItems.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No items in this category.'),
                            )
                          else
                            DataTable(
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
                                    DataCell(Text(item.name)),
                                    DataCell(Text(item.quantity.toStringAsFixed(2))),
                                    DataCell(Text(item.unit)),
                                    DataCell(Text(item.minimumStock.toStringAsFixed(2))),
                                    DataCell(
                                      isLow
                                          ? const Chip(label: Text('Low Stock'), backgroundColor: Colors.red, labelStyle: TextStyle(color: Colors.white))
                                          : const Chip(label: Text('OK'), backgroundColor: Colors.green, labelStyle: TextStyle(color: Colors.white)),
                                    ),
                                    DataCell(
                                      PermissionGuard(
                                        permissionKey: 'inventory.edit',
                                        fallback: const Text('-'),
                                        child: TextButton.icon(
                                          onPressed: () => _showRecordPurchaseDialog(context, item),
                                          icon: const Icon(Icons.add_shopping_cart, size: 16),
                                          label: const Text('Add Stock'),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext parentContext) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final authState = parentContext.read<AuthBloc>().state as Authenticated;

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
                  CreateInventoryCategory(
                    InventoryCategoryModel(
                      id: '',
                      restaurantId: authState.user.restaurantId!,
                      name: nameCtrl.text,
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

  void _showAddItemDialog(BuildContext parentContext) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final unitCtrl = TextEditingController();
    final minStockCtrl = TextEditingController();
    String? selectedCategoryId;
    final authState = parentContext.read<AuthBloc>().state as Authenticated;
    
    final state = parentContext.read<InventoryBloc>().state;
    if (state is! InventoryLoaded || state.categories.isEmpty) {
      return;
    }
    
    selectedCategoryId = state.categories.first.id;

    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('Add Inventory Item'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: state.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (val) => selectedCategoryId = val,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: unitCtrl,
                decoration: const InputDecoration(labelText: 'Unit (e.g., kg, liters, pcs)'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: minStockCtrl,
                decoration: const InputDecoration(labelText: 'Minimum Stock Alert Level'),
                keyboardType: TextInputType.number,
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
                  CreateInventoryItem(
                    InventoryItemModel(
                      id: '',
                      restaurantId: authState.user.restaurantId!,
                      categoryId: selectedCategoryId!,
                      name: nameCtrl.text,
                      unit: unitCtrl.text,
                      quantity: 0.0,
                      minimumStock: double.tryParse(minStockCtrl.text) ?? 0.0,
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

  void _showRecordPurchaseDialog(BuildContext parentContext, InventoryItemModel item) {
    final formKey = GlobalKey<FormState>();
    final qtyCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final authState = parentContext.read<AuthBloc>().state as Authenticated;

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
                decoration: InputDecoration(labelText: 'Quantity Added (${item.unit})'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: costCtrl,
                decoration: const InputDecoration(labelText: 'Total Cost'),
                keyboardType: TextInputType.number,
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
                      restaurantId: authState.user.restaurantId!,
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
