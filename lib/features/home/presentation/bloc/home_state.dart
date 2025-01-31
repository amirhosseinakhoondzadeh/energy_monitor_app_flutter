part of 'home_bloc.dart';

enum HomeStateStatus { loading, loaded, error }

class HomeState extends Equatable {
  final HomeStateStatus status;
  final List<MonitoringEntity> solarData;
  final List<MonitoringEntity> houseData;
  final List<MonitoringEntity> batteryData;
  final DateTime date;
  final MetricType metricType;
  final String errorMessage;
  final UnitType unitType;

  HomeState({
    this.status = HomeStateStatus.loading,
    this.solarData = const <MonitoringEntity>[],
    this.batteryData = const <MonitoringEntity>[],
    this.houseData = const <MonitoringEntity>[],
    this.metricType = MetricType.solar,
    this.errorMessage = '',
    this.unitType = UnitType.watts,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  HomeState copyWith({
    HomeStateStatus? status,
    List<MonitoringEntity>? solarData,
    List<MonitoringEntity>? houseData,
    List<MonitoringEntity>? batteryData,
    DateTime? date,
    MetricType? metricType,
    String? errorMessage,
    UnitType? unitType,
  }) {
    return HomeState(
      date: date ?? this.date,
      status: status ?? this.status,
      solarData: solarData ?? this.solarData,
      houseData: houseData ?? this.houseData,
      batteryData: batteryData ?? this.batteryData,
      metricType: metricType ?? this.metricType,
      errorMessage: errorMessage ?? this.errorMessage,
      unitType: unitType ?? this.unitType,
    );
  }

  @override
  List<Object> get props => [
        status,
        solarData,
        batteryData,
        houseData,
        date,
        metricType,
        errorMessage,
        unitType,
      ];
}
