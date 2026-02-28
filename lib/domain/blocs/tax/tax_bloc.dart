import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/data/repositories/tax_repository.dart';
import 'package:restaurant/domain/blocs/tax/tax_event.dart';
import 'package:restaurant/domain/blocs/tax/tax_state.dart';

class TaxBloc extends Bloc<TaxEvent, TaxState> {
  final TaxRepository _taxRepository;

  TaxBloc({required TaxRepository taxRepository})
      : _taxRepository = taxRepository,
        super(TaxInitial()) {
    on<LoadTaxConfig>(_onLoadConfig);
    on<CreateTaxConfig>(_onCreateConfig);
    on<UpdateTaxConfig>(_onUpdateConfig);
    on<LoadTaxCategories>(_onLoadCategories);
    on<CreateTaxCategory>(_onCreateCategory);
    on<LoadFbrInvoices>(_onLoadFbrInvoices);
  }

  Future<void> _onLoadConfig(LoadTaxConfig event, Emitter<TaxState> emit) async {
    emit(TaxLoading());
    try {
      final configs = await _taxRepository.fetchConfigurations(event.restaurantId);
      final defaultConfig = await _taxRepository.getDefaultConfig(event.restaurantId);
      emit(TaxConfigLoaded(configs, defaultConfig));
    } catch (e) {
      emit(TaxError(e.toString()));
    }
  }

  Future<void> _onCreateConfig(CreateTaxConfig event, Emitter<TaxState> emit) async {
    try {
      await _taxRepository.createConfiguration(event.config);
      add(LoadTaxConfig(event.config.restaurantId));
    } catch (e) {
      emit(TaxError(e.toString()));
    }
  }

  Future<void> _onUpdateConfig(UpdateTaxConfig event, Emitter<TaxState> emit) async {
    try {
      await _taxRepository.updateConfiguration(event.id, event.updates);
      add(LoadTaxConfig(event.restaurantId));
    } catch (e) {
      emit(TaxError(e.toString()));
    }
  }

  Future<void> _onLoadCategories(LoadTaxCategories event, Emitter<TaxState> emit) async {
    emit(TaxLoading());
    try {
      final categories = await _taxRepository.fetchCategories(event.restaurantId);
      emit(TaxCategoriesLoaded(categories));
    } catch (e) {
      emit(TaxError(e.toString()));
    }
  }

  Future<void> _onCreateCategory(CreateTaxCategory event, Emitter<TaxState> emit) async {
    try {
      await _taxRepository.createCategory(event.category);
      add(LoadTaxCategories(event.category.restaurantId));
    } catch (e) {
      emit(TaxError(e.toString()));
    }
  }

  Future<void> _onLoadFbrInvoices(LoadFbrInvoices event, Emitter<TaxState> emit) async {
    emit(TaxLoading());
    try {
      final invoices = await _taxRepository.fetchFbrInvoices(event.restaurantId);
      emit(FbrInvoicesLoaded(invoices));
    } catch (e) {
      emit(TaxError(e.toString()));
    }
  }
}
