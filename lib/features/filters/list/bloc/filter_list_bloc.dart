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
    on<FilterListPageChanged>(_onPageChanged);
    on<FilterListFiltersApplied>(_onFiltersApplied);
    on<FilterListFiltersCleared>(_onFiltersCleared);
  }

  Future<void> _onSubscriptionRequested(
    FilterListSubscriptionRequested event,
    Emitter<FilterListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      await _filterRepository.connectToNotifications();
    } catch (e) {
      print('⚠️ Notification connection failed: $e');
    }

    await emit.forEach(
      _filterRepository.watchFilters(
        limit: FilterListState.pageSize,
        offset: state.offset,
        startDate: state.startDateIso,
        endDate: state.endDateIso,
      ),
      onData: (paginatedResult) => state.copyWith(
        isLoading: false,
        filters: paginatedResult.items,
        total: paginatedResult.total,
        clearError: true,
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
    await _fetchPage(emit);
  }

  Future<void> _onPageChanged(
    FilterListPageChanged event,
    Emitter<FilterListState> emit,
  ) async {
    emit(state.copyWith(currentPage: event.page));
    await _fetchPage(emit);
  }

  Future<void> _onFiltersApplied(
    FilterListFiltersApplied event,
    Emitter<FilterListState> emit,
  ) async {
    emit(state.copyWith(
      startDate: event.startDate,
      endDate: event.endDate,
      currentPage: 0,
      clearStartDate: event.startDate == null,
      clearEndDate: event.endDate == null,
    ));
    await _fetchPage(emit);
  }

  Future<void> _onFiltersCleared(
    FilterListFiltersCleared event,
    Emitter<FilterListState> emit,
  ) async {
    emit(state.copyWith(
      currentPage: 0,
      clearStartDate: true,
      clearEndDate: true,
    ));
    await _fetchPage(emit);
  }

  Future<void> _fetchPage(Emitter<FilterListState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final result = await _filterRepository.getFilters(
        limit: FilterListState.pageSize,
        offset: state.offset,
        startDate: state.startDateIso,
        endDate: state.endDateIso,
      );
      emit(state.copyWith(
        isLoading: false,
        filters: result.items,
        total: result.total,
        clearError: true,
      ));
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
