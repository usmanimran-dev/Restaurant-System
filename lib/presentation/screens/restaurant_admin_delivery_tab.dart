import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/data/models/delivery_model.dart';
import 'package:restaurant/domain/blocs/delivery/delivery_bloc.dart';
import 'package:restaurant/domain/blocs/delivery/delivery_event.dart';
import 'package:restaurant/domain/blocs/delivery/delivery_state.dart';

/// Delivery management tab for Restaurant Admin dashboard.
class DeliveryTab extends StatelessWidget {
  const DeliveryTab({super.key, required this.restaurantId});
  final String restaurantId;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(tabs: const [
            Tab(text: 'Deliveries'),
            Tab(text: 'Drivers'),
            Tab(text: 'Zones'),
          ]),
          Expanded(
            child: TabBarView(children: [
              _DeliveriesSubTab(restaurantId: restaurantId),
              _DriversSubTab(restaurantId: restaurantId),
              _ZonesSubTab(restaurantId: restaurantId),
            ]),
          ),
        ],
      ),
    );
  }
}

class _DeliveriesSubTab extends StatelessWidget {
  const _DeliveriesSubTab({required this.restaurantId});
  final String restaurantId;

  Color _statusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.ready: return Colors.blue;
      case DeliveryStatus.packed: return Colors.indigo;
      case DeliveryStatus.assigned: return Colors.purple;
      case DeliveryStatus.pickedUp: return Colors.orange;
      case DeliveryStatus.inTransit: return Colors.amber;
      case DeliveryStatus.delivered: return Colors.green;
      case DeliveryStatus.failed: return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<DeliveryBloc, DeliveryState>(
      builder: (context, state) {
        final deliveries = state is DeliveriesLoaded ? state.deliveries : <DeliveryModel>[];
        if (deliveries.isEmpty) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.delivery_dining, size: 48, color: theme.hintColor),
            const SizedBox(height: 12),
            Text('No active deliveries', style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor)),
          ]));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: deliveries.length,
          itemBuilder: (context, i) {
            final d = deliveries[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _statusColor(d.status).withValues(alpha: 0.15),
                  child: Icon(Icons.delivery_dining, color: _statusColor(d.status)),
                ),
                title: Text('Order: ${d.orderId.substring(0, 8)}...', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (d.customerName != null) Text(d.customerName!),
                  if (d.deliveryAddress != null) Text(d.deliveryAddress!, maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (d.driverName != null) Text('Driver: ${d.driverName}'),
                ]),
                trailing: Chip(
                  label: Text(d.status.name, style: TextStyle(color: _statusColor(d.status), fontSize: 11)),
                  backgroundColor: _statusColor(d.status).withValues(alpha: 0.1),
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

class _DriversSubTab extends StatelessWidget {
  const _DriversSubTab({required this.restaurantId});
  final String restaurantId;

  Color _driverStatusColor(DriverStatus status) {
    switch (status) {
      case DriverStatus.available: return Colors.green;
      case DriverStatus.onDelivery: return Colors.orange;
      case DriverStatus.offline: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<DeliveryBloc, DeliveryState>(
      builder: (context, state) {
        final drivers = state is DeliveriesLoaded ? state.drivers : <DriverModel>[];
        if (drivers.isEmpty) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.person_pin, size: 48, color: theme.hintColor),
            const SizedBox(height: 12),
            Text('No drivers added', style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor)),
            const SizedBox(height: 12),
            ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Add Driver'), onPressed: () {}),
          ]));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: drivers.length,
          itemBuilder: (context, i) {
            final d = drivers[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _driverStatusColor(d.status).withValues(alpha: 0.15),
                  child: Text(d.name[0], style: TextStyle(color: _driverStatusColor(d.status), fontWeight: FontWeight.bold)),
                ),
                title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${d.phone} • ${d.totalDeliveries} deliveries • ⭐ ${d.rating.toStringAsFixed(1)}'),
                trailing: Chip(
                  label: Text(d.status.name, style: TextStyle(color: _driverStatusColor(d.status), fontSize: 11)),
                  backgroundColor: _driverStatusColor(d.status).withValues(alpha: 0.1),
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

class _ZonesSubTab extends StatelessWidget {
  const _ZonesSubTab({required this.restaurantId});
  final String restaurantId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<DeliveryBloc, DeliveryState>(
      builder: (context, state) {
        final zones = state is DeliveriesLoaded ? state.zones : <DeliveryZoneModel>[];
        if (zones.isEmpty) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.map, size: 48, color: theme.hintColor),
            const SizedBox(height: 12),
            Text('No delivery zones', style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor)),
            const SizedBox(height: 12),
            ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Add Zone'), onPressed: () {}),
          ]));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: zones.length,
          itemBuilder: (context, i) {
            final z = zones[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(Icons.location_on, color: theme.colorScheme.primary),
                ),
                title: Text(z.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Fee: Rs.${z.deliveryFee.toStringAsFixed(0)} • ~${z.estimatedMinutes} min'),
                trailing: Switch(value: z.isActive, onChanged: (v) {}),
              ),
            );
          },
        );
      },
    );
  }
}
