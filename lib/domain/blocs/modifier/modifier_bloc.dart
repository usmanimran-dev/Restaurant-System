import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/data/repositories/modifier_repository.dart';
import 'package:restaurant/domain/blocs/modifier/modifier_event.dart';
import 'package:restaurant/domain/blocs/modifier/modifier_state.dart';

class ModifierBloc extends Bloc<ModifierEvent, ModifierState> {
  final ModifierRepository _modifierRepository;

  ModifierBloc({required ModifierRepository modifierRepository})
      : _modifierRepository = modifierRepository,
        super(ModifierInitial()) {
    on<LoadModifierGroups>(_onLoadGroups);
    on<LoadModifierItems>(_onLoadItems);
    on<CreateModifierGroup>(_onCreateGroup);
    on<CreateModifierItem>(_onCreateItem);
    on<DeleteModifierGroup>(_onDeleteGroup);
    on<DeleteModifierItem>(_onDeleteItem);
  }

  Future<void> _onLoadGroups(LoadModifierGroups event, Emitter<ModifierState> emit) async {
    emit(ModifierLoading());
    try {
      final groups = await _modifierRepository.fetchGroupsByRestaurant(event.restaurantId);
      emit(ModifierGroupsLoaded(groups));
    } catch (e) {
      emit(ModifierError(e.toString()));
    }
  }

  Future<void> _onLoadItems(LoadModifierItems event, Emitter<ModifierState> emit) async {
    emit(ModifierLoading());
    try {
      final items = await _modifierRepository.fetchItems(event.groupId);
      emit(ModifierItemsLoaded(items, event.groupId));
    } catch (e) {
      emit(ModifierError(e.toString()));
    }
  }

  Future<void> _onCreateGroup(CreateModifierGroup event, Emitter<ModifierState> emit) async {
    try {
      await _modifierRepository.createGroup(event.group);
      add(LoadModifierGroups(event.group.restaurantId));
    } catch (e) {
      emit(ModifierError(e.toString()));
    }
  }

  Future<void> _onCreateItem(CreateModifierItem event, Emitter<ModifierState> emit) async {
    try {
      await _modifierRepository.createItem(event.item);
      add(LoadModifierItems(event.item.groupId));
    } catch (e) {
      emit(ModifierError(e.toString()));
    }
  }

  Future<void> _onDeleteGroup(DeleteModifierGroup event, Emitter<ModifierState> emit) async {
    try {
      await _modifierRepository.deleteGroup(event.groupId);
      add(LoadModifierGroups(event.restaurantId));
    } catch (e) {
      emit(ModifierError(e.toString()));
    }
  }

  Future<void> _onDeleteItem(DeleteModifierItem event, Emitter<ModifierState> emit) async {
    try {
      await _modifierRepository.deleteItem(event.itemId);
      add(LoadModifierItems(event.groupId));
    } catch (e) {
      emit(ModifierError(e.toString()));
    }
  }
}
