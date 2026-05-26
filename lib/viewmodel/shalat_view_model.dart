import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/logger.dart';

import '../model/shalat_schedule_response.dart';
import '../repository/shalat_repository.dart';

class ShalatViewModel extends ChangeNotifier {
  final ShalatRepository _repo;
  static const _secureStorage = FlutterSecureStorage();

  ShalatViewModel(this._repo);

  bool _isLoading = false;
  bool _isLoadingLocation = false;
  String? _error;
  List<ShalatDaySchedule> _schedules = [];

  String _cityName = 'Jakarta';
  int _cityId = 1206;

  bool get isLoading => _isLoading;
  bool get isLoadingLocation => _isLoadingLocation;
  String? get error => _error;
  List<ShalatDaySchedule> get schedules => _schedules;

  String get cityName => _cityName;
  int get cityId => _cityId;

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

  Future<void> updateLocationAndFetchSchedule({bool forceGPS = false}) async {
    _isLoading = true;
    _isLoadingLocation = true;
    _error = null;
    notifyListeners();

    try {
      if (!forceGPS) {
        final cachedCityIdStr = await _secureStorage.read(
          key: 'cached_city_id',
        );
        final cachedCityName = await _secureStorage.read(
          key: 'cached_city_name',
        );
        if (cachedCityIdStr != null && cachedCityName != null) {
          _cityId = int.tryParse(cachedCityIdStr) ?? 1206;
          _cityName = cachedCityName;
          _isLoadingLocation = false;
          notifyListeners();

          final now = DateTime.now();
          await fetchMonthlySchedule(
            cityId: _cityId,
            year: now.year,
            month: now.month,
          );
          return;
        }
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan lokasi (GPS) aktifkan terlebih dahulu.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin akses lokasi ditolak.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin akses lokasi ditolak secara permanen.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        String searchKeyword = '';

        if (place.subAdministrativeArea != null &&
            place.subAdministrativeArea!.isNotEmpty) {
          searchKeyword = place.subAdministrativeArea!
              .replaceAll(
                RegExp(
                  r'(Regency|Kabupaten|City|Kota|Regency\s+|\s+Regency|\s+City|City\s+)',
                  caseSensitive: false,
                ),
                '',
              )
              .trim();
        } else if (place.locality != null && place.locality!.isNotEmpty) {
          searchKeyword = place.locality!;
        }

        if (searchKeyword.isNotEmpty) {
          final resolvedId = await _repo.searchCity(searchKeyword);
          if (resolvedId != null) {
            _cityId = resolvedId;
            _cityName = searchKeyword;

            await _secureStorage.write(
              key: 'cached_city_id',
              value: _cityId.toString(),
            );
            await _secureStorage.write(
              key: 'cached_city_name',
              value: _cityName,
            );
          } else {
            _cityName = searchKeyword;
          }
        }
      }
    } catch (e) {
      final cachedCityIdStr = await _secureStorage.read(key: 'cached_city_id');
      final cachedCityName = await _secureStorage.read(key: 'cached_city_name');
      if (cachedCityIdStr != null) {
        _cityId = int.tryParse(cachedCityIdStr) ?? 1206;
        _cityName = cachedCityName ?? 'Jakarta';
      } else {
        _cityId = 1206;
        _cityName = 'Jakarta';
      }
      AppLogger.warningLazy(() => 'Location error: $e');
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }

    final now = DateTime.now();
    await fetchMonthlySchedule(
      cityId: _cityId,
      year: now.year,
      month: now.month,
    );
  }

  Future<void> selectCity(int cityId, String cityName) async {
    _cityId = cityId;
    _cityName = cityName;
    _error = null;
    notifyListeners();

    try {
      await _secureStorage.write(
        key: 'cached_city_id',
        value: _cityId.toString(),
      );
      await _secureStorage.write(key: 'cached_city_name', value: _cityName);

      final now = DateTime.now();
      await fetchMonthlySchedule(
        cityId: _cityId,
        year: now.year,
        month: now.month,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}