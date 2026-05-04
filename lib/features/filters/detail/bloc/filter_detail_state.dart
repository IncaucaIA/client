import 'package:equatable/equatable.dart';
import '../../domain/models/filter_detail.dart';

class FilterDetailState extends Equatable {
  final FilterDetail? detail;
  final bool isLoading;
  final String? error;

  const FilterDetailState({
    this.detail,
    this.isLoading = false,
    this.error,
  });

  factory FilterDetailState.initial() {
    return const FilterDetailState();
  }

  FilterDetailState copyWith({
    FilterDetail? detail,
    bool? isLoading,
    String? error,
  }) {
    return FilterDetailState(
      detail: detail ?? this.detail,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [detail, isLoading, error];
}
