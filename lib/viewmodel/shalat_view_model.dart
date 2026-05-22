import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/shalat_schedule_response.dart';
import '../repository/shalat_repository.dart';

class ShalatViewModel extends ChangeNotifier {
  final ShalatRepository _repo;
  ShalatViewModel(this._repo);

  bool _isLoading = false;
  bool _isLoadingLocation = false;
  String? _error;
  List<ShalatDaySchedule> _schedules = [];

  String _cityName = 'Jakarta';
  int _cityId = 1206; // Default Jakarta ID

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
      final prefs = await SharedPreferences.getInstance();

      // 1. Cek jika data ada di cache dan tidak forceGPS
      if (!forceGPS) {
        final cachedCityId = prefs.getInt('cached_city_id');
        final cachedCityName = prefs.getString('cached_city_name');
        if (cachedCityId != null && cachedCityName != null) {
          _cityId = cachedCityId;
          _cityName = cachedCityName;
          _isLoadingLocation = false;
          notifyListeners();
          
          // Ambil jadwal bulanan langsung
          final now = DateTime.now();
          await fetchMonthlySchedule(cityId: _cityId, year: now.year, month: now.month);
          return;
        }
      }

      // 2. Gunakan GPS untuk mencari koordinat real-time
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

      // Ambil posisi GPS (menggunakan API non-deprecated)
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      // Terjemahkan koordinat ke nama kota/wilayah (Reverse Geocoding)
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        String searchKeyword = '';

        if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
          searchKeyword = place.subAdministrativeArea!
              .replaceAll(RegExp(r'(Regency|Kabupaten|City|Kota|Regency\s+|\s+Regency|\s+City|City\s+)', caseSensitive: false), '')
              .trim();
        } else if (place.locality != null && place.locality!.isNotEmpty) {
          searchKeyword = place.locality!;
        }

        if (searchKeyword.isNotEmpty) {
          // Cari ID kota di API MyQuran
          final resolvedId = await _repo.searchCity(searchKeyword);
          if (resolvedId != null) {
            _cityId = resolvedId;
            _cityName = searchKeyword;
            
            // Simpan di cache SharedPreferences
            await prefs.setInt('cached_city_id', _cityId);
            await prefs.setString('cached_city_name', _cityName);
          } else {
            // Jika ID kota tidak terdaftar di API, tetap tampilkan lokasi GPS terdeteksi tapi pakai default ID
            _cityName = searchKeyword;
          }
        }
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getInt('cached_city_id') != null) {
        _cityId = prefs.getInt('cached_city_id')!;
        _cityName = prefs.getString('cached_city_name') ?? 'Jakarta';
      } else {
        _cityId = 1206; // Fallback Jakarta
        _cityName = 'Jakarta';
      }
      debugPrint('Location error: $e');
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }

    // Ambil jadwal bulanan berdasarkan data final
    final now = DateTime.now();
    await fetchMonthlySchedule(cityId: _cityId, year: now.year, month: now.month);
  }

  Future<void> selectCity(int cityId, String cityName) async {
    _cityId = cityId;
    _cityName = cityName;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('cached_city_id', _cityId);
      await prefs.setString('cached_city_name', _cityName);
      
      final now = DateTime.now();
      await fetchMonthlySchedule(cityId: _cityId, year: now.year, month: now.month);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
