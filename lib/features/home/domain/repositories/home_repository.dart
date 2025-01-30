import 'package:dartz/dartz.dart';
import 'package:energy_monitor_app_flutter/core/error/failures.dart';
import 'package:energy_monitor_app_flutter/features/home/domain/entities/monitoring_entity.dart';
import 'package:energy_monitor_app_flutter/features/home/domain/enums/metric_type.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<MonitoringEntity>>> getMonitoringData({
    required DateTime date,
    required MetricType metric,
  });

  Future<Either<Failure, void>> clearCache();
}
