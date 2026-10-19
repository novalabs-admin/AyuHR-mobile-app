import 'package:erp_hr/core/utils/colors.dart';
import 'package:erp_hr/core/utils/spacing.dart';
import 'package:erp_hr/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:erp_hr/features/dashboard/presentation/widgets/kpi_card.dart';
import 'package:erp_hr/features/dashboard/presentation/widgets/pipeline_overview_card.dart';
import 'package:erp_hr/features/dashboard/presentation/widgets/quick_action_grid.dart';
import 'package:erp_hr/features/dashboard/presentation/widgets/recent_leads_section.dart';
import 'package:erp_hr/features/dashboard/presentation/widgets/recent_quotations_section.dart';
import 'package:erp_hr/shared/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Future<void> _onRefresh() async {
    // Simulating data refresh
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Dashboard',
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColor.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: 100.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dynamic Header Banner
              const DashboardHeader(),
              Gap.v16,

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KPI Metrics Grid
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 1.35,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        KpiCard(
                          title: 'Total Leads',
                          value: '38',
                          icon: Icons.people_outline,
                          iconColor: const Color(0xFF2563EB),
                          backgroundColor: const Color(0xFFDBEAFE),
                          trend: '+12%',
                          onTap: () => context.go('/leads'),
                        ),
                        KpiCard(
                          title: 'Quotations',
                          value: '24',
                          icon: Icons.request_quote_outlined,
                          iconColor: AppColor.primary,
                          backgroundColor: const Color(0xFFDCFCE7),
                          trend: '+8%',
                          onTap: () => context.go('/quotations'),
                        ),
                        const KpiCard(
                          title: 'Pipeline Value',
                          value: 'LKR 850K',
                          icon: Icons.account_balance_wallet_outlined,
                          iconColor: Color(0xFFD97706),
                          backgroundColor: Color(0xFFFEF3C7),
                          trend: '+15%',
                        ),
                        const KpiCard(
                          title: 'Win Rate',
                          value: '68%',
                          icon: Icons.emoji_events_outlined,
                          iconColor: Color(0xFF7C3AED),
                          backgroundColor: Color(0xFFEDE9FE),
                          trend: '+4%',
                        ),
                      ],
                    ),
                    Gap.v20,

                    // Quick Actions Hub
                    const QuickActionGrid(),
                    Gap.v20,

                    // Pipeline Target & Breakdown Card
                    const PipelineOverviewCard(),
                    Gap.v20,

                    // Recent Leads List
                    const RecentLeadsSection(),
                    Gap.v20,

                    // Recent Quotations List
                    const RecentQuotationsSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
