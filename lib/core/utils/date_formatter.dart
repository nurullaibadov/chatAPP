import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatChatListTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat.jm().format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat.EEEE().format(dateTime);
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  // Alias used by chat_list_screen.dart
  static String formatChatTimestamp(DateTime dateTime) =>
      formatChatListTime(dateTime);

  static String formatMessageTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime);
  }

  static String formatMessageDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat.EEEE().format(dateTime);
    } else {
      return DateFormat('MMMM d, yyyy').format(dateTime);
    }
  }

  static String formatLastSeen(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }

  static String formatAudioDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // Used by profile_screen.dart for "Member Since"
  static String formatFullDate(DateTime dateTime) {
    return DateFormat('MMMM d, yyyy').format(dateTime);
  }
}
