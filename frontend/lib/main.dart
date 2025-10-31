import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/core/injection_container.dart';

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

  runApp(const DevKaziApp());
}
