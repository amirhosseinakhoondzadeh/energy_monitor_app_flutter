import 'package:energy_monitor_app_flutter/core/error/exceptions.dart';
import 'package:energy_monitor_app_flutter/core/error/failures.dart';
import 'package:energy_monitor_app_flutter/features/home/data/datasources/home_local_datasource.dart';
import 'package:energy_monitor_app_flutter/features/home/data/datasources/home_remote_datasource.dart';
import 'package:energy_monitor_app_flutter/features/home/data/models/monitoring_model.dart';
import 'package:energy_monitor_app_flutter/features/home/data/repositories/home_repository_impl.dart';

import 'package:energy_monitor_app_flutter/features/home/domain/enums/metric_type.dart';
import 'package:energy_monitor_app_flutter/features/home/domain/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_repository_impl_test.mocks.dart';

@GenerateMocks([HomeLocalDatasource, HomeRemoteDatasource])
void main() {
  late MockHomeLocalDatasource mockLocalDataSource;
  late MockHomeRemoteDatasource mockRemoteDataSource;
  late HomeRepository repository;

  setUp(() {
    mockLocalDataSource = MockHomeLocalDatasource();
    mockRemoteDataSource = MockHomeRemoteDatasource();

    repository = HomeRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
    );
  });

  final testDate = DateTime(2025, 10, 11);
  final dateString = DateFormat('yyyy-MM-DD').format(testDate);
  const testMetric = MetricType.solar;

  // Some fake data
  final testMonitoringModels = [
    MonitoringModel(
        timestamp: DateTime.parse('2025-10-11T00:00:00Z'), value: 1000),
    MonitoringModel(
        timestamp: DateTime.parse('2025-10-11T00:05:00Z'), value: 2000),
  ];
  final testEntities = testMonitoringModels.map((m) => m.toEntity()).toList();

  group('getMonitoringData', () {
    test('should return Right(local data) if localData is non-empty', () async {
      // arrange
      when(mockLocalDataSource.getMonitoringData(
        date: anyNamed('date'),
        metric: anyNamed('metric'),
      )).thenAnswer((_) async => testMonitoringModels);

      // act
      final result = await repository.getMonitoringData(
        date: testDate,
        metric: testMetric,
      );

      // assert
      // The local data source is called
      verify(mockLocalDataSource.getMonitoringData(
        date: dateString,
        metric: testMetric.name,
      )).called(1);

      // The remote data source is NOT called
      verifyNever(mockRemoteDataSource.getMetricData(
        date: anyNamed('date'),
        metric: anyNamed('metric'),
      ));

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected a Right but got $failure'),
        (entities) => expect(entities, equals(testEntities)),
      );
    });

    test(
        'should fetch from remote, cache, and return Right(remote data) if local is empty',
        () async {
      // arrange
      when(mockLocalDataSource.getMonitoringData(
        date: anyNamed('date'),
        metric: anyNamed('metric'),
      )).thenAnswer((_) async => []); // empty list or null triggers remote

      when(mockRemoteDataSource.getMetricData(
        date: anyNamed('date'),
        metric: anyNamed('metric'),
      )).thenAnswer((_) async => testMonitoringModels);

      // act
      final result = await repository.getMonitoringData(
        date: testDate,
        metric: testMetric,
      );

      // assert
      // Local was called
      verify(mockLocalDataSource.getMonitoringData(
        date: dateString,
        metric: testMetric.name,
      )).called(1);

      // Remote is called
      verify(mockRemoteDataSource.getMetricData(
        date: dateString,
        metric: testMetric.name,
      )).called(1);

      // Data is cached
      verify(mockLocalDataSource.cacheMonitoringData(
        date: dateString,
        metric: testMetric.name,
        data: testMonitoringModels,
      )).called(1);

      // Returned result

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected a Right but got $failure'),
        (entities) => expect(entities, equals(testEntities)),
      );
    });

    test(
        'should fetch from remote if local is null, then return Right(remote data)',
        () async {
      // Just to handle the case localData == null
      when(mockLocalDataSource.getMonitoringData(
        date: anyNamed('date'),
        metric: anyNamed('metric'),
      )).thenAnswer((_) async => null);

      when(mockRemoteDataSource.getMetricData(
        date: anyNamed('date'),
        metric: anyNamed('metric'),
      )).thenAnswer((_) async => testMonitoringModels);

      // act
      final result = await repository.getMonitoringData(
        date: testDate,
        metric: testMetric,
      );

      // assert
      verify(mockLocalDataSource.getMonitoringData(
        date: dateString,
        metric: testMetric.name,
      )).called(1);

      verify(mockRemoteDataSource.getMetricData(
        date: dateString,
        metric: testMetric.name,
      )).called(1);

      verify(mockLocalDataSource.cacheMonitoringData(
        date: dateString,
        metric: testMetric.name,
        data: testMonitoringModels,
      )).called(1);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected a Right but got $failure'),
        (entities) => expect(entities, equals(testEntities)),
      );
    });

    test('should return Left(ServerFailure) when remote throws ServerException',
        () async {
      // arrange
      when(mockLocalDataSource.getMonitoringData(
        date: anyNamed('date'),
        metric: anyNamed('metric'),
      )).thenAnswer((_) async => []); // empty so we fetch from remote

      when(mockRemoteDataSource.getMetricData(
        date: anyNamed('date'),
        metric: anyNamed('metric'),
      )).thenThrow(ServerException(message: 'Remote error', code: 500));

      // act
      final result = await repository.getMonitoringData(
        date: testDate,
        metric: testMetric,
      );

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect((failure as ServerFailure).message, 'Remote error');
        },
        (_) => fail('Expected Left(ServerFailure)'),
      );
      verify(mockRemoteDataSource.getMetricData(
        date: dateString,
        metric: testMetric.name,
      )).called(1);
      verifyNever(mockLocalDataSource.cacheMonitoringData(
        date: anyNamed('date'),
        metric: anyNamed('metric'),
        data: anyNamed('data'),
      ));
    });

    test('should return Left(CacheFailure) for any other exception', () async {
      // arrange
      when(mockLocalDataSource.getMonitoringData(
        date: anyNamed('date'),
        metric: anyNamed('metric'),
      )).thenAnswer((_) async => []); // triggers remote
      when(mockRemoteDataSource.getMetricData(
        date: anyNamed('date'),
        metric: anyNamed('metric'),
      )).thenThrow(Exception('some random error'));

      // act
      final result = await repository.getMonitoringData(
        date: testDate,
        metric: testMetric,
      );

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Expected Left(CacheFailure)'),
      );
    });
  });

  group('clearCache', () {
    test('should return Right(void) on success', () async {
      // arrange
      when(mockLocalDataSource.clearCache())
          .thenAnswer((_) async => Future.value());

      // act
      final result = await repository.clearCache();

      // assert
      verify(mockLocalDataSource.clearCache()).called(1);
      expect(result, equals(const Right(null)));
    });

    test('should return Left(CacheFailure) if an exception occurs', () async {
      // arrange
      when(mockLocalDataSource.clearCache())
          .thenThrow(Exception('some cache error'));

      // act
      final result = await repository.clearCache();

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Expected Left(CacheFailure)'),
      );
    });
  });
}
