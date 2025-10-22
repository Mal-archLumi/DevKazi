import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load .env file with error handling
    await dotenv.load(fileName: '.env');
    print('Environment variables loaded successfully');
  } catch (e) {
    print('Error loading .env file: $e');
    // Continue without .env file - your app should handle missing env vars
  }

  runApp(const DevKaziApp());
}
