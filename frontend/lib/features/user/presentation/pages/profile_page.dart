import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/shared/app_bar/custom_app_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Profile'),
      body: const Center(child: Text('Profile page content')),
    );
  }
}
