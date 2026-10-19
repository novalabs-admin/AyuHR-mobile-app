import 'package:erp_hr/app/router/app_router.dart';
import 'package:erp_hr/core/utils/colors.dart';
import 'package:erp_hr/core/utils/spacing.dart';
import 'package:erp_hr/core/utils/text_styles.dart';
import 'package:erp_hr/features/quotations/quotation_list_card.dart';
import 'package:erp_hr/shared/widget/app_floating_action_button.dart';
import 'package:erp_hr/shared/widget/app_text_field.dart';
import 'package:erp_hr/shared/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class QuotationsPage extends StatefulWidget {
  const QuotationsPage({super.key});

  @override
  State<QuotationsPage> createState() => _QuotationsPageState();
}

class _QuotationsPageState extends State<QuotationsPage> {
  String _searchQuery = '';
  String _selectedDateFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _dateFilters = const [
    'All',
    'Today',
    'Last 7 Days',
    'Last 30 Days',
  ];

  // Mock data — replace with real quotations from your cubit/repository later.
  final List<MockQuotation> _quotations = [
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
          sellingPrice: 300.00,
          discount: 0,
        ),
        const MockQuotationItem(
          itemName: 'Wellness Package',
          unitName: 'Units',
          quantity: 1,
          sellingPrice: 25000.00,
          discount: 10,
        ),
      ],
      notes: 'Please deliver before 5 PM',
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
          sellingPrice: 900.00,
          discount: 5,
        ),
      ],
    ),
    MockQuotation(
      id: 'Q-003',
      customerName: 'Nimesha Perera',
      address: 'No. 10, Kandy Road, Kadawatha',
      mobileNo: '+94 76 999 1234',
      globalDiscount: 10,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      items: [
        const MockQuotationItem(
          itemName: 'Organic Supplement',
          unitName: 'Bottle',
          quantity: 2,
          sellingPrice: 1500.00,
          discount: 0,
        ),
      ],
    ),
    MockQuotation(
      id: 'Q-004',
      customerName: 'Ravi Jayasinghe',
      address: 'No. 77, Negombo Road, Wattala',
      mobileNo: '+94 71 555 7788',
      globalDiscount: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      items: [
        const MockQuotationItem(
          itemName: 'Ahamalki 50g',
          unitName: 'Packet',
          quantity: 10,
          sellingPrice: 550.00,
          discount: 5,
        ),
      ],
    ),
  ];

  List<MockQuotation> get _filteredQuotations {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    return _quotations.where((q) {
      // Search filter
      final query = _searchQuery.toLowerCase().trim();
      final matchesSearch = query.isEmpty ||
          q.customerName.toLowerCase().contains(query) ||
          q.address.toLowerCase().contains(query) ||
          q.mobileNo.contains(query) ||
          q.id.toLowerCase().contains(query);

      // Date filter
      bool matchesDate = true;
      if (_selectedDateFilter == 'Today') {
        matchesDate = q.createdAt.isAfter(todayStart) ||
            q.createdAt.isAtSameMomentAs(todayStart);
      } else if (_selectedDateFilter == 'Last 7 Days') {
        matchesDate = q.createdAt.isAfter(now.subtract(const Duration(days: 7)));
      } else if (_selectedDateFilter == 'Last 30 Days') {
        matchesDate = q.createdAt.isAfter(now.subtract(const Duration(days: 30)));
      }

      return matchesSearch && matchesDate;
    }).toList();
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty || _selectedDateFilter != 'All';

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedDateFilter = 'All';
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = _filteredQuotations;

    return Scaffold(
      appBar: CustomAppBar(title: "Quotations"),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: AppTextField(
              controller: _searchController,
              hint: 'Search by name, phone, ID...',
              prefixIcon: Icons.search,
              onChanged: (val) => setState(() => _searchQuery = val),
              suffixIcon: _searchQuery.isNotEmpty
                  ? Icon(Icons.clear, size: 20.r, color: cs.onSurfaceVariant)
                  : null,
              onSuffixTap: _searchQuery.isNotEmpty
                  ? () {
                      setState(() => _searchQuery = '');
                      _searchController.clear();
                    }
                  : null,
            ),
          ),
          Gap.v10,
          // Date filter chips row with optional Clear button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _dateFilters.map((filter) {
                        final isSelected = _selectedDateFilter == filter;
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() => _selectedDateFilter = filter);
                            },
                            selectedColor: AppColor.primaryDark.withValues(alpha: 0.15),
                            checkmarkColor: AppColor.primaryDark,
                            labelStyle: AppTextStyle.labelSmall.copyWith(
                              color: isSelected ? AppColor.primaryDark : cs.onSurfaceVariant,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                              side: BorderSide(
                                color: isSelected ? AppColor.primaryDark : cs.outlineVariant,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                if (_hasActiveFilters) ...[
                  Gap.h8,
                  GestureDetector(
                    onTap: _clearFilters,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: cs.errorContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: cs.error.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.filter_alt_off_outlined, size: 14.sp, color: cs.error),
                          Gap.h4,
                          Text(
                            'Clear',
                            style: AppTextStyle.labelSmall.copyWith(
                              color: cs.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Gap.v8,
          // Results count row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Text(
                  '${filtered.length} ${filtered.length == 1 ? 'quotation' : 'quotations'} found',
                  style: AppTextStyle.caption.withColor(cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Gap.v6,
          // Quotations list or empty state
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_outlined,
                          size: 48.sp,
                          color: cs.onSurfaceVariant,
                        ),
                        Gap.v8,
                        Text(
                          'No quotations found matching your criteria.',
                          style: AppTextStyle.bodyMedium.withColor(cs.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        if (_hasActiveFilters) ...[
                          Gap.v12,
                          TextButton.icon(
                            onPressed: _clearFilters,
                            icon: const Icon(Icons.filter_alt_off_outlined),
                            label: const Text('Clear Filters'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return QuotationListCard(quotation: filtered[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: AppFloatingActionButton(
          heroTag: 'quotations_fab',
          onPressed: () async {
            final result = await context.pushNamed(AppRouter.createQuotation);
            if (result == true && mounted) {
              // Refresh quotations list here once wired to real data.
            }
          },
          tooltip: 'Add Quotation',
        ),
      ),
    );
  }
}
