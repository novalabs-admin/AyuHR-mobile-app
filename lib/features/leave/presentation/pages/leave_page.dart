import 'package:erp_hr/core/utils/constants.dart';
import 'package:erp_hr/core/utils/spacing.dart';
import 'package:erp_hr/features/leave/presentation/pages/apply_leave_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

enum LeaveStatus {
  pending,
  approved,
  rejected,
}

class LeaveItem {
  LeaveItem({
    required this.title,
    required this.dateRange,
    required this.daysCount,
    required this.status,
    this.reason,
  });

  final String title;
  final String dateRange;
  final int daysCount;
  final LeaveStatus status;
  final String? reason;
}

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  int _selectedFilterIndex = 0; // 0 = All, 1 = Pending, 2 = Approved

  final List<LeaveItem> _leaveRequests = [
    LeaveItem(
      title: 'Full Day Leave',
      dateRange: '20–22 Oct 2026',
      daysCount: 3,
      status: LeaveStatus.pending,
      reason: 'Personal family event attendance.',
    ),
    LeaveItem(
      title: 'Half Day Leave',
      dateRange: '10–11 Oct 2026',
      daysCount: 2,
      status: LeaveStatus.approved,
      reason: 'Doctor consultation & medical checkup.',
    ),
    LeaveItem(
      title: 'Short Leave',
      dateRange: '24 Sep 2026',
      daysCount: 1,
      status: LeaveStatus.approved,
      reason: 'Urgent personal work in afternoon.',
    ),
  ];

  List<LeaveItem> get _filteredLeaves {
    if (_selectedFilterIndex == 1) {
      return _leaveRequests
          .where((l) => l.status == LeaveStatus.pending)
          .toList();
    } else if (_selectedFilterIndex == 2) {
      return _leaveRequests
          .where((l) => l.status == LeaveStatus.approved)
          .toList();
    }
    return _leaveRequests;
  }

  Future<void> _navigateApplyLeave() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const ApplyLeavePage()),
    );

    if (result != null && mounted) {
      final type = result['type'] as String? ?? 'Leave';
      final fromDate = result['fromDate'] as DateTime?;
      final toDate = result['toDate'] as DateTime?;
      final days = result['days'] as int? ?? 1;
      final reason = result['reason'] as String?;

      final dateFormat = DateFormat('d MMM');
      final yearFormat = DateFormat('yyyy');
      final dateRangeStr = fromDate != null && toDate != null
          ? (fromDate == toDate
              ? DateFormat('d MMM yyyy').format(fromDate)
              : '${dateFormat.format(fromDate)}–'
                  '${dateFormat.format(toDate)} '
                  '${yearFormat.format(toDate)}')
          : 'Pending Date';

      setState(() {
        _leaveRequests.insert(
          0,
          LeaveItem(
            title: type,
            dateRange: dateRangeStr,
            daysCount: days,
            status: LeaveStatus.pending,
            reason: reason,
          ),
        );
      });
    }
  }

  void _showLeaveDetails(LeaveItem item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Gap.v16,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  _buildStatusPill(item.status),
                ],
              ),
              Gap.v16,
              _buildDetailRow('Dates', item.dateRange),
              Gap.v10,
              _buildDetailRow(
                'Duration',
                '${item.daysCount} ${item.daysCount == 1 ? 'day' : 'days'}',
              ),
              Gap.v10,
              _buildDetailRow('Reason', item.reason ?? 'No reason provided.'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Gap.h8,
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.5.sp,
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const availableCount = 12;
    const usedCount = 6;
    final pendingCount =
        _leaveRequests.where((l) => l.status == LeaveStatus.pending).length;

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
                      size: 28.r,
                    ),
                    onPressed: () {
                      mainScaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  Text(
                    'Leave List',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
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
            ),
            Gap.v6,

            // ── Main Content Container ──
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28.r),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 120.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header Row: "My Leaves" + "+ Apply" ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Leaves',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Gap.v2,
                              Text(
                                'Track your leave requests',
                                style: TextStyle(
                                  fontSize: 12.5.sp,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _navigateApplyLeave,
                              borderRadius: BorderRadius.circular(20.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF045C2C),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  '+ Apply',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Gap.v16,

                      // ── 3 Summary KPI Cards ──
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              value: '$availableCount',
                              label: 'Available',
                              valueColor: const Color(0xFF047857),
                              labelColor: const Color(0xFF047857),
                              bgColor: const Color(0xFFE6F7ED),
                            ),
                          ),
                          Gap.h12,
                          Expanded(
                            child: _buildMetricCard(
                              value: '$usedCount',
                              label: 'Used',
                              valueColor: const Color(0xFF334155),
                              labelColor: const Color(0xFF64748B),
                              bgColor: const Color(0xFFEEF2F6),
                            ),
                          ),
                          Gap.h12,
                          Expanded(
                            child: _buildMetricCard(
                              value: '$pendingCount',
                              label: 'Pending',
                              valueColor: const Color(0xFFB45309),
                              labelColor: const Color(0xFFB45309),
                              bgColor: const Color(0xFFFEF3E2),
                            ),
                          ),
                        ],
                      ),
                      Gap.v20,

                      // ── Filter Segmented Control Tabs ──
                      Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Row(
                          children: [
                            _buildSegmentTab(0, 'All'),
                            _buildSegmentTab(1, 'Pending'),
                            _buildSegmentTab(2, 'Approved'),
                          ],
                        ),
                      ),
                      Gap.v20,

                      // ── Leave Request Cards List ──
                      if (_filteredLeaves.isEmpty) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.h),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 40.r,
                                  color: const Color(0xFF94A3B8),
                                ),
                                Gap.v10,
                                Text(
                                  'No leave requests found',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        ..._filteredLeaves.map(_buildLeaveCard),
                      ],
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

  Widget _buildMetricCard({
    required String value,
    required String label,
    required Color valueColor,
    required Color labelColor,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          Gap.v4,
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentTab(int index, String label) {
    final isSelected = _selectedFilterIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilterIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF045C2C)
                  : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveCard(LeaveItem item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(14.r),
              child: Row(
                children: [
                  Container(
                    width: 42.r,
                    height: 42.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.grid_view_rounded,
                      color: const Color(0xFF045C2C),
                      size: 20.r,
                    ),
                  ),
                  Gap.h12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Gap.v2,
                        Text(
                          item.dateRange,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusPill(item.status),
                ],
              ),
            ),
            const Divider(
              color: Color(0xFFF1F5F9),
              height: 1,
              thickness: 1,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.daysCount} '
                    '${item.daysCount == 1 ? 'day' : 'days'} '
                    'requested',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  InkWell(
                    onTap: () => _showLeaveDetails(item),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View Details ›',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF045C2C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(LeaveStatus status) {
    final (bgColor, textColor, label) = switch (status) {
      LeaveStatus.pending => (
          const Color(0xFFFEF3E2),
          const Color(0xFFB45309),
          'Pending'
        ),
      LeaveStatus.approved => (
          const Color(0xFFE6F7ED),
          const Color(0xFF047857),
          'Approved'
        ),
      LeaveStatus.rejected => (
          const Color(0xFFFDE8E8),
          const Color(0xFFDC2626),
          'Rejected'
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
