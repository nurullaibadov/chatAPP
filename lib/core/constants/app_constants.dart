class AppConstants {
  AppConstants._();

  static const String appName = 'ChatApp';
  static const String defaultAvatar =
      'https://ui-avatars.com/api/?background=6C63FF&color=fff&size=128&name=';

  // Animation durations
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 350);
  static const Duration longDuration = Duration(milliseconds: 500);

  // Message types
  static const String messageTypeText = 'text';
  static const String messageTypeImage = 'image';
  static const String messageTypeAudio = 'audio';
  static const String messageTypeSystem = 'system';

  // Message status
  static const String statusSent = 'sent';
  static const String statusDelivered = 'delivered';
  static const String statusRead = 'read';

  // Pagination
  static const int messagesPerPage = 30;
  static const int chatsPerPage = 20;
  static const int usersPerPage = 20;

  // Storage paths
  static const String profileImagesPath = 'profile_images';
  static const String chatImagesPath = 'chat_images';
  static const String chatAudioPath = 'chat_audio';
  static const String groupImagesPath = 'group_images';

  // Local storage keys
  static const String themeKey = 'app_theme';
  static const String notificationsKey = 'notifications_enabled';
  static const String soundKey = 'sound_enabled';
  static const String vibrationKey = 'vibration_enabled';
}
