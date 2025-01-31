import 'package:energy_monitor_app_flutter/features/home/domain/entities/monitoring_entity.dart';
import 'package:energy_monitor_app_flutter/features/home/domain/enums/metric_type.dart';
import 'package:energy_monitor_app_flutter/features/home/domain/enums/unit_type.dart';
import 'package:energy_monitor_app_flutter/features/home/presentation/bloc/home_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state.status == HomeStateStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              Switch(
                value: state.unitType == UnitType.watts,
                onChanged: (value) {
                  if (value) {
                    context
                        .read<HomeBloc>()
                        .add(UnitTypeChangedEvent(UnitType.watts));
                  } else {
                    context
                        .read<HomeBloc>()
                        .add(UnitTypeChangedEvent(UnitType.kilowatts));
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  state.unitType == UnitType.kilowatts ? 'kW' : 'W',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
            title: Text(
                'Date: ${state.date.toLocal().toString().split(" ").first}'),
          ),
          body: _buildBody(context, state),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: state.metricType.index,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.wb_sunny),
                label: 'Solar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'House',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.battery_full),
                label: 'Battery',
              ),
            ],
            onTap: (index) {
              MetricType newMetric;
              switch (index) {
                case 0:
                  newMetric = MetricType.solar;
                  break;
                case 1:
                  newMetric = MetricType.house;
                  break;
                case 2:
                  newMetric = MetricType.battery;
                  break;
                default:
                  newMetric = MetricType.solar;
              }
              context.read<HomeBloc>().add(MetricChangedEvent(newMetric));
            },
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.calendar_today),
            onPressed: () => _pickDate(context),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    switch (state.metricType) {
      case MetricType.solar:
        return _buildChart(
          state.solarData,
          'Solar Data',
          isShowingKw: state.unitType == UnitType.kilowatts,
        );
      case MetricType.house:
        return _buildChart(
          state.houseData,
          'House Data',
          isShowingKw: state.unitType == UnitType.kilowatts,
        );
      case MetricType.battery:
        return _buildChart(
          state.batteryData,
          'Battery Data',
          isShowingKw: state.unitType == UnitType.kilowatts,
        );
    }
  }

  /// Build a line chart using fl_chart
  Widget _buildChart(List<MonitoringEntity> data, String title,
      {bool isShowingKw = true}) {
    if (data.isEmpty) {
      return Center(child: Text('No data for $title'));
    }

    final spots = data.asMap().entries.map((entry) {
      final index = entry.key;
      final entity = entry.value;
      final double convertedValue = isShowingKw
          ? entity.watts / 1000 // Convert Watts -> Kilowatts
          : entity.watts.toDouble();

      return FlSpot(index.toDouble(), convertedValue);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          titlesData: FlTitlesData(
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (spots.length / 5).floorToDouble(),
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= data.length) {
                    return const SizedBox.shrink();
                  }
                  final date = data[i].dateTime;
                  return Text(
                    '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blueAccent,
              barWidth: 2,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final initialDate = context.read<HomeBloc>().state.date;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      context.read<HomeBloc>().add(DateTimeChangedEvent(picked));
    }
  }
}
