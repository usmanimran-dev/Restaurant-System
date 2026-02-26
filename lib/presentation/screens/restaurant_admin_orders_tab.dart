import 'package:flutter/material.dart';
import 'package:restaurant/presentation/screens/pos_screen.dart';
import 'package:restaurant/presentation/screens/order_history_subtab.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Management',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create new orders and view order history',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.1)),
                ),
                child: TabBar(
                  isScrollable: true,
                  indicatorSize: TabBarIndicatorSize.tab,
                  padding: const EdgeInsets.all(4),
                  indicator: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  tabs: const [
                    Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Point of Sale (New Order)'))),
                    Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Order History'))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Expanded(
            child: TabBarView(
              children: [
                PosScreen(),
                OrderHistorySubtab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
