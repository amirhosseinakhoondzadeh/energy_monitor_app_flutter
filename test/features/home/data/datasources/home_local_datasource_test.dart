import 'dart:convert';

import 'package:energy_monitor_app_flutter/features/home/data/datasources/home_local_datasource.dart';
import 'package:energy_monitor_app_flutter/features/home/data/models/monitoring_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late HomeLocalDatasourceImpl dataSource;

  setUp(() async {
    // Reset the in-memory SharedPreferences before each test
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();
    dataSource = HomeLocalDatasourceImpl(sharedPreferences: sharedPrefs);
  });

  group('getMonitoringData', () {
    test('should return null if there is no cached data for given date/metric',
        () async {
      // act
      final result = await dataSource.getMonitoringData(
        date: '2024-10-11',
        metric: 'solar',
      );

      // assert
      expect(result, isNull);
    });

    test('should return a List<MonitoringModel> if cached data is present',
        () async {
      // arrange
      final testModels = [
        MonitoringModel(
            timestamp: DateTime.parse('2024-10-11T00:00:00.000Z'), value: 1000),
        MonitoringModel(
            timestamp: DateTime.parse('2024-10-11T00:05:00.000Z'), value: 2000),
      ];
      final date = '2024-10-11';
      final metric = 'solar';
      final cacheKey = 'LOCAL_DATA_${metric}_$date';

      final sharedPrefs = await SharedPreferences.getInstance();
      final rawList = testModels.map((m) => m.toJson()).toList();
      await sharedPrefs.setString(cacheKey, jsonEncode(rawList));

      // act
      final result =
          await dataSource.getMonitoringData(date: date, metric: metric);

      // assert
      expect(result, isNotNull);
      expect(result, isA<List<MonitoringModel>>());
      expect(result!.length, 2);
      expect(result[0].timestamp, testModels[0].timestamp);
      expect(result[0].value, testModels[0].value);
      expect(result[1].timestamp, testModels[1].timestamp);
      expect(result[1].value, testModels[1].value);
    });
  });

  group('cacheMonitoringData', () {
    test('should write the serialized data to SharedPreferences', () async {
      // arrange
      final testModels = [
        MonitoringModel(
            timestamp: DateTime.parse('2024-10-11T00:00:00.000Z'), value: 1234),
      ];
      final date = '2024-10-11';
      final metric = 'solar';
      final cacheKey = 'LOCAL_DATA_${metric}_$date';

      // act
      await dataSource.cacheMonitoringData(
          date: date, metric: metric, data: testModels);

      // assert
      final sharedPrefs = await SharedPreferences.getInstance();
      final storedString = sharedPrefs.getString(cacheKey);
      expect(storedString, isNotNull);

      final decoded = jsonDecode(storedString!) as List<dynamic>;
      expect(decoded.length, 1);
      expect(decoded[0]['value'], 1234);
      expect(decoded[0]['timestamp'], '2024-10-11T00:00:00.000Z');
    });
  });

  group('clearCache', () {
    test('should remove all keys that start with LOCAL_DATA_', () async {
      // arrange
      final sharedPrefs = await SharedPreferences.getInstance();

      await sharedPrefs.setString(
          'LOCAL_DATA_solar_2024-10-11', 'fake_solar_data');
      await sharedPrefs.setString(
          'LOCAL_DATA_house_2024-10-11', 'fake_house_data');

      await sharedPrefs.setString('OTHER_KEY', 'other_value');

      // sanity check
      expect(sharedPrefs.getKeys().length, 3);

      // act
      await dataSource.clearCache();

      // assert
      final remainingKeys = sharedPrefs.getKeys();

      expect(remainingKeys.contains('LOCAL_DATA_solar_2024-10-11'), false);
      expect(remainingKeys.contains('LOCAL_DATA_house_2024-10-11'), false);
      // The non-matching key remains
      expect(remainingKeys.contains('OTHER_KEY'), true);
    });
  });
}
