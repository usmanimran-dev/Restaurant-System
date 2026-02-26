import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:restaurant/config/router.dart';
import 'package:restaurant/domain/blocs/auth/auth_bloc.dart';
import 'package:restaurant/domain/blocs/auth/auth_event.dart';

import 'package:restaurant/presentation/screens/restaurant_admin_staff_tab.dart';
import 'package:restaurant/presentation/screens/restaurant_admin_roles_tab.dart';
import 'package:restaurant/presentation/screens/restaurant_admin_menu_tab.dart';
import 'package:restaurant/presentation/screens/restaurant_admin_payroll_tab.dart';
import 'package:restaurant/presentation/screens/restaurant_admin_inventory_tab.dart';
import 'package:restaurant/presentation/screens/restaurant_admin_reports_tab.dart';
import 'package:restaurant/presentation/screens/restaurant_admin_orders_tab.dart';

/// Restaurant Admin dashboard – manages a single tenant's operations.
class RestaurantAdminDashboard extends StatefulWidget {
  const RestaurantAdminDashboard({super.key});

  @override
  State<RestaurantAdminDashboard> createState() =>
      _RestaurantAdminDashboardState();
}

class _RestaurantAdminDashboardState extends State<RestaurantAdminDashboard> {
  int _selectedIndex = 0;

  static const _navItems = <_NavItem>[
    _NavItem(icon: Icons.restaurant_menu_rounded, label: 'Menu'),
    _NavItem(icon: Icons.group_rounded, label: 'Staff'),
    _NavItem(icon: Icons.receipt_long_rounded, label: 'Orders'),
    _NavItem(icon: Icons.inventory_2_rounded, label: 'Inventory'),
    _NavItem(icon: Icons.request_quote_rounded, label: 'Payroll'),
    _NavItem(icon: Icons.analytics_rounded, label: 'Reports'),
    _NavItem(icon: Icons.security_rounded, label: 'Roles'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 768;

    return Scaffold(
      body: Row(
        children: [
          // ── Side navigation ────────────────────────────────────────────
          NavigationRail(
            extended: isWide,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF03DAC6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.storefront_rounded,
                        color: Colors.white, size: 22),
                  ),
                  if (isWide) ...[
                    const SizedBox(height: 8),
                    Text('Restaurant',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.hintColor)),
                  ],
                ],
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: IconButton(
                    tooltip: 'Sign out',
                    icon: const Icon(Icons.logout_rounded),
                    onPressed: () {
                      context.read<AuthBloc>().add(const LogoutRequested());
                      Navigator.of(context)
                          .pushReplacementNamed(Routes.login);
                    },
                  ),
                ),
              ),
            ),
            destinations: _navItems
                .map((item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      label: Text(item.label),
                    ))
                .toList(),
          ),

          const VerticalDivider(width: 1),

          // ── Content area ──────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: _buildContentArea(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea(ThemeData theme) {
    final label = _navItems[_selectedIndex].label;
    
    if (label == 'Menu') {
      return const MenuTab();
    } else if (label == 'Staff') {
      return const StaffTab();
    } else if (label == 'Orders') {
      return const OrdersTab();
    } else if (label == 'Inventory') {
      return const InventoryTab();
    } else if (label == 'Payroll') {
      return const PayrollTab();
    } else if (label == 'Reports') {
      return const ReportsTab();
    } else if (label == 'Roles') {
      return const RolesTab();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your ${label.toLowerCase()}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.hintColor,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _navItems[_selectedIndex].icon,
                  size: 64,
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Analytics & Reports coming soon',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
