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
                    icon: const Icon(Icons.category, size: 18),
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
                    icon: const Icon(Icons.add_circle_outline, size: 18),
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
                if (state.categories.isEmpty) return const Center(child: Text('No menu categories found. Create a category to start.'));

                // Group by category for display
                final itemsByCategory = <String, List<MenuItemModel>>{};
                for (var cat in state.categories) {
                  itemsByCategory[cat.id] = state.items.where((i) => i.categoryId == cat.id).toList();
                }

                return ListView.builder(
                  itemCount: state.categories.length,
                  itemBuilder: (context, index) {
                    final cat = state.categories[index];
                    final catItems = itemsByCategory[cat.id] ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                cat.name.toUpperCase(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Row(
                                children: [
                                  PermissionGuard(
                                    permissionKey: 'menu.edit',
                                    fallback: const SizedBox(),
                                    child: IconButton(
                                      icon: Icon(Icons.edit, size: 18, color: theme.hintColor),
                                      onPressed: () => _showEditCategoryDialog(context, cat),
                                    ),
                                  ),
                                  PermissionGuard(
                                    permissionKey: 'menu.delete',
                                    fallback: const SizedBox(),
                                    child: IconButton(
                                      icon: Icon(Icons.delete, size: 18, color: theme.colorScheme.error),
                                      onPressed: () => _confirmDeleteCategory(context, cat),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (catItems.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Text('No items in this category.', style: TextStyle(color: theme.hintColor, fontStyle: FontStyle.italic)),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 350,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 2.2, // adjusted for layout
                              ),
                              itemCount: catItems.length,
                              itemBuilder: (ctx, i) {
                                final item = catItems[i];
                                return Card(
                                  elevation: 2,
                                  shadowColor: Colors.black.withValues(alpha: 0.2),
                                  child: Row(
                                    children: [
                                      // Image placeholder or actual image
                                      Container(
                                        width: 100,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                                          image: item.imageUrl != null && item.imageUrl!.isNotEmpty
                                              ? DecorationImage(image: NetworkImage(item.imageUrl!), fit: BoxFit.cover)
                                              : null,
                                        ),
                                        child: (item.imageUrl == null || item.imageUrl!.isEmpty)
                                            ? Icon(Icons.fastfood, size: 40, color: theme.colorScheme.primary.withValues(alpha: 0.5))
                                            : null,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      item.name,
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  PopupMenuButton<String>(
                                                    icon: Icon(Icons.more_vert, size: 18, color: theme.hintColor),
                                                    padding: EdgeInsets.zero,
                                                    itemBuilder: (context) => [
                                                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                                    ],
                                                    onSelected: (value) {
                                                      if (value == 'edit') {
                                                        _showEditItemDialog(context, item, state.categories);
                                                      } else if (value == 'delete') {
                                                        _confirmDeleteItem(context, item);
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '\$${item.price.toStringAsFixed(2)}',
                                                style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 16),
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
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
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

  // ── Categories ────────────────────────────────────────────────────────────

  void _showAddCategoryDialog(BuildContext parentContext) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();

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
                  CreateCategory(MenuCategoryModel(id: '', restaurantId: restaurantId, name: nameCtrl.text)),
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

  void _showEditCategoryDialog(BuildContext parentContext, MenuCategoryModel cat) {
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
                parentContext.read<MenuBloc>().add(
                  UpdateCategory(cat.id, restaurantId, {'name': nameCtrl.text}),
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

  void _confirmDeleteCategory(BuildContext parentContext, MenuCategoryModel cat) {
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
              parentContext.read<MenuBloc>().add(DeleteCategory(cat.id, restaurantId));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── Items ─────────────────────────────────────────────────────────────────

  void _showAddItemDialog(BuildContext parentContext) {
    final state = parentContext.read<MenuBloc>().state;
    if (state is! MenuLoaded || state.categories.isEmpty) {
      ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('Please create a category first.')));
      return;
    }
    _showItemForm(parentContext, null, state.categories);
  }

  void _showEditItemDialog(BuildContext parentContext, MenuItemModel item, List<MenuCategoryModel> categories) {
    _showItemForm(parentContext, item, categories);
  }

  void _showItemForm(BuildContext parentContext, MenuItemModel? item, List<MenuCategoryModel> categories) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final priceCtrl = TextEditingController(text: item?.price.toString() ?? '');
    final descCtrl = TextEditingController(text: item?.description ?? '');
    final imageCtrl = TextEditingController(text: item?.imageUrl ?? '');
    String? selectedCategoryId = item?.categoryId ?? categories.first.id;

    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Add Menu Item' : 'Edit Menu Item'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category)),
                    items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (val) => selectedCategoryId = val,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Item Name', prefixIcon: Icon(Icons.fastfood)),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(labelText: 'Price', prefixIcon: Icon(Icons.attach_money)),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Description (optional)', prefixIcon: Icon(Icons.description)),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: imageCtrl,
                    decoration: const InputDecoration(labelText: 'Image URL (optional)', prefixIcon: Icon(Icons.image)),
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
                if (item == null) {
                  parentContext.read<MenuBloc>().add(
                    CreateMenuItem(
                      MenuItemModel(
                        id: '',
                        restaurantId: restaurantId,
                        categoryId: selectedCategoryId!,
                        name: nameCtrl.text,
                        price: double.tryParse(priceCtrl.text) ?? 0.0,
                        description: descCtrl.text,
                        imageUrl: imageCtrl.text,
                      ),
                    ),
                  );
                } else {
                  parentContext.read<MenuBloc>().add(
                    UpdateMenuItem(item.id, restaurantId, {
                      'category_id': selectedCategoryId,
                      'name': nameCtrl.text,
                      'price': double.tryParse(priceCtrl.text) ?? 0.0,
                      'description': descCtrl.text,
                      'image_url': imageCtrl.text,
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

  void _confirmDeleteItem(BuildContext parentContext, MenuItemModel item) {
    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: Row(children: [
          Icon(Icons.warning_rounded, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8),
          const Text('Delete Menu Item'),
        ]),
        content: Text('Are you sure you want to delete "${item.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              parentContext.read<MenuBloc>().add(DeleteMenuItem(item.id, restaurantId));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
