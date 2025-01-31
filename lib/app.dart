import 'package:energy_monitor_app_flutter/dependency_injection/injection.dart';
import 'package:energy_monitor_app_flutter/features/home/presentation/bloc/home_bloc.dart';
import 'package:energy_monitor_app_flutter/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (_) => getIt<HomeBloc>()..add(const FetchAllMetricsEvent()),
        child: const HomePage(),
      ),
    );
  }
}
