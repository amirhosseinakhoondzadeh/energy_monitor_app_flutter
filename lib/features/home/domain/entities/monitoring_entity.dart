import 'package:equatable/equatable.dart';

class MonitoringEntity extends Equatable {
  final DateTime dateTime;
  final int watts;

  const MonitoringEntity({
    required this.dateTime,
    required this.watts,
  });

  @override
  List<Object?> get props => [dateTime, watts];
}
