import 'dart:convert';

import 'package:energy_monitor_app_flutter/core/error/exceptions.dart';
import 'package:energy_monitor_app_flutter/core/network/api_urls.dart';
import 'package:energy_monitor_app_flutter/features/home/data/datasources/home_remote_datasource.dart';
import 'package:energy_monitor_app_flutter/features/home/data/models/monitoring_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'home_remote_datasource_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;
  late HomeRemoteDatasourceImpl dataSource;

  setUp(() {
    mockClient = MockClient();
    dataSource = HomeRemoteDatasourceImpl(client: mockClient);
  });

  group('getMetricData', () {
    const tDate = '2024-10-11';
    const tMetric = 'solar';
    final tUri = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.monitoring}')
        .replace(queryParameters: {'date': tDate, 'type': tMetric});

    test(
        'should return a List<MonitoringModel> when the response is 200 and body is a JSON array',
        () async {
      // arrange
      final jsonResponse = [
        {
          "timestamp": "2024-10-11T00:00:00.000Z",
          "value": 2462,
        },
        {
          "timestamp": "2024-10-11T00:05:00.000Z",
          "value": 8152,
        }
      ];

      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response(
          jsonEncode(jsonResponse),
          200,
        ),
      );

      // act
      final result =
          await dataSource.getMetricData(date: tDate, metric: tMetric);

      // assert
      verify(mockClient.get(tUri)).called(1);
      expect(result, isA<List<MonitoringModel>>());
      expect(result.length, 2);
      expect(result[0].timestamp, DateTime.parse("2024-10-11T00:00:00.000Z"));
      expect(result[0].value, 2462);
      expect(result[1].value, 8152);
    });

    test(
        'should return an empty List<MonitoringModel> if the response is an empty array',
        () async {
      // arrange
      when(mockClient.get(tUri))
          .thenAnswer((_) async => http.Response(jsonEncode([]), 200));

      // act
      final result =
          await dataSource.getMetricData(date: tDate, metric: tMetric);

      // assert
      verify(mockClient.get(tUri)).called(1);
      expect(result, isA<List<MonitoringModel>>());
      expect(result, isEmpty);
    });

    test('should throw a ServerException when the response code is not 200',
        () async {
      // arrange
      when(mockClient.get(tUri))
          .thenAnswer((_) async => http.Response('Something went wrong', 404));

      // act
      final call = dataSource.getMetricData;

      // assert
      expect(
        () => call(date: tDate, metric: tMetric),
        throwsA(isA<ServerException>()),
      );
      verify(mockClient.get(tUri)).called(1);
    });

    test(
        'should throw a ServerException when the response is 200 but not a JSON list',
        () async {
      // arrange
      // e.g. server returns an object instead of an array
      when(mockClient.get(tUri)).thenAnswer(
          (_) async => http.Response(jsonEncode({"foo": "bar"}), 200));

      // act
      final call = dataSource.getMetricData;

      // assert
      expect(
        () => call(date: tDate, metric: tMetric),
        throwsA(isA<ServerException>()),
      );
      verify(mockClient.get(tUri)).called(1);
    });
  });
}
