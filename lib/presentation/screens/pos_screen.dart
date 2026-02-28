import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/core/di/injection_container.dart';
import 'package:restaurant/domain/blocs/auth/auth_bloc.dart';
import 'package:restaurant/domain/blocs/auth/auth_state.dart';
import 'package:restaurant/domain/blocs/menu/menu_bloc.dart';
import 'package:restaurant/domain/blocs/menu/menu_event.dart';
import 'package:restaurant/domain/blocs/menu/menu_state.dart';
import 'package:restaurant/domain/blocs/order/order_bloc.dart';
import 'package:restaurant/domain/blocs/order/order_event.dart';
import 'package:restaurant/domain/blocs/order/order_state.dart';
import 'package:restaurant/data/models/order_model.dart';
import 'package:restaurant/presentation/widgets/loading_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return const Scaffold(body: Center(child: Text('Unauthorized')));

    return MultiBlocProvider(
      providers: [
        BlocProvider<MenuBloc>(
          create: (_) => sl<MenuBloc>()..add(LoadMenu(authState.user.restaurantId!)),
        ),
        BlocProvider<OrderBloc>(
          create: (_) => sl<OrderBloc>()..add(LoadOrders(authState.user.restaurantId!)),
        ),
      ],
      child: _PosView(restaurantId: authState.user.restaurantId!, employeeId: authState.user.id),
    );
  }
}

class _PosView extends StatefulWidget {
  final String restaurantId;
  final String employeeId;
  const _PosView({required this.restaurantId, required this.employeeId});

  @override
  State<_PosView> createState() => _PosViewState();
}

class _PosViewState extends State<_PosView> {
  String _orderType = 'dine-in';
  String _paymentMethod = 'cash';
  bool _applyFbr = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Point of Sale'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Row(
        children: [
          // ── LEFT: Menu Grid ──────────────────────────────────────────────
          Expanded(
            flex: 2,
            child: BlocBuilder<MenuBloc, MenuState>(
              builder: (context, state) {
                if (state is MenuLoading) return const LoadingWidget();
                if (state is MenuLoaded) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 250,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return InkWell(
                        onTap: () {
                          final orderItem = OrderItemModel(
                            menuItemId: item.id,
                            name: item.name,
                            quantity: 1,
                            unitPrice: item.price,
                          );
                          context.read<OrderBloc>().add(AddItemToCart(orderItem));
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Card(
                          elevation: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.fastfood, size: 48, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                              const SizedBox(height: 16),
                              Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              const SizedBox(height: 8),
                              Text('\$${item.price.toStringAsFixed(2)}', style: TextStyle(color: theme.colorScheme.secondary)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text('No menu items available.'));
              },
            ),
          ),
          
          // ── RIGHT: Cart & Checkout ────────────────────────────────────────
          Container(
            width: 400,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(left: BorderSide(color: theme.hintColor.withValues(alpha: 0.1))),
            ),
            child: Column(
              children: [
                Expanded(
                  child: BlocConsumer<OrderBloc, OrderState>(
                    listener: (context, state) {
                      if (state is OrderSubmissionSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Order submitted successfully!'), backgroundColor: Colors.green),
                        );
                        _generateAndPrintInvoice(state.order);
                      }
                      if (state is OrderError) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: theme.colorScheme.error));
                      }
                    },
                    builder: (context, state) {
                      if (state is OrderLoaded) {
                        if (state.currentCart.isEmpty) return const Center(child: Text('Cart is empty'));

                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.currentCart.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = state.currentCart[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Qty: ${item.quantity} x \$${item.unitPrice}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('\$${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                    onPressed: () => context.read<OrderBloc>().add(RemoveItemFromCart(item.menuItemId)),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                      return const Center(child: Text('Loading cart...'));
                    },
                  ),
                ),
                // ── Checkout Panel ───────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5))],
                  ),
                  child: BlocBuilder<OrderBloc, OrderState>(
                    builder: (context, state) {
                      double subtotal = 0, tax = 0, total = 0;
                      if (state is OrderLoaded) {
                        subtotal = state.cartSubtotal;
                        tax = state.cartTax;
                        total = state.cartTotal;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Type:'),
                              DropdownButton<String>(
                                value: _orderType,
                                items: const [
                                  DropdownMenuItem(value: 'dine-in', child: Text('Dine-In')),
                                  DropdownMenuItem(value: 'takeaway', child: Text('Takeaway')),
                                  DropdownMenuItem(value: 'delivery', child: Text('Delivery')),
                                ],
                                onChanged: (v) => setState(() => _orderType = v!),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Payment:'),
                              DropdownButton<String>(
                                value: _paymentMethod,
                                items: const [
                                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                                  DropdownMenuItem(value: 'card', child: Text('Card')),
                                  DropdownMenuItem(value: 'jazzcash', child: Text('JazzCash')),
                                  DropdownMenuItem(value: 'easypaisa', child: Text('Easypaisa')),
                                  DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
                                ],
                                onChanged: (v) => setState(() => _paymentMethod = v!),
                              )
                            ],
                          ),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Apply GST Tax (17%)'),
                            value: _applyFbr,
                            onChanged: (v) {
                              setState(() => _applyFbr = v ?? false);
                              context.read<OrderBloc>().add(SetTaxRate(_applyFbr ? 0.17 : 0));
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          const Divider(height: 32),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal'), Text('\$${subtotal.toStringAsFixed(2)}')]),
                          const SizedBox(height: 8),
                          if (state is OrderLoaded && state.cartDiscount > 0) ...[
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('Discount${state.discountName != null ? " (${state.discountName})" : ""}'),
                              Text('-\$${state.cartDiscount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green)),
                            ]),
                            const SizedBox(height: 8),
                          ],
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Tax'), Text('\$${tax.toStringAsFixed(2)}')]),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.secondary)),
                              Text('\$${total.toStringAsFixed(2)}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.secondary)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: (state is OrderLoaded && state.currentCart.isNotEmpty)
                                ? () {
                                    context.read<OrderBloc>().add(SubmitOrder(
                                      restaurantId: widget.restaurantId,
                                      employeeId: widget.employeeId,
                                      type: _orderType,
                                      paymentMethod: _paymentMethod,
                                    ));
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Submit Order & Print', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          )
                        ],
                      );
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _generateAndPrintInvoice(OrderModel order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text('Restaurant SaaS Platform', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 10),
              pw.Center(child: pw.Text('Order ID: ${order.id.substring(0, 8)}')),
              pw.Center(child: pw.Text('Date: ${order.createdAt.toString().split('.')[0]}')),
              if (order.fbrInvoiceNumber != null) ...[
                pw.SizedBox(height: 8),
                pw.Center(child: pw.Text('FBR Invoice: ${order.fbrInvoiceNumber}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              ],
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              ...order.items.map((item) {
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(child: pw.Text('${item.quantity}x ${item.name}')),
                    pw.Text('\$${(item.unitPrice * item.quantity).toStringAsFixed(2)}'),
                  ],
                );
              }),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Subtotal:'), pw.Text('\$${order.subtotal.toStringAsFixed(2)}')]),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Tax:'), pw.Text('\$${order.taxAmount.toStringAsFixed(2)}')]),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('GRAND TOTAL:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('\$${order.total.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Center(child: pw.Text('Thank you! Please come again.')),
              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
