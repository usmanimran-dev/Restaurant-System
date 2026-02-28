import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/data/models/payroll_customer_model.dart';
import 'package:restaurant/domain/blocs/customer/customer_bloc.dart';

/// Customer CRM & Loyalty tab.
class CustomerTab extends StatelessWidget {
  const CustomerTab({super.key, required this.restaurantId});
  final String restaurantId;

  Color _tierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'gold': return const Color(0xFFD4AF37);
      case 'silver': return Colors.blueGrey;
      case 'bronze': return const Color(0xFFCD7F32);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        final customers = state is CustomersLoaded ? state.customers : <CustomerModel>[];
        
        return Column(
          children: [
            // Stats bar
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _StatCard(title: 'Total', value: '${customers.length}', icon: Icons.people, color: Colors.blue),
                  const SizedBox(width: 12),
                  _StatCard(
                    title: 'Gold', 
                    value: '${customers.where((c) => c.loyaltyTier == "gold").length}', 
                    icon: Icons.star, 
                    color: const Color(0xFFD4AF37),
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    title: 'Avg Spent', 
                    value: customers.isEmpty ? 'Rs.0' : 'Rs.${(customers.fold<double>(0, (s, c) => s + c.totalSpent) / customers.length).toStringAsFixed(0)}',
                    icon: Icons.attach_money, 
                    color: Colors.green,
                  ),
                ],
              ),
            ),

            // Customer list
            Expanded(
              child: customers.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.people_outline, size: 48, color: theme.hintColor),
                      const SizedBox(height: 12),
                      Text('No customers yet', style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor)),
                      const SizedBox(height: 8),
                      Text('Customers will appear as orders are placed', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: customers.length,
                      itemBuilder: (context, i) {
                        final c = customers[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _tierColor(c.loyaltyTier).withValues(alpha: 0.15),
                              child: Text(c.name.isNotEmpty ? c.name[0] : '?', 
                                style: TextStyle(color: _tierColor(c.loyaltyTier), fontWeight: FontWeight.bold)),
                            ),
                            title: Row(children: [
                              Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: _tierColor(c.loyaltyTier).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(c.loyaltyTier.toUpperCase(), 
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _tierColor(c.loyaltyTier))),
                              ),
                            ]),
                            subtitle: Text(
                              '${c.phone} • ${c.totalOrders} orders • Rs.${c.totalSpent.toStringAsFixed(0)} spent • ${c.loyaltyPoints} pts',
                            ),
                            trailing: const Icon(Icons.chevron_right),
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
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}
