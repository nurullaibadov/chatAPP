import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/providers/auth_provider.dart';
import '../auth/forgot_password_screen.dart';
import '../auth/login_screen.dart';
import '../auth/profile_setup_screen.dart';
import '../auth/register_screen.dart';
import '../chat/chat_screen.dart';
import '../contacts/new_group_screen.dart';
import '../contacts/user_search_screen.dart';
import '../home/chat_list_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String profileSetup = '/profile-setup';
  static const String home = '/';
  static const String chat = '/chat/:chatId';
  static const String userSearch = '/search';
  static const String newGroup = '/new-group';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (BuildContext context, GoRouterState state) {
      final user = authState.asData?.value;
      final isLoggingIn = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword;

      if (user == null && !isLoggingIn) {
        return AppRoutes.login;
      }

      if (user != null && isLoggingIn) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) {
          final chatId = state.pathParameters['chatId'] ?? '';
          final extra = state.extra as Map<String, dynamic>?;
          return ChatScreen(
            chatId: chatId,
            otherUserName: extra?['title'],
            otherUserPhoto: extra?['photo'],
            isGroup: extra?['isGroup'] ?? false,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.userSearch,
        builder: (context, state) => const UserSearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.newGroup,
        builder: (context, state) => const NewGroupScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
