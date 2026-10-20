import 'package:erp_hr/core/utils/constants.dart';
import 'package:erp_hr/core/utils/spacing.dart';
import 'package:erp_hr/features/login/presentation/blocs/auth_cubit.dart';
import 'package:erp_hr/features/login/presentation/blocs/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final bannerHeight = 205.h;
    final overlapAmount = 26.h;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: Stack(
        children: [
          // ── Fixed Top Header Banner (Stable, does not scroll) ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: bannerHeight,
            child: _buildTopBanner(context),
          ),

          // ── Scrollable White Body Container ──
          Positioned.fill(
            top: bannerHeight - overlapAmount,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAF8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  topRight: Radius.circular(30.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  topRight: Radius.circular(30.r),
                ),
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: const Color(0xFF00632B),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting & Date
                        _buildGreeting(context),
                        Gap.v16,

                        // Today's Attendance Card
                        _buildTodayAttendanceCard(context),
                        Gap.v24,

                        // Quick Actions Section
                        _buildQuickActionsSection(context),
                        Gap.v24,

                        // Recent Activity Section
                        _buildRecentActivitySection(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top Header Banner (Stable) ─────────────────────────────────────────────
  Widget _buildTopBanner(BuildContext context) {
    return SizedBox(
      height: 205.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background herbal foliage image
          Image.asset(
            'assets/images/ayu_erp_img.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),

          // Subtle gradient to guarantee contrast
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.15),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Content over the banner
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar: Hamburger Menu & Notifications
                  Row(
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
                  Gap.v4,

                  // Ayu Lanka Logo
                  Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo-Ayulanka.png',
                        height: 38.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Greeting & Date ────────────────────────────────────────────────────────
  Widget _buildGreeting(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final profile =
            authState is Authenticated ? authState.userProfile : null;
        final name = profile?.username ?? 'Dr. Sanduni';
        final hour = DateTime.now().hour;
        final greeting = hour < 12
            ? 'Good morning'
            : hour < 17
                ? 'Good afternoon'
                : 'Good evening';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, $name',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
                letterSpacing: -0.3,
              ),
            ),
            Gap.v4,
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Today's Attendance Card ────────────────────────────────────────────────
  Widget _buildTodayAttendanceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 20.r,
                color: const Color(0xFF0F172A),
              ),
              Gap.h8,
              Text(
                "Today's Attendance",
                style: TextStyle(
                  fontSize: 16.5.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          Gap.v12,
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF00632B),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Text(
                  'Present',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              Gap.h12,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Text(
                  'Checked in at 08:02 AM',
                  style: TextStyle(
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                    fontSize: 12.5.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Quick Actions Section ──────────────────────────────────────────────────
  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        Gap.v12,
        Row(
          children: [
            _buildQuickActionCard(
              title: 'Attendance',
              subtitle: 'View report',
              icon: Icons.calendar_month_outlined,
              iconColor: const Color(0xFF00632B),
              iconBgColor: const Color(0xFFE6F4EA),
              onTap: () {
                context.go('/attendance');
              },
            ),
            Gap.h12,
            _buildQuickActionCard(
              title: 'Apply Leave',
              subtitle: 'Request leave',
              icon: Icons.description_outlined,
              iconColor: const Color(0xFF0284C7),
              iconBgColor: const Color(0xFFE0F2FE),
              onTap: () {
                context.go('/leave');
              },
            ),
          ],
        ),
        Gap.v12,
        Row(
          children: [
            _buildQuickActionCard(
              title: 'Duty Roster',
              subtitle: 'My shifts',
              icon: Icons.access_time_rounded,
              iconColor: const Color(0xFF7C3AED),
              iconBgColor: const Color(0xFFF3E8FF),
              onTap: () {},
            ),
            Gap.h12,
            _buildQuickActionCard(
              title: 'Payslip',
              subtitle: 'View payslips',
              icon: Icons.article_outlined,
              iconColor: const Color(0xFF0D9488),
              iconBgColor: const Color(0xFFFEF3C7),
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: iconColor, size: 22.r),
                ),
                Gap.h10,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5.sp,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap.v2,
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Recent Activity Section ────────────────────────────────────────────────
  Widget _buildRecentActivitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'View all',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00632B),
                ),
              ),
            ),
          ],
        ),
        Gap.v12,
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActivityItem(
                date: '13 Oct 2026',
                status: 'Present',
                icon: Icons.calendar_month_outlined,
                onTap: () {},
              ),
              Padding(
                padding: EdgeInsets.only(left: 68.w, right: 16.w),
                child: const Divider(
                  height: 1,
                  thickness: 0.8,
                  color: Color(0xFFF1F5F9),
                ),
              ),
              _buildActivityItem(
                date: '12 Oct 2026',
                status: 'Off Day',
                icon: Icons.access_time_rounded,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required String date,
    required String status,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4EA),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF00632B),
                  size: 20.r,
                ),
              ),
              Gap.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Gap.v2,
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFF94A3B8),
                size: 22.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
