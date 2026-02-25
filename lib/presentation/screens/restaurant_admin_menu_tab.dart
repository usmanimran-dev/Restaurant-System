import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/core/di/injection_container.dart';
import 'package:restaurant/data/models/menu_model.dart';
import 'package:restaurant/domain/blocs/auth/auth_bloc.dart';
import 'package:restaurant/domain/blocs/auth/auth_state.dart';
import 'package:restaurant/domain/blocs/menu/menu_bloc.dart';
import 'package:restaurant/domain/blocs/menu/menu_event.dart';
import 'package:restaurant/domain/blocs/menu/menu_state.dart';
import 'package:restaurant/presentation/widgets/loading_widget.dart';
import 'package:restaurant/presentation/widgets/permission_guard.dart';

class MenuTab extends StatelessWidget {
  const MenuTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return const SizedBox();

    return BlocProvider(
      create: (_) => sl<MenuBloc>()..add(LoadMenu(authState.user.restaurantId!)),
      child: _MenuTabView(restaurantId: authState.user.restaurantId!),
    );
  }
}

class _MenuTabView extends StatelessWidget {
  final String restaurantId;
  const _MenuTabView({required this.restaurantId});

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
                  'Menu Management',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage categories and items',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
          Row(
            children: [
              PermissionGuard(
                permissionKey: 'menu.create',
                fallback: const SizedBox(),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddCategoryDialog(context),
                  icon: const Icon(Icons.category),
                  label: const Text('New Category'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(160, 48), backgroundColor: theme.colorScheme.secondary),
                ),
              ),
              const SizedBox(width: 16),
              PermissionGuard(
                permissionKey: 'menu.create',
                fallback: const SizedBox(),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddItemDialog(context),
                  icon: const Icon(Icons.add_circle_outline),
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
          child: BlocConsumer<MenuBloc, MenuState>(
            listener: (context, state) {
              if (state is MenuError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: theme.colorScheme.error));
              }
              if (state is MenuOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
              }
            },
            builder: (context, state) {
              if (state is MenuLoading) return const LoadingWidget();
              if (state is MenuLoaded) {
                if (state.items.isEmpty) return const Center(child: Text('No menu items found.'));

                // Group by category for display
                final itemsByCategory = <String, List>{};
                for (var cat in state.categories) {
                  itemsByCategory[cat.id] = state.items.where((i) => i.categoryId == cat.id).toList();
                }

                return ListView.builder(
                  itemCount: state.categories.length,
                  itemBuilder: (context, index) {
                    final cat = state.categories[index];
                    final catItems = itemsByCategory[cat.id] ?? [];
                    if (catItems.isEmpty) return const SizedBox();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            cat.name.toUpperCase(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 300,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 3 / 2,
                          ),
                          itemCount: catItems.length,
                          itemBuilder: (ctx, i) {
                            final item = catItems[i];
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        PermissionGuard(
                                          permissionKey: 'menu.edit',
                                          fallback: const SizedBox(),
                                          child: Icon(Icons.edit, size: 16, color: theme.hintColor),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '\$${item.price.toStringAsFixed(2)}',
                                      style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    if (item.description != null)
                                      Text(
                                        item.description!,
                                        style: TextStyle(color: theme.hintColor, fontSize: 12),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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

  void _showAddCategoryDialog(BuildContext parentContext) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final authState = parentContext.read<AuthBloc>().state as Authenticated;

    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('Add Menu Category'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Category Name (e.g., Beverages)'),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                parentContext.read<MenuBloc>().add(
                  CreateCategory(
                    MenuCategoryModel(
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
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String? selectedCategoryId;
    final authState = parentContext.read<AuthBloc>().state as Authenticated;

    final state = parentContext.read<MenuBloc>().state;
    if (state is! MenuLoaded || state.categories.isEmpty) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        const SnackBar(content: Text('Please create a category first before adding items.')),
      );
      return;
    }

    selectedCategoryId = state.categories.first.id;

    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('Add Menu Item'),
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
                controller: priceCtrl,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                parentContext.read<MenuBloc>().add(
                  CreateMenuItem(
                    MenuItemModel(
                      id: '',
                      restaurantId: authState.user.restaurantId!,
                      categoryId: selectedCategoryId!,
                      name: nameCtrl.text,
                      price: double.tryParse(priceCtrl.text) ?? 0.0,
                      description: descCtrl.text,
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
