import 'dart:convert';

import 'package:energy_monitor_app_flutter/features/home/data/models/monitoring_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class HomeLocalDatasource {
  /// Retrieves cached monitoring data for the given [date] and [metric].
  /// Returns `null` if no cache is found.
  Future<List<MonitoringModel>?> getMonitoringData({
    required String date,
    required String metric,
  });

  /// Caches the [data] for the given [date] and [metric].
  Future<void> cacheMonitoringData({
    required String date,
    required String metric,
    required List<MonitoringModel> data,
  });

  /// Clears the entire cache in SharedPreferences that belongs to this data source.
  Future<void> clearCache();
}

class HomeLocalDatasourceImpl implements HomeLocalDatasource {
  final SharedPreferences sharedPreferences;

  static String _cacheKey(String metric, String date) {
    return 'LOCAL_DATA_${metric}_$date';
  }

  const HomeLocalDatasourceImpl({required this.sharedPreferences});

  @override
  Future<List<MonitoringModel>?> getMonitoringData({
    required String date,
    required String metric,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _cacheKey(metric, date);

    final jsonString = prefs.getString(key);
    if (jsonString == null) {
      return null;
    }

    final List<dynamic> rawList = json.decode(jsonString);

    final List<MonitoringModel> models = rawList
        .map<MonitoringModel>((item) => MonitoringModel.fromJson(item))
        .toList();
    return models;
  }

  @override
  Future<void> cacheMonitoringData({
    required String date,
    required String metric,
    required List<MonitoringModel> data,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _cacheKey(metric, date);

    final List<Map<String, dynamic>> rawList =
        data.map((m) => m.toJson()).toList();
    final jsonString = jsonEncode(rawList);

    await prefs.setString(key, jsonString);
  }

  @override
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();

    final keysToRemove =
        prefs.getKeys().where((k) => k.startsWith('LOCAL_DATA_'));

    for (var k in keysToRemove) {
      await prefs.remove(k);
    }
  }
}
