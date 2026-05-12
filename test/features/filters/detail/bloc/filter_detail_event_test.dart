import 'package:flutter_test/flutter_test.dart';
import 'package:incauca_labs/features/filters/detail/bloc/filter_detail_event.dart';

void main() {
  group('FilterDetailEvent', () {
    test('FilterDetailRequested supports value equality', () {
      expect(
        const FilterDetailRequested('1'),
        const FilterDetailRequested('1'),
      );
      expect(
        const FilterDetailRequested('1').props,
        ['1'],
      );
    });
  });
}
