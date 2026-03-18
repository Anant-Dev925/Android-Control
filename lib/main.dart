import 'package:flutter/material.dart';
import 'package:android_control/app.dart';
import 'package:android_control/core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initServiceLocator();

  runApp(const AndroidControlApp());
}
