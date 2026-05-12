import 'package:flutter_test/flutter_test.dart';
import 'package:incauca_labs/features/filters/detail/bloc/filter_detail_event.dart';

void main() {
  group('FilterDetailEvent', () {
    test('Base FilterDetailEvent supports value equality', () {
      expect(_TestFilterDetailEvent(), _TestFilterDetailEvent());
      expect(_TestFilterDetailEvent().props, <Object?>[]);
    });

    test('FilterDetailRequested supports value equality', () {
      expect(
        FilterDetailRequested('1'),
        FilterDetailRequested('1'),
      );
      expect(
        FilterDetailRequested('1').props,
        ['1'],
      );
    });
  });
}

class _TestFilterDetailEvent extends FilterDetailEvent {
  const _TestFilterDetailEvent();
}
