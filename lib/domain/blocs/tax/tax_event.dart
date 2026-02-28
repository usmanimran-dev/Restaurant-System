import 'package:equatable/equatable.dart';
import 'package:restaurant/data/models/tax_model.dart';

abstract class TaxEvent extends Equatable {
  const TaxEvent();
  @override
  List<Object?> get props => [];
}

class LoadTaxConfig extends TaxEvent {
  final String restaurantId;
  const LoadTaxConfig(this.restaurantId);
  @override
  List<Object?> get props => [restaurantId];
}

class CreateTaxConfig extends TaxEvent {
  final TaxConfigurationModel config;
  const CreateTaxConfig(this.config);
  @override
  List<Object?> get props => [config];
}

class UpdateTaxConfig extends TaxEvent {
  final String id;
  final Map<String, dynamic> updates;
  final String restaurantId;
  const UpdateTaxConfig(this.id, this.updates, this.restaurantId);
  @override
  List<Object?> get props => [id, updates, restaurantId];
}

class LoadTaxCategories extends TaxEvent {
  final String restaurantId;
  const LoadTaxCategories(this.restaurantId);
  @override
  List<Object?> get props => [restaurantId];
}

class CreateTaxCategory extends TaxEvent {
  final TaxCategoryModel category;
  const CreateTaxCategory(this.category);
  @override
  List<Object?> get props => [category];
}

class LoadFbrInvoices extends TaxEvent {
  final String restaurantId;
  const LoadFbrInvoices(this.restaurantId);
  @override
  List<Object?> get props => [restaurantId];
}
