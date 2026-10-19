import 'package:erp_hr/core/utils/colors.dart';
import 'package:erp_hr/core/utils/spacing.dart';
import 'package:erp_hr/core/utils/text_styles.dart';
import 'package:erp_hr/features/leads/presentation/lead_list_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class RecentLeadsSection extends StatelessWidget {
  const RecentLeadsSection({super.key});

  Color _getStatusColor(String statusName) {
    switch (statusName.toLowerCase()) {
      case 'new':
        return const Color(0xFF2563EB);
      case 'contacted':
        return const Color(0xFFD97706);
      case 'visited':
        return const Color(0xFF7C3AED);
      case 'won':
        return AppColor.primary;
      case 'lost':
        return const Color(0xFFDC2626);
      default:
        return AppColor.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Sample recent leads
    final sampleLeads = [
      MockLead(
        customerName: 'John Silva',
        address: 'No. 12, Galle Road, Colombo 03',
        mobileNo: '+94 77 123 4567',
        currentStatus: 1,
        currentStatusName: 'New',
        sumAssured: 35000,
      ),
      MockLead(
        customerName: 'Amara Perera',
        address: 'No. 45, Kandy Road, Kadawatha',
        mobileNo: '+94 71 987 6543',
        currentStatus: 2,
        currentStatusName: 'Contacted',
        sumAssured: 12000,
      ),
      MockLead(
        customerName: 'Kamala Jayawardena',
        address: 'No. 33, High Level Road, Nugegoda',
        mobileNo: '+94 75 222 9090',
        currentStatus: 5,
        currentStatusName: 'Won',
        sumAssured: 80000,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Leads',
              style: AppTextStyle.h5.bold.withColor(cs.onSurface),
            ),
            TextButton(
              onPressed: () => context.go('/leads'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                children: [
                  Text(
                    'See All',
                    style: AppTextStyle.bodySmall.bold.withColor(
                      AppColor.primary,
                    ),
                  ),
                  Gap.h4,
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12.r,
                    color: AppColor.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        Gap.v12,
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sampleLeads.length,
          separatorBuilder: (context, index) => Gap.v8,
          itemBuilder: (context, index) {
            final lead = sampleLeads[index];
            final statusColor = _getStatusColor(
              lead.currentStatusName ?? 'New',
            );

            return Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withAlpha(30)
                        : Colors.grey.shade100,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: statusColor.withAlpha(30),
                    child: Text(
                      lead.customerName.isNotEmpty
                          ? lead.customerName[0].toUpperCase()
                          : 'L',
                      style: AppTextStyle.bodyLarge.bold.withColor(statusColor),
                    ),
                  ),
                  Gap.h12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                lead.customerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle.bodyMedium.bold.withColor(
                                  cs.onSurface,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: statusColor.withAlpha(60),
                                  width: 0.6.r,
                                ),
                              ),
                              child: Text(
                                lead.currentStatusName ?? 'New',
                                style: AppTextStyle.caption.bold.withColor(
                                  statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Gap.v4,
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 12.r,
                              color: cs.onSurface.withAlpha(140),
                            ),
                            Gap.h4,
                            Text(
                              lead.mobileNo,
                              style: AppTextStyle.caption.medium.withColor(
                                cs.onSurface.withAlpha(160),
                              ),
                            ),
                            Gap.h12,
                            Icon(
                              Icons.attach_money_outlined,
                              size: 12.r,
                              color: AppColor.primary,
                            ),
                            Text(
                              'LKR ${lead.sumAssured.toStringAsFixed(0)}',
                              style: AppTextStyle.caption.bold.withColor(
                                AppColor.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
