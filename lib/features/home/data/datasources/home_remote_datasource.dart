import 'dart:convert';

import 'package:energy_monitor_app_flutter/core/error/exceptions.dart';
import 'package:energy_monitor_app_flutter/core/network/api_urls.dart';
import 'package:energy_monitor_app_flutter/features/home/data/models/monitoring_model.dart';
import 'package:http/http.dart' show Client;

abstract class HomeRemoteDatasource {
  Future<List<MonitoringModel>> getMetricData({
    required String date,
    required String metric,
  });
}

class HomeRemoteDatasourceImpl implements HomeRemoteDatasource {
  final Client client;

  HomeRemoteDatasourceImpl({required this.client});

  @override
  Future<List<MonitoringModel>> getMetricData({
    required String date,
    required String metric,
  }) async {
    final uri = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.monitoring}').replace(
      queryParameters: {
        'date': date,
        'type': metric,
      },
    );

    final response = await client.get(uri);

    if (response.statusCode != 200) {
      throw ServerException(
        message:
            'Failed to fetch $metric data: ${response.statusCode} ${response.reasonPhrase}',
        code: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw ServerException(message: 'Server response is not a JSON array.');
    }

    return decoded
        .map<MonitoringModel>((json) => MonitoringModel.fromJson(json))
        .toList();
  }
}
