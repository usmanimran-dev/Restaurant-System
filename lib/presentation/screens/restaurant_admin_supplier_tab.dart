import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/data/models/supplier_model.dart';
import 'package:restaurant/domain/blocs/supplier/supplier_bloc.dart';

/// Supplier & Purchase Order management tab.
class SupplierTab extends StatelessWidget {
  const SupplierTab({super.key, required this.restaurantId});
  final String restaurantId;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(tabs: const [
            Tab(text: 'Suppliers'),
            Tab(text: 'Purchase Orders'),
          ]),
          Expanded(
            child: TabBarView(children: [
              _SuppliersSubTab(restaurantId: restaurantId),
              _PurchaseOrdersSubTab(restaurantId: restaurantId),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SuppliersSubTab extends StatelessWidget {
  const _SuppliersSubTab({required this.restaurantId});
  final String restaurantId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<SupplierBloc, SupplierState>(
      builder: (context, state) {
        final suppliers = state is SuppliersLoaded ? state.suppliers : <SupplierModel>[];
        if (suppliers.isEmpty) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.business, size: 48, color: theme.hintColor),
            const SizedBox(height: 12),
            Text('No suppliers added', style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor)),
            const SizedBox(height: 12),
            ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Add Supplier'), onPressed: () {}),
          ]));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: suppliers.length,
          itemBuilder: (context, i) {
            final s = suppliers[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Text(s.name[0], style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
                title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${s.phone} ${s.email != null ? "• ${s.email}" : ""}'),
                  Row(children: [
                    Text('Quality: '), _Stars(s.qualityRating),
                    const SizedBox(width: 12),
                    Text(' Reliability: '), _Stars(s.reliabilityRating),
                  ]),
                ]),
                trailing: Chip(
                  label: Text(s.isActive ? 'Active' : 'Inactive', style: TextStyle(color: s.isActive ? Colors.green : Colors.grey, fontSize: 11)),
                  backgroundColor: (s.isActive ? Colors.green : Colors.grey).withValues(alpha: 0.1),
                  side: BorderSide.none,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars(this.rating);
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) => Icon(
        i < rating.round() ? Icons.star : Icons.star_border,
        size: 14, color: Colors.amber,
      )),
    );
  }
}

class _PurchaseOrdersSubTab extends StatelessWidget {
  const _PurchaseOrdersSubTab({required this.restaurantId});
  final String restaurantId;

  Color _statusColor(PurchaseOrderStatus status) {
    switch (status) {
      case PurchaseOrderStatus.draft: return Colors.grey;
      case PurchaseOrderStatus.pending: return Colors.blue;
      case PurchaseOrderStatus.confirmed: return Colors.indigo;
      case PurchaseOrderStatus.partiallyReceived: return Colors.orange;
      case PurchaseOrderStatus.received: return Colors.green;
      case PurchaseOrderStatus.invoiced: return Colors.purple;
      case PurchaseOrderStatus.paid: return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<SupplierBloc, SupplierState>(
      builder: (context, state) {
        final orders = state is SuppliersLoaded ? state.purchaseOrders : <PurchaseOrderModel>[];
        if (orders.isEmpty) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.receipt_long, size: 48, color: theme.hintColor),
            const SizedBox(height: 12),
            Text('No purchase orders', style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor)),
            const SizedBox(height: 12),
            ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Create PO'), onPressed: () {}),
          ]));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, i) {
            final po = orders[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _statusColor(po.status).withValues(alpha: 0.15),
                  child: Icon(Icons.receipt, color: _statusColor(po.status)),
                ),
                title: Text('PO #${po.id.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${po.supplierName} • ${po.items.length} items • Rs.${po.totalAmount.toStringAsFixed(0)}'),
                trailing: Chip(
                  label: Text(po.status.name, style: TextStyle(color: _statusColor(po.status), fontSize: 11)),
                  backgroundColor: _statusColor(po.status).withValues(alpha: 0.1),
                  side: BorderSide.none,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
