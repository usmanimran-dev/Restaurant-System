import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/data/models/kds_model.dart';
import 'package:restaurant/domain/blocs/auth/auth_bloc.dart';
import 'package:restaurant/domain/blocs/auth/auth_state.dart';
import 'package:restaurant/domain/blocs/kds/kds_bloc.dart';
import 'package:restaurant/domain/blocs/kds/kds_event.dart';
import 'package:restaurant/domain/blocs/kds/kds_state.dart';
import 'package:restaurant/core/di/injection_container.dart';

/// Kitchen Display System — real-time order queue for kitchen staff.
class KdsScreen extends StatelessWidget {
  const KdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return const SizedBox.shrink();

    return BlocProvider(
      create: (_) => sl<KdsBloc>()..add(StreamKdsOrders(authState.user.restaurantId!)),
      child: const _KdsView(),
    );
  }
}

class _KdsView extends StatefulWidget {
  const _KdsView();
  @override
  State<_KdsView> createState() => _KdsViewState();
}

class _KdsViewState extends State<_KdsView> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Refresh elapsed time every 30 seconds
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.kitchen, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            const Text('Kitchen Display System'),
          ],
        ),
        actions: [
          // Live indicator
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, color: Colors.green, size: 10),
                SizedBox(width: 6),
                Text('LIVE', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      body: BlocBuilder<KdsBloc, KdsState>(
        builder: (context, state) {
          if (state is KdsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is KdsError) {
            return Center(child: Text(state.message));
          }
          if (state is KdsOrdersLoaded) {
            if (state.orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.restaurant, size: 64, color: theme.hintColor),
                    const SizedBox(height: 16),
                    Text('No active orders', style: theme.textTheme.titleLarge?.copyWith(color: theme.hintColor)),
                    const SizedBox(height: 8),
                    Text('Orders will appear here in real-time', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 1200 ? 4 : constraints.maxWidth > 800 ? 3 : 2;
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: state.orders.length,
                    itemBuilder: (context, index) => _KdsOrderCard(order: state.orders[index]),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Individual order card in the KDS grid.
class _KdsOrderCard extends StatelessWidget {
  const _KdsOrderCard({required this.order});
  final KdsOrderModel order;

  Color _typeColor() {
    switch (order.orderType.toLowerCase()) {
      case 'dine-in': return const Color(0xFF0066FF);
      case 'takeaway': return const Color(0xFF00D084);
      case 'delivery': return const Color(0xFFDC2626);
      default: return Colors.grey;
    }
  }

  Color _priorityColor() {
    switch (order.priority) {
      case OrderPriority.rush: return const Color(0xFFDC2626);
      case OrderPriority.delayed: return const Color(0xFFFF6B35);
      case OrderPriority.normal: return Colors.transparent;
    }
  }

  String _elapsed() {
    final mins = order.elapsed.inMinutes;
    if (mins < 1) return 'Just now';
    if (mins < 60) return '${mins}m ago';
    return '${mins ~/ 60}h ${mins % 60}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = _typeColor();
    final isRush = order.priority == OrderPriority.rush;
    final isHeld = order.isOnHold;

    return Container(
      decoration: BoxDecoration(
        color: isHeld ? Colors.orange.withValues(alpha: 0.05) : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRush ? _priorityColor() : typeColor.withValues(alpha: 0.3),
          width: isRush ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#${order.orderNumber}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text(order.orderType.toUpperCase(), style: TextStyle(color: typeColor, fontWeight: FontWeight.w700, fontSize: 11)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_elapsed(), style: TextStyle(
                      color: order.elapsed.inMinutes > order.estimatedPrepMinutes ? Colors.red : theme.hintColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    )),
                    if (order.customerName != null)
                      Text(order.customerName!, style: theme.textTheme.bodySmall),
                    if (isRush)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                        child: const Text('RUSH', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    if (isHeld)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                        child: const Text('ON HOLD', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: order.items.length,
              separatorBuilder: (_, __) => const Divider(height: 8),
              itemBuilder: (context, i) {
                final item = order.items[i];
                return _KdsItemRow(
                  item: item,
                  onStatusChanged: (status) {
                    context.read<KdsBloc>().add(UpdateItemStatus(
                      order.restaurantId,
                      order.orderId,
                      i,
                      status,
                    ));
                  },
                );
              },
            ),
          ),

          // Footer actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<KdsBloc>().add(ToggleOrderHold(order.restaurantId, order.orderId, !order.isOnHold));
                    },
                    icon: Icon(isHeld ? Icons.play_arrow : Icons.pause, size: 16),
                    label: Text(isHeld ? 'Resume' : 'Hold', style: const TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.symmetric(vertical: 8)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: order.isComplete
                        ? () => context.read<KdsBloc>().add(CompleteKdsOrder(order.restaurantId, order.orderId))
                        : null,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Done', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.symmetric(vertical: 8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual item row in a KDS order card.
class _KdsItemRow extends StatelessWidget {
  const _KdsItemRow({required this.item, required this.onStatusChanged});
  final KdsItemModel item;
  final ValueChanged<ItemPrepStatus> onStatusChanged;

  Color _statusColor() {
    switch (item.status) {
      case ItemPrepStatus.pending: return Colors.grey;
      case ItemPrepStatus.cooking: return Colors.orange;
      case ItemPrepStatus.ready: return Colors.green;
      case ItemPrepStatus.served: return Colors.blue;
    }
  }

  ItemPrepStatus get _nextStatus {
    switch (item.status) {
      case ItemPrepStatus.pending: return ItemPrepStatus.cooking;
      case ItemPrepStatus.cooking: return ItemPrepStatus.ready;
      case ItemPrepStatus.ready: return ItemPrepStatus.served;
      case ItemPrepStatus.served: return ItemPrepStatus.served;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    return InkWell(
      onTap: item.status != ItemPrepStatus.served ? () => onStatusChanged(_nextStatus) : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text('${item.quantity}x', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration: item.status == ItemPrepStatus.served ? TextDecoration.lineThrough : null,
                  )),
                  if (item.modifiers.isNotEmpty)
                    Text(item.modifiers.join(', '), style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  if (item.notes != null && item.notes!.isNotEmpty)
                    Text('⚠ ${item.notes}', style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
              child: Text(item.status.name.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
            ),
          ],
        ),
      ),
    );
  }
}
