import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/core/di/injection_container.dart';
import 'package:restaurant/data/models/salary_record_model.dart';
import 'package:restaurant/domain/blocs/auth/auth_bloc.dart';
import 'package:restaurant/domain/blocs/auth/auth_state.dart';
import 'package:restaurant/domain/blocs/salary/salary_bloc.dart';
import 'package:restaurant/domain/blocs/salary/salary_event.dart';
import 'package:restaurant/domain/blocs/salary/salary_state.dart';
import 'package:restaurant/presentation/widgets/loading_widget.dart';
import 'package:restaurant/presentation/widgets/permission_guard.dart';

class PayrollTab extends StatelessWidget {
  const PayrollTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return const SizedBox();

    return BlocProvider(
      create: (_) => sl<SalaryBloc>()..add(LoadSalaries(authState.user.restaurantId!)),
      child: _PayrollTabView(restaurantId: authState.user.restaurantId!),
    );
  }
}

class _PayrollTabView extends StatelessWidget {
  final String restaurantId;
  const _PayrollTabView({required this.restaurantId});

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
                  'Payroll Management',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Process salaries, bonuses, and deductions',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
            PermissionGuard(
              permissionKey: 'salary.create',
              fallback: const SizedBox(),
              child: ElevatedButton.icon(
                onPressed: () => _showProcessSalaryDialog(context),
                icon: const Icon(Icons.request_quote),
                label: const Text('Process Salary'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: BlocConsumer<SalaryBloc, SalaryState>(
            listener: (context, state) {
              if (state is SalaryError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: theme.colorScheme.error));
              }
              if (state is SalaryOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
              }
            },
            builder: (context, state) {
              if (state is SalaryLoading) return const LoadingWidget();
              if (state is SalaryLoaded) {
                if (state.records.isEmpty) return const Center(child: Text('No salary records found.'));
                return ListView.builder(
                  itemCount: state.records.length,
                  itemBuilder: (context, index) {
                    final record = state.records[index];
                    final isPaid = record.status == 'paid';
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPaid ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                          child: Icon(
                            isPaid ? Icons.check_circle : Icons.pending,
                            color: isPaid ? Colors.green : Colors.orange,
                          ),
                        ),
                        title: Text('Month: ${record.month}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        subtitle: Text('Base: \$${record.baseSalary} • Bonus: \$${record.bonus} • Ded: \$${record.loanDeduction + record.taxDeduction}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('\$${record.netSalary.toStringAsFixed(2)}', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.secondary)),
                                Text(record.status.toUpperCase(), style: TextStyle(fontSize: 10, color: isPaid ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            if (!isPaid) ...[
                              const SizedBox(width: 16),
                              PermissionGuard(
                                permissionKey: 'salary.edit',
                                fallback: const SizedBox(),
                                child: IconButton(
                                  icon: const Icon(Icons.payment, color: Colors.green),
                                  tooltip: 'Mark as Paid',
                                  onPressed: () {
                                    context.read<SalaryBloc>().add(MarkSalaryPaid(record.id, restaurantId));
                                  },
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  void _showProcessSalaryDialog(BuildContext parentContext) {
    final formKey = GlobalKey<FormState>();
    final empIdCtrl = TextEditingController();
    final monthCtrl = TextEditingController(text: 'February 2026');
    final baseCtrl = TextEditingController();
    final bonusCtrl = TextEditingController(text: '0');
    final deductCtrl = TextEditingController(text: '0');
    final authState = parentContext.read<AuthBloc>().state as Authenticated;

    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('Process Salary'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: empIdCtrl,
                  decoration: const InputDecoration(labelText: 'Employee ID / Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: monthCtrl,
                  decoration: const InputDecoration(labelText: 'Month (e.g., Feb 2026)'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: baseCtrl,
                  decoration: const InputDecoration(labelText: 'Base Salary'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: bonusCtrl,
                  decoration: const InputDecoration(labelText: 'Bonuses'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: deductCtrl,
                  decoration: const InputDecoration(labelText: 'Deductions (Tax/Loan)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final bSal = double.tryParse(baseCtrl.text) ?? 0.0;
                final bon = double.tryParse(bonusCtrl.text) ?? 0.0;
                final lDed = double.tryParse(deductCtrl.text) ?? 0.0;

                parentContext.read<SalaryBloc>().add(
                  ProcessSalary(
                    SalaryRecordModel(
                      id: '',
                      restaurantId: authState.user.restaurantId!,
                      employeeId: empIdCtrl.text,
                      month: monthCtrl.text,
                      baseSalary: bSal,
                      bonus: bon,
                      loanDeduction: lDed,
                      taxDeduction: 0.0,
                      netSalary: (bSal + bon) - lDed,
                      status: 'pending',
                    ),
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Process'),
          ),
        ],
      ),
    );
  }
}
