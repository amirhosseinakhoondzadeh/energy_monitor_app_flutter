import 'package:energy_monitor_app_flutter/features/home/data/datasources/home_remote_datasource.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  //Data sources
  getIt.registerLazySingleton<HomeRemoteDatasource>(
      () => HomeRemoteDatasourceImpl(client: getIt()));

  // External
  getIt.registerLazySingleton(() => http.Client());

  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
}
