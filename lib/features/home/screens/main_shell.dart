import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment/core/widgets/bottom_nav_bar.dart';
import 'package:assignment/core/theme/theme_provider.dart';
import 'package:assignment/features/bmi/screens/bmi_dashboard_screen.dart';
import 'package:assignment/features/profile/screens/profile_switcher_screen.dart';
import 'package:assignment/features/history/screens/weight_history_screen.dart';
import 'package:assignment/features/settings/screens/settings_screen.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider); // force shell rebuild on theme changes
    final activeIndex = ref.watch(bottomNavIndexProvider);

    final List<Widget> screens = [
      BmiDashboardScreen(),
      WeightHistoryScreen(),
      ProfileSwitcherScreen(),
      SettingsScreen(),
    ];

    return SafeArea(
      child: Scaffold(
        body: IndexedStack(
          index: activeIndex,
          children: screens,
        ),
        bottomNavigationBar:  CustomBottomNavBar(),
      ),
    );
  }
}
