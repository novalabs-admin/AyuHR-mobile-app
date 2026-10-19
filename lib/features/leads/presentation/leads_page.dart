import 'package:erp_hr/app/router/app_router.dart';
import 'package:erp_hr/core/utils/colors.dart';
import 'package:erp_hr/core/utils/spacing.dart';
import 'package:erp_hr/core/utils/text_styles.dart';
import 'package:erp_hr/features/leads/presentation/lead_list_card.dart';
import 'package:erp_hr/shared/widget/app_floating_action_button.dart';
import 'package:erp_hr/shared/widget/app_text_field.dart';
import 'package:erp_hr/shared/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LeadsPage extends StatefulWidget {
  const LeadsPage({super.key});

  @override
  State<LeadsPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends State<LeadsPage> {
  String _searchQuery = '';
  String _selectedStatus = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _statuses = const [
    'All',
    'New',
    'Contacted',
    'Visited',
    'Won',
    'Lost',
  ];

  // Mock data — replace with real leads from your cubit/repository later.
  final List<MockLead> _leads = [
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
      customerName: 'Nimal Fernando',
      address: 'No. 8, Negombo Road, Wattala',
      mobileNo: '+94 76 555 1234',
      currentStatus: 4,
      currentStatusName: 'Visited',
      sumAssured: 45000,
      visits: [
        MockVisit(
          status: 1,
          reason: 'Interested',
          createdAt: DateTime.now().toIso8601String(),
        ),
      ],
    ),
    MockLead(
      customerName: 'Kamala Jayawardena',
      address: 'No. 33, High Level Road, Nugegoda',
      mobileNo: '+94 75 222 9090',
      currentStatus: 5,
      currentStatusName: 'Won',
      sumAssured: 80000,
    ),
    MockLead(
      customerName: 'Roshan Bandara',
      address: 'No. 7, Main Street, Kurunegala',
      mobileNo: '+94 78 444 3333',
      currentStatus: 6,
      currentStatusName: 'Lost',
      sumAssured: 20000,
    ),
  ];

  List<MockLead> get _filteredLeads {
    return _leads.where((lead) {
      final query = _searchQuery.toLowerCase().trim();
      final matchesSearch = query.isEmpty ||
          lead.customerName.toLowerCase().contains(query) ||
          lead.address.toLowerCase().contains(query) ||
          lead.mobileNo.contains(query);

      final matchesStatus = _selectedStatus == 'All' ||
          lead.currentStatusName?.toLowerCase() == _selectedStatus.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty || _selectedStatus != 'All';

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedStatus = 'All';
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
    final filtered = _filteredLeads;

    return Scaffold(
      appBar: CustomAppBar(title: "Leads"),
      body: Column(
        children: [
          // Search & Filter header
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: AppTextField(
              controller: _searchController,
              hint: 'Search by name, address or contact...',
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
          // Status chips row with optional Clear button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _statuses.map((status) {
                        final isSelected = _selectedStatus == status;
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: FilterChip(
                            label: Text(status),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() => _selectedStatus = status);
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
                  '${filtered.length} ${filtered.length == 1 ? 'lead' : 'leads'} found',
                  style: AppTextStyle.caption.withColor(cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Gap.v6,
          // Leads list or empty state
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_outlined, size: 48.sp, color: cs.onSurfaceVariant),
                        Gap.v8,
                        Text(
                          'No leads found matching your criteria.',
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
                      return LeadListCard(lead: filtered[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: AppFloatingActionButton(
          heroTag: 'leads_fab',
          onPressed: () async {
            final result = await context.pushNamed(AppRouter.createLead);
            if (result == true && mounted) {
              // Refresh leads list here once wired to real data.
            }
          },
          tooltip: 'Add Lead',
        ),
      ),
    );
  }
}