import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:energy_monitor_app_flutter/core/error/failures.dart';
import 'package:energy_monitor_app_flutter/features/home/domain/entities/monitoring_entity.dart';
import 'package:energy_monitor_app_flutter/features/home/domain/enums/metric_type.dart';
import 'package:energy_monitor_app_flutter/features/home/domain/enums/unit_type.dart';
import 'package:energy_monitor_app_flutter/features/home/domain/repositories/home_repository.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repository;

  HomeBloc(this.repository) : super(HomeState()) {
    on<FetchAllMetricsEvent>(_onFetchAllMetrics);
    on<FetchMetricDataEvent>(_onFetchMetricData);
    on<ClearCacheEvent>(_onClearCache);
    on<DateTimeChangedEvent>(_onDateTimeChanged);
    on<MetricChangedEvent>(_onMetricChanged);
    on<UnitTypeChangedEvent>(_onUnitTypeChanged);
  }

  /// Handles preloading all metrics (solar, house, battery) for the given date.
  Future<void> _onFetchAllMetrics(
    FetchAllMetricsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStateStatus.loading));

    // We do three separate calls to the repository:
    final eitherSolar = await repository.getMonitoringData(
      date: state.date,
      metric: MetricType.solar,
    );
    final eitherHouse = await repository.getMonitoringData(
      date: state.date,
      metric: MetricType.house,
    );
    final eitherBattery = await repository.getMonitoringData(
      date: state.date,
      metric: MetricType.battery,
    );

    // If any result is a Left (failure), we emit HomeError immediately.
    // Otherwise, we combine them into a single loaded state.
    if (_anyLeft([eitherSolar, eitherHouse, eitherBattery])) {
      // Find the first failure to show an error message
      final firstFailure =
          _getFirstFailure([eitherSolar, eitherHouse, eitherBattery]);
      final message = _mapFailureToMessage(firstFailure);
      emit(state.copyWith(
        status: HomeStateStatus.error,
        errorMessage: message,
      ));
      return;
    }

    // All are Right => Extract data
    final solarData = eitherSolar.getOrElse(() => []);
    final houseData = eitherHouse.getOrElse(() => []);
    final batteryData = eitherBattery.getOrElse(() => []);

    // Emit loaded with all three metrics
    emit(state.copyWith(
      status: HomeStateStatus.loaded,
      solarData: solarData,
      houseData: houseData,
      batteryData: batteryData,
    ));
  }

  Future<void> _onFetchMetricData(
    FetchMetricDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStateStatus.loading));

    final result = await repository.getMonitoringData(
      date: state.date,
      metric: state.metricType,
    );

    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        emit(state.copyWith(
          status: HomeStateStatus.error,
          errorMessage: message,
        ));
      },
      (entities) {
        switch (state.metricType) {
          case MetricType.battery:
            emit(state.copyWith(batteryData: entities));
            break;
          case MetricType.house:
            emit(state.copyWith(houseData: entities));
            break;
          case MetricType.solar:
            emit(state.copyWith(solarData: entities));
            break;
        }
      },
    );
  }

  Future<void> _onClearCache(
    ClearCacheEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStateStatus.loading));
    final result = await repository.clearCache();
    result.fold(
      (failure) => emit(state.copyWith(
        status: HomeStateStatus.error,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (_) => emit(state.copyWith(
        status: HomeStateStatus.loaded,
        errorMessage: '',
      )),
    );
  }

  FutureOr<void> _onDateTimeChanged(
    DateTimeChangedEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(date: event.dateTime));
    add(FetchMetricDataEvent());
  }

  FutureOr<void> _onMetricChanged(
      MetricChangedEvent event, Emitter<HomeState> emit) {
    emit(state.copyWith(metricType: event.metricType));
    add(FetchMetricDataEvent());
  }

  FutureOr<void> _onUnitTypeChanged(
    UnitTypeChangedEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(unitType: event.unitType));
  }

  bool _anyLeft(List<Either<Failure, List<MonitoringEntity>>> results) {
    return results.any((either) => either.isLeft());
  }

  Failure _getFirstFailure(
      List<Either<Failure, List<MonitoringEntity>>> results) {
    for (final either in results) {
      if (either.isLeft()) {
        return either.swap().getOrElse(() => CacheFailure('Unknown'));
      }
    }
    // Should never happen if called only when there's a Left
    return CacheFailure('Unknown error');
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is CacheFailure) {
      return failure.message;
    }
    return 'Unexpected error occurred.';
  }
}
