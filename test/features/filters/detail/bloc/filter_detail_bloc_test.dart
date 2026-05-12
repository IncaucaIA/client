import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:incauca_labs/features/filters/domain/filter_repository.dart';
import 'package:incauca_labs/features/filters/detail/bloc/filter_detail_bloc.dart';
import 'package:incauca_labs/features/filters/detail/bloc/filter_detail_event.dart';
import 'package:incauca_labs/features/filters/detail/bloc/filter_detail_state.dart';

class MockFilterRepository extends Mock implements FilterRepository {}

void main() {
  late MockFilterRepository filterRepository;
  late FilterDetailBloc filterDetailBloc;

  setUp(() {
    filterRepository = MockFilterRepository();
    filterDetailBloc = FilterDetailBloc(filterRepository: filterRepository);
  });

  tearDown(() {
    filterDetailBloc.close();
  });

  group('FilterDetailBloc', () {
    test('initial state is correct', () {
      expect(filterDetailBloc.state, FilterDetailState.initial());
    });

    blocTest<FilterDetailBloc, FilterDetailState>(
      'emits [loading, error] when detail is requested (since it is unimplemented)',
      build: () => filterDetailBloc,
      act: (bloc) => bloc.add(const FilterDetailRequested('1')),
      expect: () => [
        FilterDetailState.initial().copyWith(isLoading: true),
        FilterDetailState.initial().copyWith(
          isLoading: false,
          error: 'UnimplementedError: Detail is now passed directly from the list',
        ),
      ],
    );
  });
}
