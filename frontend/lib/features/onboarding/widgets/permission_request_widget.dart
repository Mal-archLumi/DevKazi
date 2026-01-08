// lib/features/onboarding/widgets/permission_request_widget.dart
import 'package:flutter/material.dart';
import 'package:frontend/core/services/notification_permission_service.dart';

class PermissionRequestWidget extends StatefulWidget {
  final VoidCallback onComplete;
  final bool showSkip;

  const PermissionRequestWidget({
    super.key,
    required this.onComplete,
    this.showSkip = true,
  });

  @override
  State<PermissionRequestWidget> createState() =>
      _PermissionRequestWidgetState();
}

class _PermissionRequestWidgetState extends State<PermissionRequestWidget> {
  final NotificationPermissionService _permissionService =
      NotificationPermissionService();

  bool _isLoading = false;

  Future<void> _requestPermission() async {
    setState(() => _isLoading = true);

    final granted = await _permissionService.requestPermission();

    if (granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification permission granted! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can enable notifications in app settings later'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    setState(() => _isLoading = false);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade200, width: 2),
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                size: 64,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 32),

            // Title
            Text(
              'Stay Updated',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              'Get notified about team activities, messages, project updates, and join requests. Never miss important updates!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 40),

            // Permission buttons
            Column(
              children: [
                // Allow button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _requestPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_active, size: 20),
                              SizedBox(width: 12),
                              Text(
                                'Allow Notifications',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                if (widget.showSkip) ...[
                  const SizedBox(height: 12),
                  // Skip button
                  TextButton(
                    onPressed: widget.onComplete,
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
