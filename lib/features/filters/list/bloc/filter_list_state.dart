import 'package:equatable/equatable.dart';
import '../../domain/models/filter_summary.dart';

class FilterListState extends Equatable {
  final List<FilterSummary> filters;
  final bool isLoading;
  final String? error;

  const FilterListState({
    this.filters = const [],
    this.isLoading = false,
    this.error,
  });

  factory FilterListState.initial() {
    return const FilterListState();
  }

  FilterListState copyWith({
    List<FilterSummary>? filters,
    bool? isLoading,
    String? error,
  }) {
    return FilterListState(
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [filters, isLoading, error];
}
