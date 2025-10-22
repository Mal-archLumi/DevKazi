import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/shared/app_bar/custom_app_bar.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Notifications'),
      body: const Center(child: Text('Notifications will appear here')),
    );
  }
}
