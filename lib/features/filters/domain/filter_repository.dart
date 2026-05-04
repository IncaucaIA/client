import 'models/filter_detail.dart';
import 'models/filter_summary.dart';

abstract class FilterRepository {
  Future<FilterDetail> getFilterDetail(String filterId);
  Future<List<FilterSummary>> getFilters();
  Stream<List<FilterSummary>> watchFilters();
  Stream<String> listenToNotifications();
  Future<void> connectToNotifications();
  Future<void> disconnectFromNotifications();
}
