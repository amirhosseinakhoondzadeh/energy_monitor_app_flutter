import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:energy_monitor_app_flutter/core/error/failures.dart';
import 'package:energy_monitor_app_flutter/features/home/domain/entities/monitoring_entity.dart';
import 'package:energy_monitor_app_flutter/features/home/domain/enums/metric_type.dart';
import 'package:energy_monitor_app_flutter/features/home/domain/repositories/home_repository.dart';
import 'package:energy_monitor_app_flutter/features/home/presentation/bloc/home_bloc.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([HomeRepository])
import 'home_bloc_test.mocks.dart';

void main() {
  late MockHomeRepository mockRepository;
  late HomeBloc bloc;

  setUp(() {
    mockRepository = MockHomeRepository();
    bloc = HomeBloc(mockRepository);
  });

  final testEntityA =
      MonitoringEntity(dateTime: DateTime(2025, 10, 11), watts: 1000);
  final testEntityB =
      MonitoringEntity(dateTime: DateTime(2025, 10, 11, 0, 5), watts: 2000);
  final dataList = [testEntityA, testEntityB];
  final errorMsg = 'Some failure message';

  group('initial state', () {
    test('should have default date ~ now, status=initial, empty arrays', () {
      final s = bloc.state;
      expect(s.status, HomeStateStatus.loading);
      expect(s.solarData, isEmpty);
      expect(s.houseData, isEmpty);
      expect(s.batteryData, isEmpty);
      // s.date ~ now
      expect(
        s.date.difference(DateTime.now()).inSeconds.abs() < 5,
        isTrue,
        reason: 'HomeState date should be near current time',
      );
    });
  });

  group('FetchAllMetricsEvent', () {
    void mockAllSuccess() {
      when(mockRepository.getMonitoringData(
        date: anyNamed('date'),
        metric: MetricType.solar,
      )).thenAnswer((_) async => Right(dataList));

      when(mockRepository.getMonitoringData(
        date: anyNamed('date'),
        metric: MetricType.house,
      )).thenAnswer((_) async => Right(dataList));

      when(mockRepository.getMonitoringData(
        date: anyNamed('date'),
        metric: MetricType.battery,
      )).thenAnswer((_) async => Right(dataList));
    }

    blocTest<HomeBloc, HomeState>(
      'emits [loading(empty arrays), loaded(full arrays)] on success for all metrics',
      build: () {
        mockAllSuccess();
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchAllMetricsEvent()),
      expect: () => [
        bloc.state.copyWith(
          status: HomeStateStatus.loading,
          solarData: [],
          houseData: [],
          batteryData: [],
        ),
        bloc.state.copyWith(
          status: HomeStateStatus.loaded,
          solarData: dataList,
          houseData: dataList,
          batteryData: dataList,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits [loading(empty arrays), error] if any fetch fails',
      build: () {
        // solar ok, house fails, battery ok
        when(mockRepository.getMonitoringData(
          date: anyNamed('date'),
          metric: MetricType.solar,
        )).thenAnswer((_) async => Right(dataList));
        when(mockRepository.getMonitoringData(
          date: anyNamed('date'),
          metric: MetricType.house,
        )).thenAnswer((_) async => Left(ServerFailure(errorMsg)));
        when(mockRepository.getMonitoringData(
          date: anyNamed('date'),
          metric: MetricType.battery,
        )).thenAnswer((_) async => Right(dataList));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchAllMetricsEvent()),
      expect: () => [
        bloc.state.copyWith(
          status: HomeStateStatus.loading,
          errorMessage: '',
          solarData: [],
          houseData: [],
          batteryData: [],
        ),
        bloc.state.copyWith(
          status: HomeStateStatus.error,
          errorMessage: errorMsg,
        ),
      ],
    );
  });

  group('FetchMetricDataEvent', () {
    blocTest<HomeBloc, HomeState>(
      'if metricType=solar => sets solarData on success',
      build: () {
        when(mockRepository.getMonitoringData(
          date: anyNamed('date'),
          metric: MetricType.solar,
        )).thenAnswer((_) async => Right(dataList));
        return bloc;
      },
      act: (bloc) async {
        bloc.emit(bloc.state.copyWith(metricType: MetricType.solar));
        bloc.add(const FetchMetricDataEvent());
      },
      expect: () => [
        bloc.state.copyWith(
          metricType: MetricType.solar,
          status: HomeStateStatus.loading,
          solarData: [],
          houseData: [],
          batteryData: [],
        ),
        bloc.state.copyWith(
          metricType: MetricType.solar,
          solarData: dataList,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'if metricType=house => sets houseData on success',
      build: () {
        when(mockRepository.getMonitoringData(
          date: anyNamed('date'),
          metric: MetricType.house,
        )).thenAnswer((_) async => Right(dataList));
        return bloc;
      },
      act: (bloc) async {
        bloc.emit(bloc.state.copyWith(metricType: MetricType.house));
        bloc.add(const FetchMetricDataEvent());
      },
      expect: () => [
        bloc.state.copyWith(
          metricType: MetricType.house,
          status: HomeStateStatus.loading,
          solarData: [],
          houseData: [],
          batteryData: [],
        ),
        bloc.state.copyWith(
          metricType: MetricType.house,
          houseData: dataList,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'if metricType=battery => sets batteryData on success',
      build: () {
        when(mockRepository.getMonitoringData(
          date: anyNamed('date'),
          metric: MetricType.battery,
        )).thenAnswer((_) async => Right(dataList));
        return bloc;
      },
      act: (bloc) async {
        bloc.emit(bloc.state.copyWith(metricType: MetricType.battery));
        bloc.add(const FetchMetricDataEvent());
      },
      expect: () => [
        bloc.state.copyWith(
          metricType: MetricType.battery,
          status: HomeStateStatus.loading,
          solarData: [],
          houseData: [],
          batteryData: [],
        ),
        bloc.state.copyWith(
          metricType: MetricType.battery,
          batteryData: dataList,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits [loading(empty), error] if getMonitoringData fails',
      build: () {
        when(mockRepository.getMonitoringData(
          date: anyNamed('date'),
          metric: anyNamed('metric'),
        )).thenAnswer((_) async => Left(CacheFailure(errorMsg)));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchMetricDataEvent()),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.status, 'status', HomeStateStatus.loading),
        bloc.state.copyWith(
          status: HomeStateStatus.error,
          errorMessage: errorMsg,
        ),
      ],
    );
  });

  group('ClearCacheEvent', () {
    blocTest<HomeBloc, HomeState>(
      'success => [loading(empty), new HomeState()]',
      build: () {
        when(mockRepository.clearCache())
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const ClearCacheEvent()),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.status, 'status', HomeStateStatus.loading),
        bloc.state.copyWith(status: HomeStateStatus.loaded, errorMessage: ''),
      ],
      verify: (_) {
        verify(mockRepository.clearCache()).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'failure => [loading(empty), error]',
      build: () {
        when(mockRepository.clearCache())
            .thenAnswer((_) async => Left(CacheFailure(errorMsg)));
        return bloc;
      },
      act: (bloc) => bloc.add(const ClearCacheEvent()),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.status, 'status', HomeStateStatus.loading),
        bloc.state.copyWith(
          status: HomeStateStatus.error,
          errorMessage: errorMsg,
        ),
      ],
    );
  });
}
