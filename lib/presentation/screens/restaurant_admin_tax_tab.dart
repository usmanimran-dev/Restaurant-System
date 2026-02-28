import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/data/models/tax_model.dart';
import 'package:restaurant/domain/blocs/auth/auth_bloc.dart';
import 'package:restaurant/domain/blocs/auth/auth_state.dart';
import 'package:restaurant/domain/blocs/tax/tax_bloc.dart';
import 'package:restaurant/domain/blocs/tax/tax_event.dart';
import 'package:restaurant/domain/blocs/tax/tax_state.dart';
import 'package:restaurant/core/di/injection_container.dart';
import 'package:restaurant/presentation/widgets/loading_widget.dart';

class TaxTab extends StatelessWidget {
  const TaxTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return const SizedBox.shrink();

    return BlocProvider(
      create: (_) => sl<TaxBloc>()..add(LoadTaxConfig(authState.user.restaurantId!)),
      child: const _TaxView(),
    );
  }
}

class _TaxView extends StatelessWidget {
  const _TaxView();

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
                  'Tax & FBR Configuration',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Manage tax rates and POS machine integration',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showConfigDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Configuration'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: BlocBuilder<TaxBloc, TaxState>(
            builder: (context, state) {
              if (state is TaxLoading) return const LoadingWidget();
              if (state is TaxError) return Center(child: Text(state.message));
              
              if (state is TaxConfigLoaded) {
                if (state.configs.isEmpty) {
                  return const Center(child: Text('No tax configurations found.'));
                }
                
                return ListView.builder(
                  itemCount: state.configs.length,
                  itemBuilder: (context, index) {
                    final config = state.configs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(config.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rate: ${config.rate}%'),
                            if (config.fbrPosId != null && config.fbrPosId!.isNotEmpty) 
                              Text('FBR POS ID: ${config.fbrPosId}'),
                            if (config.ntn != null && config.ntn!.isNotEmpty) 
                              Text('NTN: ${config.ntn}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (config.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('Default', style: TextStyle(color: theme.colorScheme.primary, fontSize: 12)),
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showConfigDialog(context, config: config),
                            ),
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

  void _showConfigDialog(BuildContext context, {TaxConfigurationModel? config}) {
    final nameCtrl = TextEditingController(text: config?.name);
    final rateCtrl = TextEditingController(text: config?.rate.toString());
    final ntnCtrl = TextEditingController(text: config?.ntn);
    final posIdCtrl = TextEditingController(text: config?.fbrPosId);
    bool isDefault = config?.isDefault ?? true;

    final parentContext = context;
    final authState = parentContext.read<AuthBloc>().state as Authenticated;

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(config == null ? 'Add Tax Configuration' : 'Edit Configuration'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Name (e.g. GST)'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: rateCtrl,
                      decoration: const InputDecoration(labelText: 'Rate (%)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: ntnCtrl,
                      decoration: const InputDecoration(labelText: 'NTN (Optional)'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: posIdCtrl,
                      decoration: const InputDecoration(labelText: 'FBR POS ID (Optional)'),
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Default Configuration'),
                      value: isDefault,
                      onChanged: (v) => setState(() => isDefault = v ?? false),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final rateValue = double.tryParse(rateCtrl.text.trim()) ?? 0.0;
                    
                    if (config == null) {
                      final newConfig = TaxConfigurationModel(
                        id: '',
                        restaurantId: authState.user.restaurantId!,
                        name: nameCtrl.text.trim(),
                        rate: rateValue,
                        ntn: ntnCtrl.text.trim(),
                        fbrPosId: posIdCtrl.text.trim(),
                        isDefault: isDefault,
                      );
                      parentContext.read<TaxBloc>().add(CreateTaxConfig(newConfig));
                    } else {
                      parentContext.read<TaxBloc>().add(UpdateTaxConfig(
                        config.id,
                        {
                          'name': nameCtrl.text.trim(),
                          'rate': rateValue,
                          'ntn': ntnCtrl.text.trim(),
                          'fbr_pos_id': posIdCtrl.text.trim(),
                          'is_default': isDefault,
                        },
                        authState.user.restaurantId!,
                      ));
                    }
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
