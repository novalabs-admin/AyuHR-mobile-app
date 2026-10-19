import 'package:erp_hr/core/utils/colors.dart';
import 'package:erp_hr/core/utils/spacing.dart';
import 'package:erp_hr/core/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final actions = [
      _QuickActionItem(
        label: 'New Lead',
        icon: Icons.person_add_outlined,
        color: const Color(0xFF2563EB),
        bgColor: const Color(0xFFDBEAFE),
        onTap: () => context.push('/leads/create'),
      ),
      _QuickActionItem(
        label: 'New Quotation',
        icon: Icons.post_add_outlined,
        color: AppColor.primary,
        bgColor: const Color(0xFFDCFCE7),
        onTap: () => context.push('/quotations/create'),
      ),
      _QuickActionItem(
        label: 'Leads List',
        icon: Icons.people_outline,
        color: const Color(0xFFD97706),
        bgColor: const Color(0xFFFEF3C7),
        onTap: () => context.go('/leads'),
      ),
      _QuickActionItem(
        label: 'Quotations',
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFA5B4FC).withAlpha(60),
        onTap: () => context.go('/quotations'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyle.h5.bold.withColor(cs.onSurface),
        ),
        Gap.v12,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((action) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: action.onTap,
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.grey.shade200,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withAlpha(40)
                                : Colors.grey.shade100,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? action.color.withAlpha(40)
                                  : action.bgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              action.icon,
                              color: isDark ? action.bgColor : action.color,
                              size: 22.r,
                            ),
                          ),
                          Gap.v8,
                          Text(
                            action.label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.caption.semiBold.withColor(
                              cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _QuickActionItem {

  const _QuickActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;
}
