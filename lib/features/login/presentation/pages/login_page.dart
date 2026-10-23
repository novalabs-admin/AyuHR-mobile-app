import 'package:erp_hr/core/utils/colors.dart';
import 'package:erp_hr/core/utils/enums.dart';
import 'package:erp_hr/core/utils/spacing.dart';
import 'package:erp_hr/core/utils/text_styles.dart';
import 'package:erp_hr/features/login/presentation/blocs/auth_cubit.dart';
import 'package:erp_hr/features/login/presentation/blocs/auth_state.dart';
import 'package:erp_hr/features/login/presentation/blocs/login_cubit.dart';
import 'package:erp_hr/features/login/presentation/blocs/login_state.dart';
import 'package:erp_hr/injector.dart';
import 'package:erp_hr/shared/widget/app_button.dart';
import 'package:erp_hr/shared/widget/app_snack_bar.dart';
import 'package:erp_hr/shared/widget/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

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
                      userId: state.user?.userProfileId ?? 1,
                    );
                context.go('/dashboard');
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
              if (state is Authenticated) {
                context.go('/dashboard');
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
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: 'akila');
    _passwordController = TextEditingController(text: '1234');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSimpleTouchLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    // Smooth UI presentation delay (simulating authentic login with zero API calls)
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    // Set mock authenticated state
    final username = _usernameController.text.trim();
    context.read<AuthCubit>().setLoggedIn(
          userId: 1,
          username: username.isNotEmpty ? username : 'akila',
        );

    if (mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight = (screenHeight * 0.30).clamp(200.0, 280.0).h;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // ── Hero banner image (top) ──
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
                                AppTextField(
                                  controller: _usernameController,
                                  label: 'Username',
                                  hint: 'Enter your username',
                                  filled: true,
                                  borderRadius: 14.r,
                                  onChanged: context
                                      .read<LoginCubit>()
                                      .usernameChanged,
                                  textInputAction: TextInputAction.next,
                                  onSubmitted: (_) =>
                                      _handleSimpleTouchLogin(),
                                ),

                                Gap.v16,

                                // ── Password field ──
                                AppTextField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  hint: 'Enter your password',
                                  isPassword: true,
                                  filled: true,
                                  borderRadius: 14.r,
                                  onChanged: context
                                      .read<LoginCubit>()
                                      .passwordChanged,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _handleSimpleTouchLogin(),
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
                                                  shape:
                                                      RoundedRectangleBorder(
                                                    borderRadius: AppRadius.r4,
                                                  ),
                                                ),
                                              ),
                                              Gap.h8,
                                              Flexible(
                                                child: Text(
                                                  'Remember Me',
                                                  style: AppTextStyle
                                                      .bodyMedium
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

                        // ── Bottom: LOG IN button (Simple Touch Navigation) + footer ──
                        Padding(
                          padding: AppPadding.fromLTRB(20, 8, 20, 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppButton(
                                label: 'LOG IN',
                                backgroundColor: AppColor.primaryDark,
                                foregroundColor: AppColor.primaryLight,
                                borderRadius: 30.r,
                                height: 52.h,
                                fontSize: 16.sp,
                                isLoading: _isLoading,
                                onPressed:
                                    _isLoading ? null : _handleSimpleTouchLogin,
                                useGradient: true,
                              ),

                              Gap.v12,

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
