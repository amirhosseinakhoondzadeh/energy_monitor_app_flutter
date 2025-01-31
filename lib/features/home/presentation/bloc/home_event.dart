part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class FetchAllMetricsEvent extends HomeEvent {
  const FetchAllMetricsEvent();
}

/// Fetch data for a specific [date] and [metric].
/// The BLoC calls the repository, which returns either a list of MonitoringEntity or a Failure.
class FetchMetricDataEvent extends HomeEvent {
  const FetchMetricDataEvent();
}

/// Clear all locally cached data.
class ClearCacheEvent extends HomeEvent {
  const ClearCacheEvent();
}

class MetricChangedEvent extends HomeEvent {
  final MetricType metricType;

  const MetricChangedEvent(this.metricType);

  @override
  List<Object> get props => [metricType];
}

class DateTimeChangedEvent extends HomeEvent {
  final DateTime dateTime;

  const DateTimeChangedEvent(this.dateTime);

  @override
  List<Object> get props => [dateTime];
}

class UnitTypeChangedEvent extends HomeEvent {
  final UnitType unitType;

  const UnitTypeChangedEvent(this.unitType);

  @override
  List<Object> get props => [unitType];
}
