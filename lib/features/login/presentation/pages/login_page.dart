import 'package:erp_hr/core/utils/enums.dart';
import 'package:erp_hr/core/utils/spacing.dart';
import 'package:erp_hr/core/utils/text_styles.dart';
import 'package:erp_hr/features/login/presentation/blocs/auth_cubit.dart';
import 'package:erp_hr/features/login/presentation/blocs/auth_state.dart';
import 'package:erp_hr/features/login/presentation/blocs/login_cubit.dart';
import 'package:erp_hr/features/login/presentation/blocs/login_state.dart';
import 'package:erp_hr/shared/widget/app_button.dart';
import 'package:erp_hr/shared/widget/app_snack_bar.dart';
import 'package:erp_hr/shared/widget/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:erp_hr/core/utils/colors.dart';
import 'package:erp_hr/injector.dart';

// ─────────────────────────────────────────────────────────────────────────
// NOTE ON THIS PASS:
// Only the VISUAL TREE inside LoginView.build() changed to match the new
// web design (hero banner image + rounded white card overlapping it,
// green gradient LOG IN button, footer copyright line).
//
// Everything below is UNCHANGED from your working version:
//   • BlocProvider / MultiBlocListener wiring in LoginPage
//   • LoginCubit.usernameChanged / passwordChanged / rememberMeToggled / submit
//   • AuthCubit.setLoggedIn
//   • All BlocListener / BlocBuilder logic, buildWhen/listenWhen conditions
//   • _usernameController and its lifecycle
//   • Validators / errorText wiring (state.username.displayError, etc.)
//   • Navigation calls (context.go / context.push)
// ─────────────────────────────────────────────────────────────────────────

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginCubit>(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<LoginCubit, LoginState>(
            listenWhen: (p, c) => p.status != c.status,
            listener: (context, state) {
              if (state.status == SubmitStatus.success) {
                context.read<AuthCubit>().setLoggedIn(
                  userId: state.user?.userProfileId,
                );
                if (state.user?.isPasswordExpiringSoon ?? false) {
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final expiry = state.user!.passwordExpiryDate.toLocal();
                  final expiryDate =
                  DateTime(expiry.year, expiry.month, expiry.day);
                  final diff = expiryDate.difference(today).inDays;

                  String message;
                  if (diff <= 0) {
                    message =
                    'Your password expires today! Please change it immediately.';
                  } else if (diff == 1) {
                    message =
                    'Your password will expire tomorrow! Please change it soon.';
                  } else {
                    message =
                    'Your password will expire in $diff days. Please change it soon.';
                  }

                  AppSnackBar.warning(
                    context,
                    message: message,
                    duration: const Duration(seconds: 6),
                  );
                } else {
                  AppSnackBar.success(
                    context,
                    message: 'Login successful! Welcome back.',
                  );
                }
                // Navigation to /dashboard is handled automatically by GoRouter's
                // refreshListenable once AuthCubit emits Authenticated.
              } else if (state.status == SubmitStatus.passwordExpired) {
                // Password is expired — force user to change it before continuing
                AppSnackBar.warning(
                  context,
                  message:
                  'Your password has expired. Please set a new password.',
                );
                context.go(
                  '/reset-password',
                  extra: state.user?.accessToken,
                );
              } else if (state.status == SubmitStatus.failure) {
                AppSnackBar.error(
                  context,
                  message:
                  state.errorMessage ?? 'Invalid username or password.',
                );
              }
            },
          ),
          BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthFailure) {
                AppSnackBar.error(
                  context,
                  message: state.message,
                );
              }
            },
          ),
        ],
        child: const LoginView(),
      ),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    // Hero banner height — big enough to feel like the web's left panel,
    // small enough to leave room for the form on a phone screen.
    final bannerHeight = (screenHeight * 0.30).clamp(200.0, 280.0).h;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // ── Hero banner image (top) ──
          // TODO: point this at your actual ayurvedic banner asset
          // (herbs / mortar & pestle image from the web design).
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: bannerHeight + 40.h,
            child: Image.asset(
              'assets/images/ayu_erp_img.png',
              fit: BoxFit.cover,
            ),
          ),

          // ── Foreground content ──
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Spacer so the card below starts partway down the banner,
                // creating the overlap look from the web design.
                SizedBox(height: bannerHeight - 24.h),

                // ── White rounded card (form) ──
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cs.surface,
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
                    child: Column(
                      children: [
                        // ── Scrollable form fields ──
                        Expanded(
                          child: SingleChildScrollView(
                            padding: AppPadding.horizontal24,
                            child: Column(
                              children: [
                                Gap.v10,

                                // ── Logo ──
                                Image.asset(
                                  'assets/images/ayu_hr.png',
                                  height: 100.h,
                                  width: 400.w,
                                ),

                                Gap.v20,

                                // ── "Welcome Back!" ──
                                Text(
                                  'Welcome Back!',
                                  style: AppTextStyle.h2.extraBold
                                      .withColor(cs.onSurface),
                                ),

                                Gap.v8,

                                // ── Subtitle ──
                                Text(
                                  'An ERP system built to boost organizational efficiency.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyle.bodySmall
                                      .withColor(cs.onSurfaceVariant),
                                ),

                                Gap.v8,

                                // Small accent underline, matching the web design
                                Container(
                                  width: 36.w,
                                  height: 3.h,
                                  decoration: BoxDecoration(
                                    color: AppColor.primary,
                                    borderRadius: AppRadius.full,
                                  ),
                                ),

                                Gap.v24,

                                // ── Username field ──
                                BlocListener<LoginCubit, LoginState>(
                                  listenWhen: (p, c) =>
                                  p.username.value != c.username.value &&
                                      c.username.value.isNotEmpty &&
                                      _usernameController.text.isEmpty,
                                  listener: (context, state) {
                                    _usernameController.text =
                                        state.username.value;
                                  },
                                  child: BlocBuilder<LoginCubit, LoginState>(
                                    buildWhen: (p, c) => p.username != c.username,
                                    builder: (context, state) {
                                      return AppTextField(
                                        controller: _usernameController,
                                        label: 'Username',
                                        hint: 'Enter your username',
                                        errorText:
                                        state.username.displayError != null
                                            ? 'Username is required'
                                            : null,
                                        filled: true,
                                        borderRadius: 14.r,
                                        onChanged: context
                                            .read<LoginCubit>()
                                            .usernameChanged,
                                        textInputAction: TextInputAction.next,
                                      );
                                    },
                                  ),
                                ),

                                Gap.v16,

                                // ── Password field ──
                                BlocBuilder<LoginCubit, LoginState>(
                                  buildWhen: (p, c) => p.password != c.password,
                                  builder: (context, state) {
                                    return AppTextField(
                                      label: 'Password',
                                      hint: 'Enter your password',
                                      errorText:
                                      state.password.displayError != null
                                          ? 'Password is required'
                                          : null,
                                      isPassword: true,
                                      filled: true,
                                      borderRadius: 14.r,
                                      onChanged: context
                                          .read<LoginCubit>()
                                          .passwordChanged,
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) =>
                                          context.read<LoginCubit>().submit(),
                                    );
                                  },
                                ),

                                Gap.v12,

                                // ── Remember me / Forgot password ──
                                BlocBuilder<LoginCubit, LoginState>(
                                  buildWhen: (p, c) =>
                                  p.rememberMe != c.rememberMe,
                                  builder: (context, state) {
                                    return Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 22.r,
                                                height: 22.r,
                                                child: Checkbox(
                                                  value: state.rememberMe,
                                                  onChanged: (_) => context
                                                      .read<LoginCubit>()
                                                      .rememberMeToggled(),
                                                  activeColor: AppColor.primary,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: AppRadius.r4,
                                                  ),
                                                ),
                                              ),
                                              Gap.h8,
                                              Flexible(
                                                child: Text(
                                                  'Remember Me',
                                                  style: AppTextStyle.bodyMedium
                                                      .withColor(cs.onSurface),
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            context.push('/forgot-password');
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: AppColor.primary,
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: Text(
                                            'Forgot Password?',
                                            style: AppTextStyle.bodyMedium
                                                .semiBold
                                                .withColor(AppColor.primary),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                Gap.v20,
                              ],
                            ),
                          ),
                        ),

                        // ── Bottom: LOG IN button + footer ──
                        Padding(
                          padding: AppPadding.fromLTRB(20, 8, 20, 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ── Green gradient LOG IN button ──
                              BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, authState) {
                                  return BlocBuilder<LoginCubit, LoginState>(
                                    buildWhen: (p, c) => p.status != c.status,
                                    builder: (context, loginState) {
                                      // Keep button in loading state during both
                                      // the login API call AND the subsequent
                                      // profile-fetch phase.
                                      final isLoading = loginState.status ==
                                          SubmitStatus.loading ||
                                          authState is AuthLoading;

                                      return AppButton(
                                        label: 'LOG IN',
                                        isLoading: isLoading,
                                        backgroundColor: AppColor.primaryDark,
                                        foregroundColor: AppColor.primaryLight,
                                        borderRadius: 30.r,
                                        height: 52.h,
                                        fontSize: 16.sp,
                                        onPressed: isLoading
                                            ? null
                                            : () => context
                                            .read<LoginCubit>()
                                            .submit(),
                                        useGradient: true,
                                      );
                                    },
                                  );
                                },
                              ),

                              Gap.v12,

                              // ── Footer copyright ──
                              Text(
                                '© ${DateTime.now().year} Ayu lanka Medical Pvt Ltd. All rights reserved.',
                                textAlign: TextAlign.center,
                                style: AppTextStyle.bodySmall
                                    .withColor(cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}