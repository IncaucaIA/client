import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/filter_repository.dart';
import 'filter_list_event.dart';
import 'filter_list_state.dart';

class FilterListBloc extends Bloc<FilterListEvent, FilterListState> {
  final FilterRepository _filterRepository;

  FilterListBloc({
    required FilterRepository filterRepository,
  })  : _filterRepository = filterRepository,
        super(FilterListState.initial()) {
    on<FilterListSubscriptionRequested>(_onSubscriptionRequested);
    on<FilterListRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onSubscriptionRequested(
    FilterListSubscriptionRequested event,
    Emitter<FilterListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    // Connect to notifications when subscription starts
    try {
      await _filterRepository.connectToNotifications();
    } catch (e) {
      print('⚠️ Notification connection failed: $e');
      // We continue anyway so we can at least show the initial data
    }

    await emit.forEach(
      _filterRepository.watchFilters(),
      onData: (filters) => state.copyWith(
        isLoading: false,
        filters: filters,
        error: null,
      ),
      onError: (error, stackTrace) => state.copyWith(
        isLoading: false,
        error: error.toString(),
      ),
    );
  }

  Future<void> _onRefreshRequested(
    FilterListRefreshRequested event,
    Emitter<FilterListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final filters = await _filterRepository.getFilters();
      emit(state.copyWith(isLoading: false, filters: filters, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _filterRepository.disconnectFromNotifications();
    return super.close();
  }
}
