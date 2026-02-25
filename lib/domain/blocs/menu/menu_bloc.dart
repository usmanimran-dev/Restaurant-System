import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/data/repositories/menu_repository.dart';
import 'package:restaurant/domain/blocs/menu/menu_event.dart';
import 'package:restaurant/domain/blocs/menu/menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final MenuRepository _menuRepository;

  MenuBloc({required MenuRepository menuRepository})
      : _menuRepository = menuRepository,
        super(MenuInitial()) {
    on<LoadMenu>(_onLoadMenu);
    on<CreateCategory>(_onCreateCategory);
    on<CreateMenuItem>(_onCreateMenuItem);
  }

  Future<void> _onLoadMenu(LoadMenu event, Emitter<MenuState> emit) async {
    emit(MenuLoading());
    try {
      final categories = await _menuRepository.fetchCategories(event.restaurantId);
      final items = await _menuRepository.fetchItems(event.restaurantId);
      emit(MenuLoaded(categories: categories, items: items));
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  Future<void> _onCreateCategory(CreateCategory event, Emitter<MenuState> emit) async {
    try {
      await _menuRepository.createCategory(event.category);
      emit(const MenuOperationSuccess('Category created successfully.'));
      add(LoadMenu(event.category.restaurantId));
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  Future<void> _onCreateMenuItem(CreateMenuItem event, Emitter<MenuState> emit) async {
    try {
      await _menuRepository.createItem(event.item);
      emit(const MenuOperationSuccess('Item created successfully.'));
      add(LoadMenu(event.item.restaurantId));
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }
}
