import 'package:dartz/dartz.dart';
import 'package:energy_monitor_app_flutter/core/error/exceptions.dart';
import 'package:energy_monitor_app_flutter/core/error/failures.dart';
import 'package:energy_monitor_app_flutter/features/home/domain/enums/metric_type.dart';
import 'package:energy_monitor_app_flutter/features/home/domain/repositories/home_repository.dart';
import 'package:energy_monitor_app_flutter/features/home/domain/entities/monitoring_entity.dart';

import 'package:energy_monitor_app_flutter/features/home/data/datasources/home_local_datasource.dart';
import 'package:energy_monitor_app_flutter/features/home/data/datasources/home_remote_datasource.dart';

import 'package:intl/intl.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDatasource localDataSource;
  final HomeRemoteDatasource remoteDataSource;

  HomeRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<MonitoringEntity>>> getMonitoringData({
    required DateTime date,
    required MetricType metric,
  }) async {
    try {
      final formate = DateFormat.yMd();
      final dateString = formate.format(date);

      // Check cached data
      final localData = await localDataSource.getMonitoringData(
        date: dateString,
        metric: metric.name,
      );

      if (localData != null && localData.isNotEmpty) {
        // Convert each MonitoringModel -> MonitoringEntity
        return right(localData.map((model) => model.toEntity()).toList());
      }

      // Otherwise, fetch from remote
      final remoteData = await remoteDataSource.getMetricData(
        date: dateString,
        metric: metric.name,
      );

      // Cache local
      await localDataSource.cacheMonitoringData(
        date: dateString,
        metric: metric.name,
        data: remoteData,
      );

      // Convert to entity
      return right(remoteData.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return left(ServerFailure(e.message ?? "Something went wrong."));
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      return right(await localDataSource.clearCache());
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }
}
