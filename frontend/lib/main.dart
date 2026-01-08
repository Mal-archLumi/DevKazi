import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/core/injection_container.dart';
import 'package:frontend/core/services/notification_permission_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ Load .env first before initializing dependencies
    await dotenv.load(fileName: '.env');
    print('✅ Environment variables loaded successfully');
  } catch (e) {
    print('⚠️ Error loading .env file: $e');
  }

  // ✅ Now initialize dependencies (depends on .env)
  await initDependencies();
  // Initialize notification service
  await NotificationPermissionService().initialize();

  runApp(const DevKaziApp());
}
