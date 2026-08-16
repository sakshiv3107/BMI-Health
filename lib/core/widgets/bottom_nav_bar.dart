import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment/core/theme/app_colors.dart';
import 'package:assignment/core/theme/theme_provider.dart';

// Provider to manage bottom navigation index
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class CustomBottomNavBar extends ConsumerWidget {
  CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider); // force rebuild on theme changes
    final activeIndex = ref.watch(bottomNavIndexProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border:  Border(
          top: BorderSide(color: AppColors.borderLight, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                ref: ref,
                index: 0,
                activeIcon: Icons.home,
                inactiveIcon: Icons.home_outlined,
                label: 'Home',
                activeIndex: activeIndex,
              ),
              _buildNavItem(
                ref: ref,
                index: 1,
                activeIcon: Icons.history,
                inactiveIcon: Icons.history,
                label: 'History',
                activeIndex: activeIndex,
              ),
              _buildNavItem(
                ref: ref,
                index: 2,
                activeIcon: Icons.people,
                inactiveIcon: Icons.people_outline,
                label: 'Profiles',
                activeIndex: activeIndex,
              ),
              _buildNavItem(
                ref: ref,
                index: 3,
                activeIcon: Icons.settings,
                inactiveIcon: Icons.settings_outlined,
                label: 'Settings',
                activeIndex: activeIndex,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required WidgetRef ref,
    required int index,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
    required int activeIndex,
  }) {
    final isActive = activeIndex == index;
    final color = isActive ? AppColors.navActive : AppColors.navInactive;
    final icon = isActive ? activeIcon : inactiveIcon;

    return InkWell(
      onTap: () {
        ref.read(bottomNavIndexProvider.notifier).state = index;
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryLight : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
