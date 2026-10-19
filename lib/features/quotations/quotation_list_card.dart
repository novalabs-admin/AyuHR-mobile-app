import 'package:erp_hr/core/utils/colors.dart';
import 'package:erp_hr/core/utils/spacing.dart';
import 'package:erp_hr/core/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class MockQuotationItem {
  const MockQuotationItem({
    required this.itemName,
    required this.unitName,
    required this.quantity,
    required this.sellingPrice,
    required this.discount,
  });

  final String itemName;
  final String unitName;
  final int quantity;
  final double sellingPrice;
  final double discount; // 0-100 percentage

  double get lineTotal => quantity * sellingPrice * (1 - discount / 100);
}

class MockQuotation {
  const MockQuotation({
    required this.id,
    required this.customerName,
    required this.address,
    required this.mobileNo,
    required this.items,
    required this.globalDiscount,
    required this.createdAt,
    this.notes,
  });

  final String id;
  final String customerName;
  final String address;
  final String mobileNo;
  final List<MockQuotationItem> items;
  final double globalDiscount; // 0-100 percentage
  final DateTime createdAt;
  final String? notes;

  double get subTotal => items.fold(0.0, (sum, item) => sum + item.lineTotal);
  double get totalAmount => subTotal * (1 - globalDiscount / 100);
}

class QuotationListCard extends StatefulWidget {
  const QuotationListCard({
    required this.quotation,
    super.key,
  });

  final MockQuotation quotation;

  @override
  State<QuotationListCard> createState() => _QuotationListCardState();
}

class _QuotationListCardState extends State<QuotationListCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final q = widget.quotation;
    final initials = q.customerName.isNotEmpty
        ? q.customerName.trim()[0].toUpperCase()
        : '?';
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(q.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.r16,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: AppPadding.all16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Initials + Name + Date + Total
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: AppColor.primaryDark.withValues(alpha: 0.15),
                  child: Text(
                    initials,
                    style: AppTextStyle.label.bold.withColor(AppColor.primaryDark),
                  ),
                ),
                Gap.h12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q.customerName,
                        style: AppTextStyle.label.bold,
                      ),
                      Gap.v4,
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 12, color: Colors.grey),
                          Gap.h4,
                          Text(
                            dateStr,
                            style: AppTextStyle.caption.withColor(Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColor.primaryDark.withValues(alpha: 0.1),
                        borderRadius: AppRadius.r8,
                      ),
                      child: Text(
                        'LKR ${q.totalAmount.toStringAsFixed(2)}',
                        style: AppTextStyle.labelSmall.bold.withColor(AppColor.primaryDark),
                      ),
                    ),
                    Gap.v4,
                    Text(
                      '${q.items.length} ${q.items.length == 1 ? 'item' : 'items'}',
                      style: AppTextStyle.caption.withColor(cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),

            Gap.v12,
            const Divider(height: 1),
            Gap.v12,

            // Quick Info: Address & Phone
            Row(
              children: [
                const Icon(Icons.home_outlined, size: 14, color: Colors.grey),
                Gap.h6,
                Expanded(
                  child: Text(
                    q.address,
                    style: AppTextStyle.bodySmall.withColor(cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Gap.v4,
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                Gap.h6,
                Text(
                  q.mobileNo,
                  style: AppTextStyle.bodySmall.withColor(cs.onSurfaceVariant),
                ),
              ],
            ),

            // Expansion details for items
            if (_isExpanded) ...[
              Gap.v12,
              const Divider(height: 1),
              Gap.v12,
              Text(
                'Items Summary:',
                style: AppTextStyle.labelSmall.bold.withColor(cs.onSurface),
              ),
              Gap.v6,
              ...q.items.map((item) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.itemName} (${item.unitName}) x ${item.quantity}',
                            style: AppTextStyle.bodySmall.withColor(cs.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            if (item.discount > 0) ...[
                              Text(
                                '-${item.discount.toStringAsFixed(0)}%',
                                style: AppTextStyle.caption.withColor(cs.error),
                              ),
                              Gap.h8,
                            ],
                            Text(
                              'LKR ${item.lineTotal.toStringAsFixed(2)}',
                              style: AppTextStyle.bodySmall.medium.withColor(cs.onSurface),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
              if (q.globalDiscount > 0) ...[
                const Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sub Total',
                        style: AppTextStyle.bodySmall.withColor(cs.onSurfaceVariant),
                      ),
                      Text(
                        'LKR ${q.subTotal.toStringAsFixed(2)}',
                        style: AppTextStyle.bodySmall.withColor(cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Global Discount (${q.globalDiscount.toStringAsFixed(0)}%)',
                        style: AppTextStyle.bodySmall.withColor(cs.error),
                      ),
                      Text(
                        '- LKR ${(q.subTotal * q.globalDiscount / 100).toStringAsFixed(2)}',
                        style: AppTextStyle.bodySmall.withColor(cs.error),
                      ),
                    ],
                  ),
                ),
              ],
              if (q.notes != null && q.notes!.isNotEmpty) ...[
                const Divider(),
                Text(
                  'Notes:',
                  style: AppTextStyle.labelSmall.bold.withColor(cs.onSurface),
                ),
                Gap.v4,
                Text(
                  q.notes!,
                  style: AppTextStyle.bodySmall.italic.withColor(cs.onSurfaceVariant),
                ),
              ],
            ],

            Gap.v12,

            // Toggle Expand Button
            Center(
              child: GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isExpanded ? 'Hide Details' : 'View Details',
                      style: AppTextStyle.labelSmall.bold.withColor(AppColor.primaryDark),
                    ),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppColor.primaryDark,
                      size: 18.sp,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
