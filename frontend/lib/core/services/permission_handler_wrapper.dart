// lib/core/services/permission_handler_wrapper.dart
import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerWrapper {
  // Check if we should request permission (only if not granted and not permanently denied)
  Future<bool> shouldRequestNotificationPermission() async {
    final status = await Permission.notification.status;

    // Don't ask if already granted or permanently denied
    if (status.isGranted || status.isPermanentlyDenied) {
      return false;
    }

    // Only ask if denied (not permanently) or not determined
    return status.isDenied || status.isRestricted;
  }

  // Open app settings for manual permission enabling
  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
