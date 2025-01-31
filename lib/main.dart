import 'package:energy_monitor_app_flutter/app.dart';
import 'package:flutter/material.dart';
import 'dependency_injection/injection.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}
