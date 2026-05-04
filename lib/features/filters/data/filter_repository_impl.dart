import '../domain/filter_repository.dart';
import '../domain/models/filter_detail.dart';
import '../domain/models/filter_summary.dart';
import 'package:incauca_labs/features/filters/domain/websocket_datasource.dart';

class FilterRepositoryImpl implements FilterRepository {
  final WebSocketDatasource webSocketDataSource;

  FilterRepositoryImpl({
    required this.webSocketDataSource,
  });

  @override
  Future<FilterDetail> getFilterDetail(String filterId) async {
    // Mock implementation for now
    await Future.delayed(const Duration(seconds: 1));
    return FilterDetail(
      id: filterId,
      imageUrl: 'https://via.placeholder.com/400',
      impurityCount: 15,
      fineBagasse: 2,
      metal: 1,
      sand: 12,
      firstEffect: 0,
      secondEffect: 1,
      thirdEffect: 2,
      fourthEffect: 3,
      fifthEffect: 4,
      processedAt: DateTime.now(),
    );
  }

  @override
  Future<List<FilterSummary>> getFilters() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.generate(
      5,
      (index) => FilterSummary(
        id: 'filter_${index + 1}',
        imageUrl: 'https://via.placeholder.com/100',
        impurityCount: 10 + index,
        processedAt: DateTime.now().subtract(Duration(hours: index)),
      ),
    );
  }

  @override
  Stream<List<FilterSummary>> watchFilters() async* {
    // 1. Emit initial data
    yield await getFilters();

    // 2. Listen to notifications and yield updated data whenever a new message arrives
    await for (final _ in listenToNotifications()) {
      yield await getFilters();
    }
  }

  @override
  Stream<String> listenToNotifications() {
    return webSocketDataSource.getMessageStream();
  }

  @override
  Future<void> connectToNotifications() async {
    await webSocketDataSource.connect();
  }

  @override
  Future<void> disconnectFromNotifications() async {
    await webSocketDataSource.disconnect();
  }
}
