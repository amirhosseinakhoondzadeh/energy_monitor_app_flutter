import 'package:energy_monitor_app_flutter/features/home/data/datasources/home_local_datasource.dart';
import 'package:energy_monitor_app_flutter/features/home/data/datasources/home_remote_datasource.dart';
import 'package:energy_monitor_app_flutter/features/home/data/repositories/home_repository_impl.dart';
import 'package:energy_monitor_app_flutter/features/home/domain/repositories/home_repository.dart';
import 'package:energy_monitor_app_flutter/features/home/presentation/bloc/home_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  //Bloc
  getIt.registerFactory(
    () => HomeBloc(getIt()),
  );

  //Repositories
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );

  //Data sources
  getIt.registerLazySingleton<HomeRemoteDatasource>(
      () => HomeRemoteDatasourceImpl(client: getIt()));

  getIt.registerLazySingleton<HomeLocalDatasource>(
      () => HomeLocalDatasourceImpl(sharedPreferences: getIt()));

  // External
  getIt.registerLazySingleton(() => http.Client());

  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
}
