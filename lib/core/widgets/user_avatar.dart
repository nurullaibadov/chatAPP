import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double size;
  final bool showOnlineIndicator;
  final bool isOnline;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.photoUrl,
    required this.name,
    this.size = 48,
    this.showOnlineIndicator = false,
    this.isOnline = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: photoUrl == null || photoUrl!.isEmpty
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getAvatarColor(name),
                        _getAvatarColor(name).withAlpha(180),
                      ],
                    )
                  : null,
            ),
            child: ClipOval(
              child: photoUrl != null && photoUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: photoUrl!,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildInitials(),
                      errorWidget: (context, url, error) => _buildInitials(),
                    )
                  : _buildInitials(),
            ),
          ),
          if (showOnlineIndicator)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.online : AppColors.offline,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInitials() {
    final initials = _getInitials(name);
    return Container(
      width: size,
      height: size,
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFF00D4AA),
      const Color(0xFFFF6584),
      const Color(0xFFFFA947),
      const Color(0xFF4FACFE),
      const Color(0xFF43E97B),
      const Color(0xFFFA709A),
      const Color(0xFF667EEA),
    ];
    final index = name.isEmpty ? 0 : name.codeUnitAt(0) % colors.length;
    return colors[index];
  }
}
