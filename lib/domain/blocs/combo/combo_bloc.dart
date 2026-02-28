import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/data/repositories/combo_repository.dart';
import 'package:restaurant/domain/blocs/combo/combo_event.dart';
import 'package:restaurant/domain/blocs/combo/combo_state.dart';

class ComboBloc extends Bloc<ComboEvent, ComboState> {
  final ComboRepository _comboRepository;

  ComboBloc({required ComboRepository comboRepository})
      : _comboRepository = comboRepository,
        super(ComboInitial()) {
    on<LoadCombos>(_onLoad);
    on<CreateCombo>(_onCreate);
    on<UpdateCombo>(_onUpdate);
    on<DeleteCombo>(_onDelete);
  }

  Future<void> _onLoad(LoadCombos event, Emitter<ComboState> emit) async {
    emit(ComboLoading());
    try {
      final combos = await _comboRepository.fetchCombos(event.restaurantId);
      emit(CombosLoaded(combos));
    } catch (e) {
      emit(ComboError(e.toString()));
    }
  }

  Future<void> _onCreate(CreateCombo event, Emitter<ComboState> emit) async {
    try {
      await _comboRepository.createCombo(event.combo);
      add(LoadCombos(event.combo.restaurantId));
    } catch (e) {
      emit(ComboError(e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateCombo event, Emitter<ComboState> emit) async {
    try {
      await _comboRepository.updateCombo(event.id, event.updates);
      add(LoadCombos(event.restaurantId));
    } catch (e) {
      emit(ComboError(e.toString()));
    }
  }

  Future<void> _onDelete(DeleteCombo event, Emitter<ComboState> emit) async {
    try {
      await _comboRepository.deleteCombo(event.id);
      add(LoadCombos(event.restaurantId));
    } catch (e) {
      emit(ComboError(e.toString()));
    }
  }
}
