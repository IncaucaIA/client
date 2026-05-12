import 'package:equatable/equatable.dart';

abstract class FilterListEvent extends Equatable {
  const FilterListEvent();

  @override
  List<Object?> get props => [];
}

class FilterListSubscriptionRequested extends FilterListEvent {}

class FilterListRefreshRequested extends FilterListEvent {}

class FilterListPageChanged extends FilterListEvent {
  final int page;
  const FilterListPageChanged(this.page);

  @override
  List<Object?> get props => [page];
}

class FilterListFiltersApplied extends FilterListEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterListFiltersApplied({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class FilterListFiltersCleared extends FilterListEvent {}
