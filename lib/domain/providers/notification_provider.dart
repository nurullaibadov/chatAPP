import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/notification_service.dart';
import 'auth_provider.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final notificationInitializerProvider = FutureProvider<void>((ref) async {
  final notificationService = ref.watch(notificationServiceProvider);
  final userRepo = ref.watch(userRepositoryProvider);
  final currentUserState = ref.watch(currentUserModelProvider);
  final currentUser = currentUserState.asData?.value;

  if (currentUser != null) {
    await notificationService.initialize(
      onTokenRefresh: (token) async {
        await userRepo.updateFcmToken(currentUser.uid, token);
      },
      onNotificationClick: (data) {
        // Handle notification routing if payload contains chatId
      },
    );
  }
});
