import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:restaurant/core/di/injection_container.dart';
import 'package:restaurant/data/models/order_model.dart';
import 'package:restaurant/domain/blocs/auth/auth_bloc.dart';
import 'package:restaurant/domain/blocs/auth/auth_state.dart';
import 'package:restaurant/domain/blocs/order/order_bloc.dart';
import 'package:restaurant/domain/blocs/order/order_event.dart';
import 'package:restaurant/domain/blocs/order/order_state.dart';
import 'package:restaurant/presentation/widgets/loading_widget.dart';

class OrderHistorySubtab extends StatelessWidget {
  const OrderHistorySubtab({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return const SizedBox();

    return BlocProvider(
      create: (_) => sl<OrderBloc>()..add(LoadOrders(authState.user.restaurantId!)),
      child: _OrderHistoryView(restaurantId: authState.user.restaurantId!),
    );
  }
}

class _OrderHistoryView extends StatefulWidget {
  final String restaurantId;
  const _OrderHistoryView({required this.restaurantId});

  @override
  State<_OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<_OrderHistoryView> {
  String _searchQuery = '';
  String _filterStatus = 'All'; // All, completed, pending, cancelled
  String _filterType = 'All'; // All, dine-in, takeaway, delivery
  String _filterPayment = 'All'; // All, cash, card
  bool? _filterFbr; // null = all, true = yes, false = no

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // ── Filters & Search ──────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.hintColor.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by Order ID...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _filterType,
                      decoration: const InputDecoration(labelText: 'Order Type', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All Types')),
                        DropdownMenuItem(value: 'dine-in', child: Text('Dine-In')),
                        DropdownMenuItem(value: 'takeaway', child: Text('Takeaway')),
                        DropdownMenuItem(value: 'delivery', child: Text('Delivery')),
                      ],
                      onChanged: (v) => setState(() => _filterType = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _filterPayment,
                      decoration: const InputDecoration(labelText: 'Payment Method', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All Methods')),
                        DropdownMenuItem(value: 'cash', child: Text('Cash')),
                        DropdownMenuItem(value: 'card', child: Text('Card')),
                      ],
                      onChanged: (v) => setState(() => _filterPayment = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _filterStatus,
                      decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All Statuses')),
                        DropdownMenuItem(value: 'completed', child: Text('Completed')),
                        DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                      ],
                      onChanged: (v) => setState(() => _filterStatus = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<bool?>(
                      value: _filterFbr,
                      decoration: const InputDecoration(labelText: 'FBR Invoice', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('All')),
                        DropdownMenuItem(value: true, child: Text('Yes (FBR Invoiced)')),
                        DropdownMenuItem(value: false, child: Text('No (Standard)')),
                      ],
                      onChanged: (v) => setState(() => _filterFbr = v),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Data Table ───────────────────────────────────────────────────────
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.hintColor.withValues(alpha: 0.1)),
            ),
            child: BlocBuilder<OrderBloc, OrderState>(
              builder: (context, state) {
                if (state is OrderLoading) return const LoadingWidget();
                if (state is OrderLoaded) {
                  var orders = state.recentOrders.toList();

                  // Apply filters
                  if (_searchQuery.isNotEmpty) {
                    orders = orders.where((o) => o.id.toLowerCase().contains(_searchQuery)).toList();
                  }
                  if (_filterStatus != 'All') {
                    orders = orders.where((o) => o.status == _filterStatus).toList();
                  }
                  if (_filterType != 'All') {
                    orders = orders.where((o) => o.type == _filterType).toList();
                  }
                  if (_filterPayment != 'All') {
                    orders = orders.where((o) => o.paymentMethod == _filterPayment).toList();
                  }
                  if (_filterFbr != null) {
                    orders = orders.where((o) => (o.fbrInvoiceNumber != null) == _filterFbr).toList();
                  }

                  // Sort by latest
                  orders.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));

                  if (orders.isEmpty) {
                    return Center(
                      child: Text('No orders found matching the filters.', style: TextStyle(color: theme.hintColor)),
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.resolveWith((states) => theme.colorScheme.primary.withValues(alpha: 0.1)),
                        columns: const [
                          DataColumn(label: Text('Order ID')),
                          DataColumn(label: Text('Date & Time')),
                          DataColumn(label: Text('Type')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Payment')),
                          DataColumn(label: Text('Items')),
                          DataColumn(label: Text('Amount')),
                          DataColumn(label: Text('FBR Invoice')),
                        ],
                        rows: orders.map((o) {
                          return DataRow(
                            cells: [
                              DataCell(Text(o.id.substring(0, 8), style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(o.createdAt != null ? DateFormat('MMM dd, hh:mm a').format(o.createdAt!) : 'N/A')),
                              DataCell(_buildBadge(o.type, color: Colors.blue)),
                              DataCell(_buildBadge(o.status, color: o.status == 'completed' ? Colors.green : (o.status == 'cancelled' ? Colors.red : Colors.orange))),
                              DataCell(Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(o.paymentMethod == 'cash' ? Icons.money : Icons.credit_card, size: 16),
                                  const SizedBox(width: 4),
                                  Text(o.paymentMethod.toUpperCase()),
                                ],
                              )),
                              DataCell(Text('${o.items.length}')),
                              DataCell(Text('\$${o.total.toStringAsFixed(2)}', style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold))),
                              DataCell(
                                o.fbrInvoiceNumber != null
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                          const SizedBox(width: 4),
                                          Text(o.fbrInvoiceNumber!, style: const TextStyle(fontSize: 12)),
                                        ],
                                      )
                                    : const Text('-', style: TextStyle(color: Colors.grey)),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }
                return const Center(child: Text('No order history loaded.'));
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String label, {required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
