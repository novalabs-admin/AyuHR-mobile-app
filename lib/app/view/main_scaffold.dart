import 'package:erp_hr/core/utils/constants.dart';
import 'package:erp_hr/features/login/presentation/blocs/auth_cubit.dart';
import 'package:erp_hr/features/login/presentation/blocs/auth_state.dart';
import 'package:erp_hr/shared/widget/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({
    required this.navigationShell,
    super.key,
  });

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: mainScaffoldKey,
      extendBody: true,
      drawer: const AppDrawer(),
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  index: 0,
                  label: 'Home',
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  currentIndex: navigationShell.currentIndex,
                  onTap: () => _onTabTapped(context, 0),
                ),
                _buildNavItem(
                  context: context,
                  index: 1,
                  label: 'Attendance',
                  icon: Icons.calendar_month_outlined,
                  activeIcon: Icons.calendar_month,
                  currentIndex: navigationShell.currentIndex,
                  onTap: () => _onTabTapped(context, 1),
                ),
                _buildNavItem(
                  context: context,
                  index: 2,
                  label: 'Leave',
                  icon: Icons.description_outlined,
                  activeIcon: Icons.description,
                  currentIndex: navigationShell.currentIndex,
                  onTap: () => _onTabTapped(context, 2),
                ),
                _buildNavItem(
                  context: context,
                  index: 3,
                  label: 'Profile',
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  currentIndex: navigationShell.currentIndex,
                  onTap: () => _onTabTapped(context, 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 6)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFF00632B) : const Color(0xFF94A3B8),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF00632B) : const Color(0xFF64748B),
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onTabTapped(BuildContext context, int index) async {
    if (index == navigationShell.currentIndex) {
      navigationShell.goBranch(
        index,
        initialLocation: true,
      );
      return;
    }

    if (!context.mounted) return;
    _triggerRefresh(context, index);

    navigationShell.goBranch(
      index,
      initialLocation: true,
    );
  }

  void _triggerRefresh(BuildContext context, int index) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated || authState.userProfile == null) return;
  }
}
