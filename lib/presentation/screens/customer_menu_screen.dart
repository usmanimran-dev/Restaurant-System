import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/core/di/injection_container.dart';
import 'package:restaurant/data/models/cart_model.dart';
import 'package:restaurant/data/models/menu_model.dart';
import 'package:restaurant/domain/blocs/cart/cart_bloc.dart';
import 'package:restaurant/domain/blocs/cart/cart_event.dart';
import 'package:restaurant/domain/blocs/cart/cart_state.dart';
import 'package:restaurant/domain/blocs/menu/menu_bloc.dart';
import 'package:restaurant/domain/blocs/menu/menu_event.dart';
import 'package:restaurant/domain/blocs/menu/menu_state.dart';
import 'package:uuid/uuid.dart';
import 'package:badges/badges.dart' as badges;

/// Customer-facing menu screen. Accessed via public URL.
class CustomerMenuScreen extends StatelessWidget {
  const CustomerMenuScreen({super.key, required this.restaurantId, this.tableNumber});
  
  final String restaurantId;
  final String? tableNumber;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<MenuBloc>()..add(LoadMenu(restaurantId))),
        BlocProvider(create: (_) => sl<CartBloc>()..add(InitCart(restaurantId, tableNumber: tableNumber))),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const _CustomerMenuLayout(),
      ),
    );
  }
}

class _CustomerMenuLayout extends StatelessWidget {
  const _CustomerMenuLayout();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Responsive split: Categories left, Items center, Cart right (if wide enough)
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 1000;
        final isMedium = constraints.maxWidth > 600;

        return Stack(
          children: [
            Row(
              children: [
                // Main Menu Area
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        color: theme.cardColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  child: Icon(Icons.restaurant, color: theme.colorScheme.primary),
                                ),
                                const SizedBox(width: 12),
                                Text('Menu', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            if (!isWide && !isMedium) // Mobile cart icon
                              _MobileCartButton(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Content
                      Expanded(
                        child: BlocBuilder<MenuBloc, MenuState>(
                          builder: (context, state) {
                            if (state is MenuLoading) return const Center(child: CircularProgressIndicator());
                            if (state is MenuError) return Center(child: Text(state.message));
                            if (state is MenuLoaded) {
                              return _MenuList(categories: state.categories, items: state.items);
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Sidebar Cart (for web)
                if (isWide || isMedium)
                  Container(
                    width: isWide ? 400 : 320,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      border: Border(left: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(-2, 0))
                      ],
                    ),
                    child: const _CartSidebar(),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _MobileCartButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is CartActive && state.cart.items.isNotEmpty) {
          return badges.Badge(
            badgeContent: Text('${state.cart.items.length}', style: const TextStyle(color: Colors.white, fontSize: 10)),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => BlocProvider.value(
                    value: context.read<CartBloc>(),
                    child: const FractionallySizedBox(heightFactor: 0.9, child: _CartSidebar()),
                  ),
                );
              },
            ),
          );
        }
        return IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your cart is empty')));
          },
        );
      },
    );
  }
}

