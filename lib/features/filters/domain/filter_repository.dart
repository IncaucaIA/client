import 'models/filter_detail.dart';
import 'models/filter_summary.dart';
import 'models/paginated_result.dart';

abstract class FilterRepository {
  Future<FilterDetail> getFilterDetail(String filterId);
  Future<PaginatedResult<FilterSummary>> getFilters({
    int limit = 10,
    int offset = 0,
    String? startDate,
    String? endDate,
    int? quality,
  });
  Stream<PaginatedResult<FilterSummary>> watchFilters({
    int limit = 10,
    int offset = 0,
    String? startDate,
    String? endDate,
    int? quality,
  });
  Stream<String> listenToNotifications();
  Future<void> connectToNotifications();
  Future<void> disconnectFromNotifications();
}
