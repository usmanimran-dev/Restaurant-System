import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/domain/blocs/auth/auth_bloc.dart';
import 'package:restaurant/domain/blocs/auth/auth_state.dart';
import 'package:restaurant/domain/blocs/audit/audit_log_bloc.dart';
import 'package:restaurant/domain/blocs/audit/audit_log_event.dart';
import 'package:restaurant/domain/blocs/audit/audit_log_state.dart';
import 'package:intl/intl.dart';
import 'package:restaurant/core/di/injection_container.dart';
import 'package:restaurant/presentation/widgets/loading_widget.dart';

class AuditLogsTab extends StatelessWidget {
  const AuditLogsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return const SizedBox.shrink();

    return BlocProvider(
      create: (_) => sl<AuditLogBloc>()..add(LoadAuditLogs(authState.user.restaurantId!)),
      child: const _AuditLogsView(),
    );
  }
}

class _AuditLogsView extends StatelessWidget {
  const _AuditLogsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audit Logs',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              'Monitor all critical actions and changes in your restaurant',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: BlocBuilder<AuditLogBloc, AuditLogState>(
            builder: (context, state) {
              if (state is AuditLogLoading) return const LoadingWidget();
              if (state is AuditLogError) return Center(child: Text(state.message));
              
              if (state is AuditLogsLoaded) {
                if (state.logs.isEmpty) {
                  return const Center(child: Text('No audit logs found.'));
                }
                
                return ListView.builder(
                  itemCount: state.logs.length,
                  itemBuilder: (context, index) {
                    final log = state.logs[index];
                    final date = log.timestamp != null 
                        ? DateFormat('MMM dd, yyyy - HH:mm:ss').format(log.timestamp!)
                        : 'Unknown Date';
                        
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 1,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getColorForAction(log.action).withValues(alpha: 0.2),
                          child: Icon(_getIconForAction(log.action), color: _getColorForAction(log.action)),
                        ),
                        title: Text('${log.userName} ${log.action} ${log.entity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (log.details != null && log.details!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(log.details!),
                              ),
                            const SizedBox(height: 4),
                            Text(date, style: TextStyle(fontSize: 12, color: theme.hintColor)),
                          ],
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

  Color _getColorForAction(String action) {
    switch (action.toLowerCase()) {
      case 'create': return Colors.green;
      case 'update': return Colors.blue;
      case 'delete': return Colors.red;
      case 'login': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getIconForAction(String action) {
    switch (action.toLowerCase()) {
      case 'create': return Icons.add_circle;
      case 'update': return Icons.edit;
      case 'delete': return Icons.delete;
      case 'login': return Icons.login;
      default: return Icons.info;
    }
  }
}
