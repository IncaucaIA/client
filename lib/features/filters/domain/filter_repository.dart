import 'models/filter_detail.dart';
import 'models/filter_summary.dart';
import 'models/paginated_result.dart';

abstract class FilterRepository {
  Future<PaginatedResult<FilterDetail>> getFilters({
    int limit = 10,
    int offset = 0,
    String? startDate,
    String? endDate,
  });
  Stream<PaginatedResult<FilterDetail>> watchFilters({
    int limit = 10,
    int offset = 0,
    String? startDate,
    String? endDate,
  });
  Stream<String> listenToNotifications();
  Future<void> connectToNotifications();
  Future<void> disconnectFromNotifications();
}
