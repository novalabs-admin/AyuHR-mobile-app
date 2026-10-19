import 'dart:async';

import 'package:erp_hr/core/utils/colors.dart';
import 'package:erp_hr/core/utils/spacing.dart';
import 'package:erp_hr/core/utils/text_styles.dart';
import 'package:erp_hr/features/login/presentation/blocs/auth_cubit.dart';
import 'package:erp_hr/features/login/presentation/blocs/auth_state.dart';
import 'package:erp_hr/features/login/presentation/blocs/logout_cubit.dart';
import 'package:erp_hr/features/login/presentation/blocs/logout_state.dart';
import 'package:erp_hr/injector.dart';
import 'package:erp_hr/shared/widget/app_confirm_dialog.dart';
import 'package:erp_hr/shared/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => getIt<LogoutCubit>(),
      child: BlocConsumer<LogoutCubit, LogoutState>(
        listener: (context, logoutState) {
          if (logoutState.status == LogoutStatus.success) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            context.go('/');
          }
        },
        builder: (context, logoutState) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: CustomAppBar(
              title: 'Profile',
              isNeedBackButton: true,
              onBackPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  context.go('/dashboard');
                }
              },
            ),
            body: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                final userProfile = authState is Authenticated
                    ? authState.userProfile
                    : null;
                final branch =
                    authState is Authenticated ? authState.branch : null;
                final userName =
                    userProfile?.username ?? 'Sales Representative';
                final branchName = branch?.name ?? 'Main Branch';
                final userId = userProfile?.userId ?? 0;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    children: [
                      // Header Card with Gradient & Avatar
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [
                                    const Color(0xFF1E293B),
                                    const Color(0xFF0F172A),
                                  ]
                                : [
                                    AppColor.primary,
                                    AppColor.primary.withRed(30),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.primary.withValues(alpha: 0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 44.r,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    radius: 41.r,
                                    backgroundColor: AppColor.primary
                                        .withValues(alpha: 0.1),
                                    child: Icon(
                                      Icons.person,
                                      size: 48.r,
                                      color: AppColor.primary,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(4.r),
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      size: 12.r,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Gap.v12,
                            Text(
                              userName,
                              style:
                                  AppTextStyle.h3.bold.withColor(Colors.white),
                            ),
                            Gap.v4,
                            Text(
                              'Sales Executive',
                              style: AppTextStyle.bodyMedium.withColor(
                                Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                            Gap.v12,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.business,
                                    size: 14.r,
                                    color: Colors.white,
                                  ),
                                  Gap.h6,
                                  Text(
                                    branchName,
                                    style: AppTextStyle.caption.semiBold
                                        .withColor(Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap.v20,

                      // Info Details Card
                      _buildSectionCard(
                        context,
                        title: 'Account Information',
                        icon: Icons.badge_outlined,
                        children: [
                          _buildDetailRow(
                            context,
                            icon: Icons.tag,
                            label: 'User ID',
                            value: userId > 0 ? '#$userId' : 'N/A',
                          ),
                          const Divider(height: 1),
                          _buildDetailRow(
                            context,
                            icon: Icons.person_outline,
                            label: 'Username',
                            value: userName,
                          ),
                          const Divider(height: 1),
                          _buildDetailRow(
                            context,
                            icon: Icons.storefront_outlined,
                            label: 'Assigned Branch',
                            value: branchName,
                          ),
                          const Divider(height: 1),
                          _buildDetailRow(
                            context,
                            icon: Icons.verified_user_outlined,
                            label: 'Account Status',
                            value: 'Active',
                            valueColor: Colors.green,
                          ),
                        ],
                      ),
                      Gap.v16,

                      // App Preferences Section
                      _buildSectionCard(
                        context,
                        title: 'Preferences & Actions',
                        icon: Icons.tune_outlined,
                        children: [
                          _buildActionTile(
                            context,
                            icon: Icons.lock_outline,
                            title: 'Change Password',
                            subtitle: 'Update your security credentials',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Password change request initiated.',
                                  ),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          _buildActionTile(
                            context,
                            icon: Icons.notifications_none_outlined,
                            title: 'Notifications',
                            subtitle: 'Manage alert preferences',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Notifications enabled.'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Gap.v24,

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: BorderSide(color: Colors.red.shade200),
                            ),
                          ),
                          onPressed: logoutState.status == LogoutStatus.loading
                              ? null
                              : () async {
                                  final confirm = await AppConfirmDialog.show(
                                    context,
                                    title: 'Log Out',
                                    message: 'Are you sure you want to log out'
                                        ' of your account?',
                                    confirmLabel: 'Log Out',
                                    isDestructive: true,
                                  );

                                  if (confirm && context.mounted) {
                                    unawaited(
                                      context.read<LogoutCubit>().logout(),
                                    );
                                  }
                                },
                          child: logoutState.status == LogoutStatus.loading
                              ? SizedBox(
                                  width: 20.r,
                                  height: 20.r,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.r,
                                    color: Colors.red,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.logout, size: 20.r),
                                    Gap.h8,
                                    Text(
                                      'Log Out',
                                      style: AppTextStyle.button.semiBold
                                          .withColor(Colors.red),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      Gap.v20,
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
            child: Row(
              children: [
                Icon(icon, size: 18.r, color: AppColor.primary),
                Gap.h8,
                Text(
                  title,
                  style: AppTextStyle.h5.bold.withColor(cs.onSurface),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 18.r, color: cs.onSurfaceVariant),
          Gap.h12,
          Text(
            label,
            style: AppTextStyle.bodyMedium.withColor(cs.onSurfaceVariant),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyle.bodyMedium.semiBold
                .withColor(valueColor ?? cs.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: AppColor.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, size: 20.r, color: AppColor.primary),
      ),
      title: Text(
        title,
        style: AppTextStyle.bodyLarge.semiBold.withColor(cs.onSurface),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyle.caption.withColor(cs.onSurfaceVariant),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 20.r,
        color: cs.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}
