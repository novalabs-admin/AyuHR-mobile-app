import 'package:erp_hr/core/utils/colors.dart';
import 'package:erp_hr/core/utils/spacing.dart';
import 'package:erp_hr/core/utils/text_styles.dart';
import 'package:erp_hr/features/login/presentation/blocs/auth_cubit.dart';
import 'package:erp_hr/features/login/presentation/blocs/auth_state.dart';
import 'package:erp_hr/features/login/presentation/blocs/logout_cubit.dart';
import 'package:erp_hr/features/login/presentation/blocs/logout_state.dart';
import 'package:erp_hr/injector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';


class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BlocProvider(
      create: (_) => getIt<LogoutCubit>(),
      child: BlocConsumer<LogoutCubit, LogoutState>(
        listener: (context, state) {
          if (state.status == LogoutStatus.success) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            context.go('/');
          }
        },
        builder: (context, logoutState) {
          return BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              final userProfile = authState is Authenticated
                  ? authState.userProfile
                  : null;
              //final trainerLevelName = userProfile?.trainerLevelName;

              return Drawer(
                backgroundColor: cs.surface,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      decoration: const BoxDecoration(
                        color: AppColor.primary,
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: cs.surface,
                              radius: 30.r,
                              child: Icon(
                                  Icons.person, color: AppColor.primary, size: 30.r),
                            ),
                            Gap.v12,
                            Text(
                              userProfile?.username ?? 'User',
                              style: AppTextStyle.h5.semiBold.withColor(Colors.white),
                            ),
                            // if (trainerLevelName != null &&
                            //     trainerLevelName.isNotEmpty) ...[
                            //   Gap.v4,
                            //   Text(
                            //     trainerLevelName,
                            //     style: AppTextStyle.bodyMedium
                            //         .withColor(Colors.white.withAlpha(200)
                            //     ),
                            //   ),
                            // ],
                          ],
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.person_outline, color: cs.onSurface),
                      title: Text(
                        'Profile',
                        style:
                            AppTextStyle.bodyLarge.semiBold.withColor(cs.onSurface),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/profile');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.settings_outlined, color: cs.onSurface),
                      title: Text(
                        'Settings',
                        style:
                            AppTextStyle.bodyLarge.semiBold.withColor(cs.onSurface),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/settings');
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: logoutState.status == LogoutStatus.loading
                          ? SizedBox(
                              width: 20.r,
                              height: 20.r,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.r,
                                color: Colors.red,
                              ),
                            )
                          : const Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        'Log Out',
                        style:
                            AppTextStyle.bodyLarge.semiBold.withColor(Colors.red),
                      ),
                      onTap: () {
                        if (logoutState.status != LogoutStatus.loading) {
                          context.read<LogoutCubit>().logout();
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
