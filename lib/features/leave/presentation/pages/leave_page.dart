import 'package:erp_hr/core/utils/constants.dart';
import 'package:erp_hr/core/utils/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LeavePage extends StatelessWidget {
  const LeavePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF045C2C),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top Header Bar ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 26.r,
                    ),
                    onPressed: () {
                      mainScaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  Text(
                    'Leave',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 26.r,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Gap.v8,

            // ── Main Content Container ──
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28.r),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 100.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section: Leave Balances
                      Text(
                        'Leave Balances',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Gap.v12,

                      // 3 Balance Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildLeaveBalanceCard(
                              type: 'Annual',
                              available: '14',
                              total: '18',
                              color: const Color(0xFF00632B),
                              bgColor: const Color(0xFFE8F5E9),
                            ),
                          ),
                          Gap.h12,
                          Expanded(
                            child: _buildLeaveBalanceCard(
                              type: 'Casual',
                              available: '5',
                              total: '7',
                              color: const Color(0xFF0284C7),
                              bgColor: const Color(0xFFE0F2FE),
                            ),
                          ),
                          Gap.h12,
                          Expanded(
                            child: _buildLeaveBalanceCard(
                              type: 'Medical',
                              available: '12',
                              total: '14',
                              color: const Color(0xFF7C3AED),
                              bgColor: const Color(0xFFF3E8FF),
                            ),
                          ),
                        ],
                      ),
                      Gap.v20,

                      // "Apply For Leave" Action Card / Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Apply Leave form is under development.',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16.r),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 16.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF00632B),
                                  Color(0xFF045C2C),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00632B)
                                      .withValues(alpha: 0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_circle_outline_rounded,
                                  color: Colors.white,
                                  size: 22.r,
                                ),
                                Gap.h10,
                                Text(
                                  'Apply for Leave',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Gap.v20,

                      // Section Title
                      Text(
                        'Recent Requests',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Gap.v12,

                      // Empty / Starter Placeholder Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 36.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 64.r,
                              height: 64.r,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.description_outlined,
                                color: const Color(0xFF0284C7),
                                size: 32.r,
                              ),
                            ),
                            Gap.v16,
                            Text(
                              'No Active Requests',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Gap.v6,
                            Text(
                              'When you submit a leave application, you can track its approval status here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: const Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveBalanceCard({
    required String type,
    required String available,
    required String total,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              type,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          Gap.v12,
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                available,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Gap.h4,
              Text(
                '/$total days',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Gap.v2,
          Text(
            'Remaining',
            style: TextStyle(
              fontSize: 11.sp,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
