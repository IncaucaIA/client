import 'package:equatable/equatable.dart';

abstract class FilterListEvent extends Equatable {
  const FilterListEvent();

  @override
  List<Object?> get props => [];
}

class FilterListSubscriptionRequested extends FilterListEvent {}

class FilterListRefreshRequested extends FilterListEvent {}
