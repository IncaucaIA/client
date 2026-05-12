import 'package:flutter_test/flutter_test.dart';
import 'package:incauca_labs/features/filters/list/bloc/filter_list_event.dart';

void main() {
  group('FilterListEvent', () {
    test('FilterListSubscriptionRequested supports value equality', () {
      expect(FilterListSubscriptionRequested(), FilterListSubscriptionRequested());
    });

    test('FilterListRefreshRequested supports value equality', () {
      expect(FilterListRefreshRequested(), FilterListRefreshRequested());
    });

    test('FilterListPageChanged stores page and supports value equality', () {
      const event = FilterListPageChanged(1);
      expect(event.page, 1);
      expect(event.props, [1]);
      expect(event, const FilterListPageChanged(1));
      expect(event, isNot(const FilterListPageChanged(2)));
    });

    test('FilterListFiltersApplied stores dates and supports value equality', () {
      final date1 = DateTime(2024, 5, 4);
      final date2 = DateTime(2024, 5, 5);
      final event = FilterListFiltersApplied(startDate: date1, endDate: date2);
      expect(event.startDate, date1);
      expect(event.endDate, date2);
      expect(event.props, [date1, date2]);
      expect(
        event,
        FilterListFiltersApplied(startDate: date1, endDate: date2),
      );
    });

    test('FilterListFiltersCleared supports value equality', () {
      expect(FilterListFiltersCleared(), FilterListFiltersCleared());
    });
  });
}
