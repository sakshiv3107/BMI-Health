import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:assignment/core/theme/app_colors.dart';

/// Displays a circular avatar.
/// If [photoBase64] is non-null/non-empty it shows the decoded image,
/// otherwise falls back to a coloured circle with the first letter of [name].
class ProfileAvatar extends StatelessWidget {
  final String name;
  final String? photoBase64;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.name,
    this.photoBase64,
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context) {
    if (photoBase64 != null && photoBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(photoBase64!);
        return CircleAvatar(
          radius: radius,
          backgroundImage: MemoryImage(bytes),
          backgroundColor: AppColors.primaryLight,
        );
      } catch (_) {
        // Fall through to initials avatar on decode error
      }
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryLight,
      child: Text(
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: radius * 0.85,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
