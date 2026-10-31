import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Bottom navigation 3 tab: Beranda, Jelajah, Acara Saya.
/// Widget ini "bodoh": hanya menampilkan dan melaporkan tab yang ditekan.
/// Perpindahan halaman diatur oleh induknya.
class CustomBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.secondary.withAlpha(40),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home, color: AppColors.primary),
          label: 'Beranda',
        ),
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore, color: AppColors.primary),
          label: 'Jelajah',
        ),
        NavigationDestination(
          icon: Icon(Icons.confirmation_number_outlined),
          selectedIcon:
              Icon(Icons.confirmation_number, color: AppColors.primary),
          label: 'Acara Saya',
        ),
      ],
    );
  }
}