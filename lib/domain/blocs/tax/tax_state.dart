import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/tax_model.dart';

abstract class TaxState extends Equatable {
  const TaxState();
  @override
  List<Object?> get props => [];
}

class TaxInitial extends TaxState {}
class TaxLoading extends TaxState {}

class TaxConfigLoaded extends TaxState {
  final List<TaxConfigurationModel> configs;
  final TaxConfigurationModel? defaultConfig;
  const TaxConfigLoaded(this.configs, this.defaultConfig);
  @override
  List<Object?> get props => [configs, defaultConfig];
}

class TaxCategoriesLoaded extends TaxState {
  final List<TaxCategoryModel> categories;
  const TaxCategoriesLoaded(this.categories);
  @override
  List<Object?> get props => [categories];
}

class FbrInvoicesLoaded extends TaxState {
  final List<FbrInvoiceModel> invoices;
  const FbrInvoicesLoaded(this.invoices);
  @override
  List<Object?> get props => [invoices];
}

class TaxError extends TaxState {
  final String message;
  const TaxError(this.message);
  @override
  List<Object?> get props => [message];
}
