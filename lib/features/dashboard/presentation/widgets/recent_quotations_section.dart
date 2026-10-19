import 'package:erp_hr/core/utils/colors.dart';
import 'package:erp_hr/core/utils/spacing.dart';
import 'package:erp_hr/core/utils/text_styles.dart';
import 'package:erp_hr/features/quotations/quotation_list_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RecentQuotationsSection extends StatelessWidget {
  const RecentQuotationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Sample recent quotations
    final sampleQuotations = [
      MockQuotation(
        id: 'Q-001',
        customerName: 'Ahamalki Care',
        address: 'No. 22, Temple Road, Colombo',
        mobileNo: '+94 77 111 2222',
        globalDiscount: 5,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        items: [
          const MockQuotationItem(
            itemName: 'Ahamalki 25g',
            unitName: 'Packet',
            quantity: 3,
            sellingPrice: 300,
            discount: 0,
          ),
          const MockQuotationItem(
            itemName: 'Wellness Package',
            unitName: 'Units',
            quantity: 1,
            sellingPrice: 25000,
            discount: 10,
          ),
        ],
      ),
      MockQuotation(
        id: 'Q-002',
        customerName: 'Saman Silva',
        address: 'No. 54, Galle Road, Colombo',
        mobileNo: '+94 71 333 4444',
        globalDiscount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        items: [
          const MockQuotationItem(
            itemName: 'Herbal Tea Box',
            unitName: 'Box',
            quantity: 5,
            sellingPrice: 900,
            discount: 5,
          ),
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Quotations',
              style: AppTextStyle.h5.bold.withColor(cs.onSurface),
            ),
            TextButton(
              onPressed: () => context.go('/quotations'),
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
          itemCount: sampleQuotations.length,
          separatorBuilder: (context, index) => Gap.v8,
          itemBuilder: (context, index) {
            final q = sampleQuotations[index];
            final formattedDate =
                DateFormat('MMM dd, yyyy').format(q.createdAt);

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
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.request_quote_outlined,
                      color: AppColor.primary,
                      size: 22.r,
                    ),
                  ),
                  Gap.h12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                q.id,
                                style: AppTextStyle.caption.bold.withColor(
                                  cs.onPrimaryContainer,
                                ),
                              ),
                            ),
                            Gap.h8,
                            Expanded(
                              child: Text(
                                q.customerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle.bodyMedium.bold.withColor(
                                  cs.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Gap.v4,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${q.items.length} Item(s) • $formattedDate',
                              style: AppTextStyle.caption.medium.withColor(
                                cs.onSurface.withAlpha(150),
                              ),
                            ),
                            Text(
                              'LKR ${q.totalAmount.toStringAsFixed(2)}',
                              style: AppTextStyle.bodySmall.bold.withColor(
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
