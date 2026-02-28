import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/data/models/discount_model.dart';
import 'package:restaurant/domain/blocs/auth/auth_bloc.dart';
import 'package:restaurant/domain/blocs/auth/auth_state.dart';
import 'package:restaurant/domain/blocs/discount/discount_bloc.dart';
import 'package:restaurant/domain/blocs/discount/discount_event.dart';
import 'package:restaurant/domain/blocs/discount/discount_state.dart';
import 'package:restaurant/core/di/injection_container.dart';
import 'package:restaurant/presentation/widgets/loading_widget.dart';

class DiscountsTab extends StatelessWidget {
  const DiscountsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return const SizedBox.shrink();

    return BlocProvider(
      create: (_) => sl<DiscountBloc>()..add(LoadDiscounts(authState.user.restaurantId!)),
      child: const _DiscountsView(),
    );
  }
}

class _DiscountsView extends StatelessWidget {
  const _DiscountsView();

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
                  'Discount Management',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Create and manage promotional coupons and discounts',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showDiscountDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Discount'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: BlocBuilder<DiscountBloc, DiscountState>(
            builder: (context, state) {
              if (state is DiscountLoading) return const LoadingWidget();
              if (state is DiscountError) return Center(child: Text(state.message));
              
              if (state is DiscountsLoaded) {
                if (state.discounts.isEmpty) {
                  return const Center(child: Text('No discounts found.'));
                }
                
                return ListView.builder(
                  itemCount: state.discounts.length,
                  itemBuilder: (context, index) {
                    final discount = state.discounts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(discount.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Code: ${discount.code ?? "None"}'),
                            Text('Value: ${discount.type == DiscountType.percentage ? "${discount.value}%" : "\$${discount.value}"}'),
                            Text('Usage: ${discount.usageCount} ${discount.usageLimit != null ? "/ ${discount.usageLimit}" : ""}'),
                          ],
                        ),
                        trailing: Switch(
                          value: discount.isActive,
                          onChanged: (v) {
                            final authState = context.read<AuthBloc>().state as Authenticated;
                            context.read<DiscountBloc>().add(UpdateDiscount(
                              discount.id,
                              {'is_active': v},
                              authState.user.restaurantId!
                            ));
                          },
                        ),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  void _showDiscountDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    DiscountType selectedType = DiscountType.percentage;

    final parentContext = context;
    final authState = parentContext.read<AuthBloc>().state as Authenticated;

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Discount/Coupon'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Campaign Name'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: codeCtrl,
                      decoration: const InputDecoration(labelText: 'Coupon Code (e.g. SUMMER20)'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<DiscountType>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: const [
                        DropdownMenuItem(value: DiscountType.percentage, child: Text('Percentage (%)')),
                        DropdownMenuItem(value: DiscountType.fixedAmount, child: Text('Fixed Amount (\$)' )),
                      ],
                      onChanged: (v) => setState(() => selectedType = v!),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: valueCtrl,
                      decoration: const InputDecoration(labelText: 'Value'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final valueAmount = double.tryParse(valueCtrl.text.trim()) ?? 0.0;
                    
                    final newDiscount = DiscountModel(
                      id: '',
                      restaurantId: authState.user.restaurantId!,
                      name: nameCtrl.text.trim(),
                      type: selectedType,
                      value: valueAmount,
                      code: codeCtrl.text.trim().toUpperCase(),
                    );
                    parentContext.read<DiscountBloc>().add(CreateDiscount(newDiscount));
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
