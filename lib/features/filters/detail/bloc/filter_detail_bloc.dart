import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/filter_repository.dart';
import 'filter_detail_event.dart';
import 'filter_detail_state.dart';

class FilterDetailBloc extends Bloc<FilterDetailEvent, FilterDetailState> {
  final FilterRepository _filterRepository;

  FilterDetailBloc({
    required FilterRepository filterRepository,
  })  : _filterRepository = filterRepository,
        super(FilterDetailState.initial()) {
    on<FilterDetailRequested>(_onFilterDetailRequested);
  }

  Future<void> _onFilterDetailRequested(
    FilterDetailRequested event,
    Emitter<FilterDetailState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      // getFilterDetail endpoint no longer exists. 
      // Detail is now passed directly from the list state.
      throw UnimplementedError('Detail is now passed directly from the list');
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
