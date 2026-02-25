import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/core/di/injection_container.dart';
import 'package:restaurant/domain/blocs/auth/auth_bloc.dart';
import 'package:restaurant/domain/blocs/auth/auth_state.dart';
import 'package:restaurant/domain/blocs/reports/reports_bloc.dart';
import 'package:restaurant/domain/blocs/reports/reports_event.dart';
import 'package:restaurant/domain/blocs/reports/reports_state.dart';
import 'package:restaurant/presentation/widgets/loading_widget.dart';
import 'package:restaurant/presentation/widgets/permission_guard.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated || authState.user.restaurantId == null) {
      return const Center(child: Text('Invalid restaurant context'));
    }

    return BlocProvider(
      create: (_) => sl<ReportsBloc>()..add(LoadReportSummary(restaurantId: authState.user.restaurantId!)),
      child: const _ReportsTabView(),
    );
  }
}

class _ReportsTabView extends StatefulWidget {
  const _ReportsTabView();

  @override
  State<_ReportsTabView> createState() => _ReportsTabViewState();
}

class _ReportsTabViewState extends State<_ReportsTabView> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Financial Reports & Analytics'),
        backgroundColor: Colors.transparent,
        actions: [
          PermissionGuard(
            permissionKey: 'reports.view',
            child: ElevatedButton.icon(
              onPressed: () => _pickDateRange(context),
              icon: const Icon(Icons.date_range),
              label: Text(_startDate == null ? 'Filter Dates' : 'Filtered'),
            ),
          ),
          if (_startDate != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                setState(() {
                  _startDate = null;
                  _endDate = null;
                });
                final authState = context.read<AuthBloc>().state as Authenticated;
                context.read<ReportsBloc>().add(LoadReportSummary(restaurantId: authState.user.restaurantId!));
              },
              icon: const Icon(Icons.clear),
              tooltip: 'Clear Filter',
            ),
          ],
          const SizedBox(width: 16),
        ],
      ),
      body: BlocConsumer<ReportsBloc, ReportsState>(
        listener: (context, state) {
          if (state is ReportsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: theme.colorScheme.error),
            );
          }
        },
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const LoadingWidget(message: 'Generating analytical report...');
          }

          if (state is ReportSummaryLoaded) {
            final summary = state.summary;
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overview Dashboard', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard(context, 'Total Revenue (Gross)', '\$${summary.totalRevenue.toStringAsFixed(2)}', Icons.monetization_on, Colors.green)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildMetricCard(context, 'Total Expenses (Salaries + Stock)', '\$${(summary.totalSalaries + summary.totalPurchases).toStringAsFixed(2)}', Icons.money_off, Colors.redAccent)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildMetricCard(context, 'Total Tax (Collected)', '\$${summary.totalTaxes.toStringAsFixed(2)}', Icons.account_balance, Colors.orangeAccent)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildMetricCard(context, 'Net Profit/Loss', '\$${summary.profitAndLoss.toStringAsFixed(2)}', Icons.trending_up, summary.profitAndLoss >= 0 ? Colors.green : Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard(context, 'Total Orders', summary.orderCount.toString(), Icons.receipt, Colors.purpleAccent)),
                    ],
                  )
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange(BuildContext parentContext) async {
    final picked = await showDateRangePicker(
      context: parentContext,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      if (!mounted) return;
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      final authState = parentContext.read<AuthBloc>().state as Authenticated;
      parentContext.read<ReportsBloc>().add(
        LoadReportSummary(
          restaurantId: authState.user.restaurantId!,
          startDate: _startDate,
          endDate: _endDate,
        ),
      );
    }
  }
}
