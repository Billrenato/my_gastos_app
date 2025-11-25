import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_gastos_app/app.dart';
import 'package:my_gastos_app/services/hive_service.dart';
import 'package:my_gastos_app/services/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar timezone data
  tz.initializeTimeZones();
  try {
    final String localName = DateTime.now().timeZoneName;
    tz.setLocalLocation(tz.getLocation(localName));
  } catch (_) {
    tz.setLocalLocation(tz.getLocation('UTC'));
  }

  await HiveService.initHive();
  await NotificationService().init();

  runApp(const ProviderScope(child: MyApp()));
}