class _MenuList extends StatelessWidget {
  const _MenuList({required this.categories, required this.items});
  final List<MenuCategoryModel> categories;
  final List<MenuItemModel> items;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty && items.isEmpty) {
      return Center(child: Text('Empty menu', style: TextStyle(color: Theme.of(context).hintColor)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: categories.length,
      itemBuilder: (context, i) {
        final cat = categories[i];
        final catItems = items.where((item) => item.categoryId == cat.id).toList();

        if (catItems.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(cat.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                childAspectRatio: 2.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: catItems.length,
              itemBuilder: (context, j) => _MenuItemCard(item: catItems[j]),
            ),
          ],
        );
      },
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({required this.item});
  final MenuItemModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uuid = const Uuid();

    return InkWell(
      onTap: () {
        if (!item.isAvailable) return;
        // Simple direct add for MVP (modifiers would require a modal here)
        context.read<CartBloc>().add(AddToCart(CartItemModel(
          id: uuid.v4(),
          menuItem: item,
          quantity: 1,
        )));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} added to cart'), duration: const Duration(seconds: 1)));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 4),
                  if (item.description != null)
                    Text(item.description!, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  Text('Rs.${item.price.toStringAsFixed(0)}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (item.imageUrl != null) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(item.imageUrl!, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey))),
              ),
            ] else ...[
              const SizedBox(width: 12),
              Container(width: 80, height: 80, decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.image, color: theme.hintColor)),
            ],
            if (!item.isAvailable)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: const Text('Sold Out', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}

class _CartSidebar extends StatefulWidget {
  const _CartSidebar();
  @override
  State<_CartSidebar> createState() => _CartSidebarState();
}

class _CartSidebarState extends State<_CartSidebar> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _paymentMethod = 'cash';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is! CartActive) return const Center(child: CircularProgressIndicator());
        
        // Handle success notification
        if (state.submittedOrderId != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
                  const SizedBox(height: 24),
                  Text('Order Placed!', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Your order has been sent to the kitchen.', textAlign: TextAlign.center, style: TextStyle(color: theme.hintColor)),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => context.read<CartBloc>().add(ClearCart()),
                    child: const Text('New Order'),
                  )
                ],
              ),
            ),
          );
        }

        final cart = state.cart;

        if (cart.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_basket_outlined, size: 64, color: theme.hintColor.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text('Your cart is empty', style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor)),
              ],
            ),
          );
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)))),
              child: Row(
                children: [
                  const Icon(Icons.shopping_cart),
                  const SizedBox(width: 12),
                  Text('Your Order', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cart.items.length,
                separatorBuilder: (_, __) => const Divider(height: 32),
                itemBuilder: (context, i) {
                  final ci = cart.items[i];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Qty controls
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () => context.read<CartBloc>().add(UpdateCartItem(ci.id, ci.quantity + 1)),
                              child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.add, size: 16)),
                            ),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text('${ci.quantity}', style: const TextStyle(fontWeight: FontWeight.bold))),
                            InkWell(
                              onTap: () {
                                if (ci.quantity > 1) {
                                  context.read<CartBloc>().add(UpdateCartItem(ci.id, ci.quantity - 1));
                                } else {
                                  context.read<CartBloc>().add(RemoveFromCart(ci.id));
                                }
                              },
                              child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.remove, size: 16)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ci.menuItem.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            if (ci.selectedModifiers.isNotEmpty)
                              ...ci.selectedModifiers.map((m) => Text('+ ${m.name}', style: const TextStyle(fontSize: 12, color: Colors.grey))),
                            const SizedBox(height: 4),
                            Text('Rs.${ci.totalPrice.toStringAsFixed(0)}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                        onPressed: () => context.read<CartBloc>().add(RemoveFromCart(ci.id)),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Checkout Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Subtotal', style: TextStyle(color: theme.hintColor)),
                    Text('Rs.${cart.subtotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Est. Tax (16%)', style: TextStyle(color: theme.hintColor)),
                    Text('Rs.${cart.estimatedTax.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ]),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('Rs.${cart.total.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: theme.colorScheme.primary)),
                  ]),
                  const SizedBox(height: 24),
                  
                  // Checkout Details
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name', isDense: true),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number', isDense: true),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _paymentMethod,
                    decoration: const InputDecoration(labelText: 'Payment Method', isDense: true),
                    items: const [
                      DropdownMenuItem(value: 'cash', child: Text('Cash (Pay at counter)')),
                      DropdownMenuItem(value: 'card', child: Text('Card (Online)')),
                    ],
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                  const SizedBox(height: 24),

                  if (state.submissionError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(state.submissionError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state.isSubmitting ? null : () {
                        if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter name and phone')));
                          return;
                        }
                        context.read<CartBloc>().add(SubmitOrder(
                          customerName: _nameController.text,
                          customerPhone: _phoneController.text,
                          paymentMethod: _paymentMethod,
                        ));
                      },
                      child: state.isSubmitting 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Place Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
