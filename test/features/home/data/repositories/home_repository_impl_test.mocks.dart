// Mocks generated by Mockito 5.4.5 from annotations
// in energy_monitor_app_flutter/test/features/home/data/repositories/home_repository_impl_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:energy_monitor_app_flutter/features/home/data/datasources/home_local_datasource.dart'
    as _i2;
import 'package:energy_monitor_app_flutter/features/home/data/datasources/home_remote_datasource.dart'
    as _i5;
import 'package:energy_monitor_app_flutter/features/home/data/models/monitoring_model.dart'
    as _i4;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [HomeLocalDatasource].
///
/// See the documentation for Mockito's code generation for more information.
class MockHomeLocalDatasource extends _i1.Mock
    implements _i2.HomeLocalDatasource {
  MockHomeLocalDatasource() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<List<_i4.MonitoringModel>?> getMonitoringData({
    required String? date,
    required String? metric,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#getMonitoringData, [], {
              #date: date,
              #metric: metric,
            }),
            returnValue: _i3.Future<List<_i4.MonitoringModel>?>.value(),
          )
          as _i3.Future<List<_i4.MonitoringModel>?>);

  @override
  _i3.Future<void> cacheMonitoringData({
    required String? date,
    required String? metric,
    required List<_i4.MonitoringModel>? data,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#cacheMonitoringData, [], {
              #date: date,
              #metric: metric,
              #data: data,
            }),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> clearCache() =>
      (super.noSuchMethod(
            Invocation.method(#clearCache, []),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);
}

/// A class which mocks [HomeRemoteDatasource].
///
/// See the documentation for Mockito's code generation for more information.
class MockHomeRemoteDatasource extends _i1.Mock
    implements _i5.HomeRemoteDatasource {
  MockHomeRemoteDatasource() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<List<_i4.MonitoringModel>> getMetricData({
    required String? date,
    required String? metric,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#getMetricData, [], {
              #date: date,
              #metric: metric,
            }),
            returnValue: _i3.Future<List<_i4.MonitoringModel>>.value(
              <_i4.MonitoringModel>[],
            ),
          )
          as _i3.Future<List<_i4.MonitoringModel>>);
}
