import 'package:erp_hr/core/utils/constants.dart';
import 'package:erp_hr/core/utils/spacing.dart';
import 'package:erp_hr/features/login/presentation/blocs/logout_cubit.dart';
import 'package:erp_hr/features/login/presentation/blocs/logout_state.dart';
import 'package:erp_hr/injector.dart';
import 'package:erp_hr/shared/widget/app_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
      await logoutCubit.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LogoutCubit>(),
      child: BlocConsumer<LogoutCubit, LogoutState>(
        listener: (context, logoutState) {
          if (logoutState.status == LogoutStatus.success) {
            context.go('/');
          }
        },
        builder: (context, logoutState) {
          final logoutCubit = context.read<LogoutCubit>();

          return Scaffold(
            backgroundColor: const Color(0xFF045C2C),
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // ── Fixed Top Header Bar ──
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 6.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 28.r,
                          ),
                          onPressed: () {
                            mainScaffoldKey.currentState?.openDrawer();
                          },
                        ),
                        Text(
                          'My Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 28.r,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  Gap.v8,

                  // ── White Card Body (Scrollable) ──
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28.r),
                          topRight: Radius.circular(28.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28.r),
                          topRight: Radius.circular(28.r),
                        ),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            24.w,
                            28.h,
                            24.w,
                            110.h,
                          ),
                          child: Column(
                            children: [
                              // ── Circular Avatar ──
                              Container(
                                width: 94.r,
                                height: 94.r,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE5EEE7),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 54.r,
                                  color: const Color(0xFF72937E),
                                ),
                              ),
                              Gap.v12,

                              // ── User Full Name ──
                              Text(
                                'Dr. Sanduni Perera',
                                style: TextStyle(
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                              Gap.v4,

                              // ── Designation ──
                              Text(
                                'Medical Officer',
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Gap.v2,

                              // ── Hospital Name ──
                              Text(
                                'Ayu Lanka Hospital',
                                style: TextStyle(
                                  fontSize: 12.5.sp,
                                  color: const Color(0xFF9CA3AF),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Gap.v24,

                              // ── Employee Key-Value Details ──
                              _buildInfoRow(
                                label: 'Employee ID',
                                value: 'AYU00123',
                              ),
                              Gap.v12,
                              _buildInfoRow(
                                label: 'Department',
                                value: 'Medical',
                              ),
                              Gap.v12,
                              _buildInfoRow(
                                label: 'Joined',
                                value: '15 Jan 2023',
                              ),
                              Gap.v24,

                              // ── Menu List Items ──
                              _buildMenuItem(
                                title: 'Duty Roster',
                                icon: Icons.calendar_month_outlined,
                                onTap: () {},
                              ),
                              _buildMenuDivider(),
                              _buildMenuItem(
                                title: 'Leave Balance',
                                icon: Icons.description_outlined,
                                onTap: () {},
                              ),
                              _buildMenuDivider(),
                              _buildMenuItem(
                                title: 'My Leave Requests',
                                icon: Icons.article_outlined,
                                onTap: () {},
                              ),
                              _buildMenuDivider(),
                              _buildMenuItem(
                                title: 'Attendance Summary',
                                icon: Icons.calendar_today_outlined,
                                onTap: () {},
                              ),
                              _buildMenuDivider(),
                              _buildMenuItem(
                                title: 'Payslips',
                                icon: Icons.receipt_long_outlined,
                                onTap: () {},
                              ),
                              Gap.v32,

                              // ── Log Out Button ──
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: logoutState.status ==
                                          LogoutStatus.loading
                                      ? null
                                      : () => _handleLogout(
                                            context,
                                            logoutCubit,
                                          ),
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Container(
                                    width: double.infinity,
                                    height: 52.h,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFDECEB),
                                      borderRadius:
                                          BorderRadius.circular(16.r),
                                    ),
                                    child: Center(
                                      child: logoutState.status ==
                                              LogoutStatus.loading
                                          ? SizedBox(
                                              width: 22.r,
                                              height: 22.r,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.2.r,
                                                color: const Color(0xFFDC2626),
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.logout_rounded,
                                                  color:
                                                      const Color(0xFFDC2626),
                                                  size: 20.r,
                                                ),
                                                Gap.h8,
                                                Text(
                                                  'Log Out',
                                                  style: TextStyle(
                                                    color:
                                                        const Color(0xFFDC2626),
                                                    fontSize: 15.sp,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5.sp,
            color: const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF045C2C),
                size: 22.r,
              ),
              Gap.h16,
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFF94A3B8),
                size: 20.r,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return Padding(
      padding: EdgeInsets.only(left: 42.w),
      child: const Divider(
        height: 1,
        thickness: 0.8,
        color: Color(0xFFF1F5F9),
      ),
    );
  }
}
