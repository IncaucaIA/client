import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:incauca_labs/features/filters/domain/filter_repository.dart';
import 'package:incauca_labs/features/filters/domain/models/filter_detail.dart';
import 'package:incauca_labs/features/filters/domain/models/paginated_result.dart';
import 'package:incauca_labs/features/filters/list/bloc/filter_list_bloc.dart';
import 'package:incauca_labs/features/filters/list/bloc/filter_list_event.dart';
import 'package:incauca_labs/features/filters/list/bloc/filter_list_state.dart';

class MockFilterRepository extends Mock implements FilterRepository {}

void main() {
  late FilterRepository filterRepository;
  late FilterListBloc filterListBloc;

  final testDetail = FilterDetail(
    id: '1',
    imageUrl: 'url',
    impurityCount: 10,
    metal: 1,
    other: 2,
    firstEffect: 1,
    secondAndThirdEffect: 2,
    fourthEffect: 1,
    fifthEffect: 1,
    quality: 90,
    processedAt: DateTime(2024, 5, 4),
  );

  final testPaginatedResult = PaginatedResult<FilterDetail>(
    items: [testDetail],
    total: 1,
    limit: 5,
    offset: 0,
  );

  setUp(() {
    filterRepository = MockFilterRepository();
    filterListBloc = FilterListBloc(filterRepository: filterRepository);

    when(() => filterRepository.connectToNotifications())
        .thenAnswer((_) async => {});
    when(() => filterRepository.disconnectFromNotifications())
        .thenAnswer((_) async => {});
    when(() => filterRepository.getFilters(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        )).thenAnswer((_) async => testPaginatedResult);
    when(() => filterRepository.watchFilters(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        )).thenAnswer((_) => Stream.value(testPaginatedResult));
  });

  tearDown(() {
    filterListBloc.close();
  });

  group('FilterListBloc', () {
    test('initial state is correct', () {
      expect(filterListBloc.state, FilterListState.initial());
    });

    blocTest<FilterListBloc, FilterListState>(
      'emits [loading, success] when FilterListSubscriptionRequested is added',
      build: () => filterListBloc,
      act: (bloc) => bloc.add(FilterListSubscriptionRequested()),
      expect: () => [
        FilterListState.initial().copyWith(isLoading: true),
        FilterListState.initial().copyWith(
          isLoading: false,
          filters: [testDetail],
          total: 1,
          clearError: true,
        ),
      ],
      verify: (_) {
        verify(() => filterRepository.connectToNotifications()).called(1);
        verify(() => filterRepository.watchFilters(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).called(1);
      },
    );

    blocTest<FilterListBloc, FilterListState>(
      'emits [loading, success] when FilterListRefreshRequested is added',
      build: () => filterListBloc,
      act: (bloc) => bloc.add(FilterListRefreshRequested()),
      expect: () => [
        FilterListState.initial().copyWith(isLoading: true),
        FilterListState.initial().copyWith(
          isLoading: false,
          filters: [testDetail],
          total: 1,
          clearError: true,
        ),
      ],
    );

    blocTest<FilterListBloc, FilterListState>(
      'emits [pageChanged, loading, success] when FilterListPageChanged is added',
      build: () => filterListBloc,
      act: (bloc) => bloc.add(const FilterListPageChanged(1)),
      expect: () => [
        FilterListState.initial().copyWith(currentPage: 1),
        FilterListState.initial().copyWith(currentPage: 1, isLoading: true),
        FilterListState.initial().copyWith(
          currentPage: 1,
          isLoading: false,
          filters: [testDetail],
          total: 1,
          clearError: true,
        ),
      ],
    );

    blocTest<FilterListBloc, FilterListState>(
      'emits [filtersApplied, loading, success] when FilterListFiltersApplied is added',
      build: () => filterListBloc,
      act: (bloc) => bloc.add(FilterListFiltersApplied(
        startDate: DateTime(2024, 5, 1),
        endDate: DateTime(2024, 5, 31),
      )),
      expect: () => [
        FilterListState.initial().copyWith(
          startDate: DateTime(2024, 5, 1),
          endDate: DateTime(2024, 5, 31),
          currentPage: 0,
        ),
        FilterListState.initial().copyWith(
          startDate: DateTime(2024, 5, 1),
          endDate: DateTime(2024, 5, 31),
          currentPage: 0,
          isLoading: true,
        ),
        FilterListState.initial().copyWith(
          startDate: DateTime(2024, 5, 1),
          endDate: DateTime(2024, 5, 31),
          currentPage: 0,
          isLoading: false,
          filters: [testDetail],
          total: 1,
          clearError: true,
        ),
      ],
    );

    blocTest<FilterListBloc, FilterListState>(
      'emits [filtersCleared, loading, success] when FilterListFiltersCleared is added',
      build: () => filterListBloc,
      act: (bloc) => bloc.add(FilterListFiltersCleared()),
      expect: () => [
        FilterListState.initial().copyWith(
          currentPage: 0,
        ),
        FilterListState.initial().copyWith(
          currentPage: 0,
          isLoading: true,
        ),
        FilterListState.initial().copyWith(
          currentPage: 0,
          isLoading: false,
          filters: [testDetail],
          total: 1,
          clearError: true,
        ),
      ],
    );

    blocTest<FilterListBloc, FilterListState>(
      'emits [loading, error] when fetch fails',
      build: () {
        when(() => filterRepository.getFilters(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenThrow(Exception('Fetch failed'));
        return filterListBloc;
      },
      act: (bloc) => bloc.add(FilterListRefreshRequested()),
      expect: () => [
        FilterListState.initial().copyWith(isLoading: true),
        FilterListState.initial().copyWith(
          isLoading: false,
          error: 'Exception: Fetch failed',
        ),
      ],
    );
  });
}
