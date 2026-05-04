import 'package:equatable/equatable.dart';
import '../../domain/models/filter_detail.dart';

class FilterListState extends Equatable {
  final List<FilterDetail> filters;
  final bool isLoading;
  final String? error;

  // Pagination
  final int currentPage;
  final int total;
  static const int pageSize = 5;

  // Filters
  final int? quality;
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterListState({
    this.filters = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 0,
    this.total = 0,
    this.quality,
    this.startDate,
    this.endDate,
  });

  factory FilterListState.initial() => const FilterListState();

  int get totalPages => (total / pageSize).ceil().clamp(1, double.infinity).toInt();
  bool get hasPreviousPage => currentPage > 0;
  bool get hasNextPage => (currentPage + 1) < totalPages;

  int get offset => currentPage * pageSize;

  String? get startDateIso => startDate?.toIso8601String().split('T').first;
  String? get endDateIso => endDate?.toIso8601String().split('T').first;

  FilterListState copyWith({
    List<FilterDetail>? filters,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? total,
    int? quality,
    DateTime? startDate,
    DateTime? endDate,
    bool clearQuality = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearError = false,
  }) {
    return FilterListState(
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      total: total ?? this.total,
      quality: clearQuality ? null : (quality ?? this.quality),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
    );
  }

  @override
  List<Object?> get props =>
      [filters, isLoading, error, currentPage, total, quality, startDate, endDate];
}
