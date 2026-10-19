import 'package:erp_hr/core/utils/colors.dart';
import 'package:erp_hr/core/utils/spacing.dart';
import 'package:erp_hr/core/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PipelineOverviewCard extends StatelessWidget {
  const PipelineOverviewCard({
    this.totalTarget = 1200000,
    this.achievedRevenue = 850000,
    super.key,
  });

  final double totalTarget;
  final double achievedRevenue;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressPercent = (achievedRevenue / totalTarget).clamp(0.0, 1.0);

    final statusData = [
      const _StatusItem(label: 'New', count: 12, color: Color(0xFF3B82F6)),
      const _StatusItem(
        label: 'Contacted',
        count: 8,
        color: Color(0xFFF59E0B),
      ),
      const _StatusItem(label: 'Visited', count: 5, color: Color(0xFF8B5CF6)),
      const _StatusItem(label: 'Won', count: 18, color: AppColor.primary),
      const _StatusItem(label: 'Lost', count: 3, color: Color(0xFFEF4444)),
    ];

    final totalLeads = statusData.fold<int>(0, (sum, item) => sum + item.count);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withAlpha(40) : Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.pie_chart_outline,
                      color: AppColor.primary,
                      size: 20.r,
                    ),
                  ),
                  Gap.h10,
                  Text(
                    'Monthly Target & Pipeline',
                    style: AppTextStyle.h6.bold.withColor(cs.onSurface),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColor.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${(progressPercent * 100).toStringAsFixed(1)}%',
                  style: AppTextStyle.caption.bold.withColor(AppColor.primary),
                ),
              ),
            ],
          ),
          Gap.v16,
          // Target progress header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achieved: LKR ${(achievedRevenue / 1000).toStringAsFixed(0)}K',
                style: AppTextStyle.bodySmall.semiBold.withColor(cs.onSurface),
              ),
              Text(
                'Goal: LKR ${(totalTarget / 1000).toStringAsFixed(0)}K',
                style: AppTextStyle.caption.medium.withColor(
                  cs.onSurface.withAlpha(150),
                ),
              ),
            ],
          ),
          Gap.v6,
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 10.h,
              backgroundColor: isDark
                  ? Colors.white10
                  : AppColor.primary.withAlpha(30),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColor.primary),
            ),
          ),
          Gap.v20,
          Divider(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
            height: 1,
          ),
          Gap.v16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lead Pipeline Breakdown',
                style: AppTextStyle.bodySmall.bold.withColor(cs.onSurface),
              ),
              Text(
                '$totalLeads Total Leads',
                style: AppTextStyle.caption.medium.withColor(
                  cs.onSurface.withAlpha(160),
                ),
              ),
            ],
          ),
          Gap.v10,
          // Segmented progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: SizedBox(
              height: 10.h,
              child: Row(
                children: statusData.map((item) {
                  final flex = (item.count / totalLeads * 100).round();
                  return Expanded(
                    flex: flex > 0 ? flex : 1,
                    child: Container(
                      color: item.color,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Gap.v16,
          // Status Chips Legend
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: statusData.map((item) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? item.color.withAlpha(30)
                      : item.color.withAlpha(15),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: item.color.withAlpha(60),
                    width: 0.8.r,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: BoxDecoration(
                        color: item.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Gap.h6,
                    Text(
                      '${item.label}: ',
                      style: AppTextStyle.caption.medium.withColor(
                        cs.onSurface,
                      ),
                    ),
                    Text(
                      '${item.count}',
                      style: AppTextStyle.caption.bold.withColor(
                        item.color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StatusItem {
  const _StatusItem({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;
}
