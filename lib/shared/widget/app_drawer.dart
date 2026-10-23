import 'package:erp_hr/core/utils/spacing.dart';
import 'package:erp_hr/features/login/presentation/blocs/auth_cubit.dart';
import 'package:erp_hr/features/login/presentation/blocs/auth_state.dart';
import 'package:erp_hr/features/login/presentation/blocs/logout_cubit.dart';
import 'package:erp_hr/features/login/presentation/blocs/logout_state.dart';
import 'package:erp_hr/injector.dart';
import 'package:erp_hr/shared/widget/app_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Future<void> _handleLogout(
    BuildContext context,
    LogoutCubit logoutCubit,
  ) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Log Out',
      message: 'Are you sure you want to log out of your account?',
      confirmLabel: 'Log Out',
      isDestructive: true,
    );

    if (confirmed) {
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      await logoutCubit.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LogoutCubit>(),
      child: BlocConsumer<LogoutCubit, LogoutState>(
        listener: (context, state) {
          if (state.status == LogoutStatus.success) {
            context.go('/');
          }
        },
        builder: (context, logoutState) {
          final logoutCubit = context.read<LogoutCubit>();

          return BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              final userProfile =
                  authState is Authenticated ? authState.userProfile : null;
              final displayName =
                  userProfile?.username ?? 'Dr. Sanduni Perera';

              return Drawer(
                backgroundColor: Colors.white,
                child: Column(
                  children: [
                    // ── 1. Decorative Header with Image & Logo ──
                    _buildDecorativeHeader(context, displayName),

                    // ── 2. Scrollable Navigation Menu ──
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        children: [
                          _buildSectionTitle('MAIN MENU'),
                          Gap.v6,
                          _buildDrawerItem(
                            context: context,
                            title: 'Dashboard',
                            subtitle: 'Overview & daily summary',
                            icon: Icons.space_dashboard_outlined,
                            iconColor: const Color(0xFF045C2C),
                            iconBgColor: const Color(0xFFE8F5E9),
                            onTap: () {
                              Navigator.pop(context);
                              context.go('/dashboard');
                            },
                          ),
                          _buildDrawerItem(
                            context: context,
                            title: 'Attendance',
                            subtitle: 'Clock-in & monthly report',
                            icon: Icons.calendar_month_outlined,
                            iconColor: const Color(0xFF0284C7),
                            iconBgColor: const Color(0xFFE0F2FE),
                            onTap: () {
                              Navigator.pop(context);
                              context.go('/attendance');
                            },
                          ),
                          _buildDrawerItem(
                            context: context,
                            title: 'Leave Management',
                            subtitle: 'Apply & track requests',
                            icon: Icons.description_outlined,
                            iconColor: const Color(0xFFD97706),
                            iconBgColor: const Color(0xFFFEF3C7),
                            onTap: () {
                              Navigator.pop(context);
                              context.go('/leave');
                            },
                          ),
                          _buildDrawerItem(
                            context: context,
                            title: 'My Profile',
                            subtitle: 'Personal & employment info',
                            icon: Icons.person_outline_rounded,
                            iconColor: const Color(0xFF7C3AED),
                            iconBgColor: const Color(0xFFF3E8FF),
                            onTap: () {
                              Navigator.pop(context);
                              context.go('/profile');
                            },
                          ),

                          Gap.v16,
                          _buildSectionTitle('HR SERVICES & TOOLS'),
                          Gap.v6,
                          _buildDrawerItem(
                            context: context,
                            title: 'Duty Roster',
                            subtitle: 'Shifts & schedule',
                            icon: Icons.access_time_rounded,
                            iconColor: const Color(0xFF0D9488),
                            iconBgColor: const Color(0xFFCCFBF1),
                            onTap: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Duty Roster is under development.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            context: context,
                            title: 'Payslips',
                            subtitle: 'Salary statements & tax',
                            icon: Icons.receipt_long_outlined,
                            iconColor: const Color(0xFFE11D48),
                            iconBgColor: const Color(0xFFFFE4E6),
                            onTap: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Payslips are under development.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            context: context,
                            title: 'Settings',
                            subtitle: 'App preferences & security',
                            icon: Icons.settings_outlined,
                            iconColor: const Color(0xFF475569),
                            iconBgColor: const Color(0xFFF1F5F9),
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/settings');
                            },
                          ),
                        ],
                      ),
                    ),

                    // ── 3. Footer with Logout & Version ──
                    _buildFooter(context, logoutState, logoutCubit),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ── Decorative Header Component ──
  Widget _buildDecorativeHeader(BuildContext context, String displayName) {
    return Container(
      width: double.infinity,
      height: 230.h,
      decoration: const BoxDecoration(
        color: Color(0xFF045C2C),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background herbal image
          Image.asset(
            'assets/images/ayu_erp_img.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),

          // Deep gradient overlay ensuring high contrast
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF045C2C).withValues(alpha: 0.82),
                  const Color(0xFF003316).withValues(alpha: 0.96),
                ],
              ),
            ),
          ),

          // Header Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar: Ayu Lanka Logo badge + Close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo-Ayulanka.png',
                          height: 24.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Material(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: EdgeInsets.all(6.r),
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 18.r,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Avatar & Profile information
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.2.r,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 26.r,
                          backgroundColor: const Color(0xFFE8F5E9),
                          child: Icon(
                            Icons.person_rounded,
                            size: 28.r,
                            color: const Color(0xFF045C2C),
                          ),
                        ),
                      ),
                      Gap.h12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Gap.v4,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                'AYU00123 • Medical',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Gap.v4,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Title ──
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, top: 4.h, bottom: 4.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  // ── Drawer Item Tile ──
  Widget _buildDrawerItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20.r,
                  ),
                ),
                Gap.h12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Gap.v2,
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: const Color(0xFFCBD5E1),
                  size: 20.r,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Drawer Footer ──
  Widget _buildFooter(
    BuildContext context,
    LogoutState logoutState,
    LogoutCubit logoutCubit,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF1F5F9)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Log Out action button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: logoutState.status == LogoutStatus.loading
                    ? null
                    : () => _handleLogout(context, logoutCubit),
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (logoutState.status == LogoutStatus.loading) ...[
                        SizedBox(
                          width: 18.r,
                          height: 18.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.r,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      ] else ...[
                        Icon(
                          Icons.logout_rounded,
                          color: const Color(0xFFDC2626),
                          size: 18.r,
                        ),
                        Gap.h8,
                        Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Gap.v10,

            // App branding footer
            Text(
              'Ayu Lanka HR ERP • v1.0.0',
              style: TextStyle(
                fontSize: 11.sp,
                color: const Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
