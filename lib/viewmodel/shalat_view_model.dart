import 'package:flutter/foundation.dart';

import '../model/shalat_schedule_response.dart';
import '../repository/shalat_repository.dart';

class ShalatViewModel extends ChangeNotifier {
  final ShalatRepository _repo;
  ShalatViewModel(this._repo);

  bool _isLoading = false;
  String? _error;
  List<ShalatDaySchedule> _schedules = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ShalatDaySchedule> get schedules => _schedules;

  Future<void> fetchMonthlySchedule({
    required int cityId,
    required int year,
    required int month,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _repo.getMonthlySchedule(
        cityId: cityId,
        year: year,
        month: month,
      );
      _schedules = res.schedules;
    } catch (e) {
      _error = e.toString();
      _schedules = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
