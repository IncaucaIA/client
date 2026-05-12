import 'package:flutter_test/flutter_test.dart';
import 'package:incauca_labs/features/filters/list/bloc/filter_list_state.dart';

void main() {
  group('FilterListState', () {
    test('initial state has correct default values', () {
      final state = FilterListState.initial();
      expect(state.filters, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.currentPage, 0);
      expect(state.total, 0);
      expect(state.startDate, isNull);
      expect(state.endDate, isNull);
    });

    test('totalPages calculation is correct', () {
      const state = FilterListState(total: 10); // pageSize is 5
      expect(state.totalPages, 2);

      const state2 = FilterListState(total: 12);
      expect(state2.totalPages, 3);

      const state3 = FilterListState(total: 0);
      expect(state3.totalPages, 1);
    });

    test('pagination getters are correct', () {
      const state = FilterListState(currentPage: 0, total: 10);
      expect(state.hasPreviousPage, isFalse);
      expect(state.hasNextPage, isTrue);

      const state2 = FilterListState(currentPage: 1, total: 10);
      expect(state2.hasPreviousPage, isTrue);
      expect(state2.hasNextPage, isFalse);
    });

    test('offset calculation is correct', () {
      const state = FilterListState(currentPage: 0);
      expect(state.offset, 0);

      const state2 = FilterListState(currentPage: 2);
      expect(state2.offset, 10);
    });

    test('date ISO strings are correct', () {
      final startDate = DateTime(2024, 5, 4);
      final state = FilterListState(startDate: startDate);
      expect(state.startDateIso, '2024-05-04');
      expect(state.endDateIso, isNull);
    });

    test('copyWith works correctly', () {
      final state = FilterListState.initial();
      final newState = state.copyWith(
        isLoading: true,
        total: 100,
        error: 'error',
      );

      expect(newState.isLoading, isTrue);
      expect(newState.total, 100);
      expect(newState.error, 'error');

      final clearedState = newState.copyWith(clearError: true);
      expect(clearedState.error, isNull);
    });

    test('supports value equality', () {
      expect(FilterListState.initial(), FilterListState.initial());
    });
  });
}
