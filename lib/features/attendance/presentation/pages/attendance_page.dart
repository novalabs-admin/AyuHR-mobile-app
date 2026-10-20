import 'package:erp_hr/core/utils/constants.dart';
import 'package:erp_hr/core/utils/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

enum DayAttendanceStatus {
  present,
  leave,
  absent,
  offDay,
  normal,
}

class AttendanceRecord {
  const AttendanceRecord({
    required this.date,
    required this.status,
    required this.timeRange,
  });

  final DateTime date;
  final DayAttendanceStatus status;
  final String timeRange;
}

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  // Mock attendance data mapping (day number in month -> status & time)
  final Map<int, AttendanceRecord> _mockOctoberRecords = {
    4: AttendanceRecord(
      date: DateTime(2026, 10, 4),
      status: DayAttendanceStatus.absent,
      timeRange: '—',
    ),
    9: AttendanceRecord(
      date: DateTime(2026, 10, 9),
      status: DayAttendanceStatus.present,
      timeRange: '08:15 AM - 05:02 PM',
    ),
    10: AttendanceRecord(
      date: DateTime(2026, 10, 10),
      status: DayAttendanceStatus.leave,
      timeRange: '—',
    ),
    11: AttendanceRecord(
      date: DateTime(2026, 10, 11),
      status: DayAttendanceStatus.leave,
      timeRange: '—',
    ),
    13: AttendanceRecord(
      date: DateTime(2026, 10, 13),
      status: DayAttendanceStatus.present,
      timeRange: '08:02 AM - 05:15 PM',
    ),
    16: AttendanceRecord(
      date: DateTime(2026, 10, 16),
      status: DayAttendanceStatus.present,
      timeRange: '08:10 AM - 05:00 PM',
    ),
    18: AttendanceRecord(
      date: DateTime(2026, 10, 18),
      status: DayAttendanceStatus.leave,
      timeRange: '—',
    ),
    25: AttendanceRecord(
      date: DateTime(2026, 10, 25),
      status: DayAttendanceStatus.absent,
      timeRange: '—',
    ),
  };

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(2026, 10);
    _selectedDate = DateTime(2026, 10, 13);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + 1,
      );
    });
  }

  DayAttendanceStatus _getStatusForDay(int day) {
    if (_currentMonth.year == 2026 && _currentMonth.month == 10) {
      return _mockOctoberRecords[day]?.status ?? DayAttendanceStatus.normal;
    }
    return DayAttendanceStatus.normal;
  }

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
                      size: 28.r,
                    ),
                    onPressed: () {
                      mainScaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  Text(
                    'Attendance Report',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.5.sp,
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

            // ── Main White Content Container ──
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
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Month Selector ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.chevron_left,
                              color: const Color(0xFF045C2C),
                              size: 28.r,
                            ),
                            onPressed: _previousMonth,
                          ),
                          Text(
                            DateFormat('MMMM yyyy').format(_currentMonth),
                            style: TextStyle(
                              fontSize: 16.5.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.chevron_right,
                              color: const Color(0xFF045C2C),
                              size: 28.r,
                            ),
                            onPressed: _nextMonth,
                          ),
                        ],
                      ),
                      Gap.v16,

                      // ── 4 Summary Stat Cards ──
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'Working',
                              value: '20',
                              valueColor: const Color(0xFF0F172A),
                              bgColor: const Color(0xFFF1F5F9),
                            ),
                          ),
                          Gap.h8,
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'Present',
                              value: '16',
                              valueColor: const Color(0xFF047857),
                              bgColor: const Color(0xFFE6F7ED),
                            ),
                          ),
                          Gap.h8,
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'Leave',
                              value: '3',
                              valueColor: const Color(0xFFB45309),
                              bgColor: const Color(0xFFFEF3E2),
                            ),
                          ),
                          Gap.h8,
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'Absent',
                              value: '1',
                              valueColor: const Color(0xFFDC2626),
                              bgColor: const Color(0xFFFDE8E8),
                            ),
                          ),
                        ],
                      ),
                      Gap.v24,

                      // ── Section Title: Monthly Calendar ──
                      Text(
                        'Monthly Calendar',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Gap.v16,

                      // ── Calendar Grid ──
                      _buildCalendarView(),
                      Gap.v16,

                      // ── Divider ──
                      const Divider(
                        color: Color(0xFFF1F5F9),
                        thickness: 1,
                        height: 1,
                      ),
                      Gap.v16,

                      // ── Status Legend ──
                      _buildLegendRow(),
                      Gap.v24,

                      // ── Section Title: Attendance Details ──
                      Text(
                        'Attendance Details',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Gap.v12,

                      // ── Attendance Details List ──
                      _buildAttendanceDetailsList(),
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

  // ── Stat Card Component ──
  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color valueColor,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          Gap.v6,
          Text(
            value,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── Calendar Grid View ──
  Widget _buildCalendarView() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final year = _currentMonth.year;
    final month = _currentMonth.month;
    final totalDaysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month).weekday; // 1 = Mon, 7 = Sun
    final leadingBlanks = firstWeekday - 1;

    final totalCells = leadingBlanks + totalDaysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return Column(
      children: [
        // Weekdays Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekdays.map((day) {
            return SizedBox(
              width: 40.w,
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        Gap.v10,

        // Calendar Day Rows
        for (int r = 0; r < rowCount; r++) ...[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (int c = 0; c < 7; c++) ...[
                  Builder(
                    builder: (context) {
                      final cellIndex = r * 7 + c;
                      final dayNumber = cellIndex - leadingBlanks + 1;

                      if (dayNumber < 1 || dayNumber > totalDaysInMonth) {
                        return SizedBox(
                          width: 40.w,
                          height: 40.w,
                        );
                      }

                      return _buildDayCell(dayNumber);
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Single Day Cell ──
  Widget _buildDayCell(int day) {
    final status = _getStatusForDay(day);
    final isSelected = _selectedDate.year == _currentMonth.year &&
        _selectedDate.month == _currentMonth.month &&
        _selectedDate.day == day;

    final (bgColor, textColor) = isSelected
        ? (const Color(0xFF045C2C), Colors.white)
        : switch (status) {
            DayAttendanceStatus.present => (
                const Color(0xFFD1FAE5),
                const Color(0xFF065F46)
              ),
            DayAttendanceStatus.leave => (
                const Color(0xFFFEF3C7),
                const Color(0xFF92400E)
              ),
            DayAttendanceStatus.absent => (
                const Color(0xFFFDE8E8),
                const Color(0xFFB91C1C)
              ),
            DayAttendanceStatus.offDay ||
            DayAttendanceStatus.normal => (
                Colors.transparent,
                const Color(0xFF1E293B)
              ),
          };

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = DateTime(
            _currentMonth.year,
            _currentMonth.month,
            day,
          );
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: isSelected || status != DayAttendanceStatus.normal
                  ? FontWeight.bold
                  : FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  // ── Status Legend Row ──
  Widget _buildLegendRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLegendItem('Present', const Color(0xFF16A34A)),
        _buildLegendItem('Leave', const Color(0xFFF59E0B)),
        _buildLegendItem('Absent', const Color(0xFFF43F5E)),
        _buildLegendItem('Off Day', const Color(0xFF94A3B8)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        Gap.h6,
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── Attendance Details List ──
  Widget _buildAttendanceDetailsList() {
    // Collect the records for October 2026 ordered from selected / recent
    final records = [
      AttendanceRecord(
        date: DateTime(2026, 10, 13),
        status: DayAttendanceStatus.present,
        timeRange: '08:02 AM - 05:15 PM',
      ),
      AttendanceRecord(
        date: DateTime(2026, 10, 11),
        status: DayAttendanceStatus.leave,
        timeRange: '—',
      ),
      AttendanceRecord(
        date: DateTime(2026, 10, 10),
        status: DayAttendanceStatus.leave,
        timeRange: '—',
      ),
      AttendanceRecord(
        date: DateTime(2026, 10, 9),
        status: DayAttendanceStatus.present,
        timeRange: '08:15 AM - 05:00 PM',
      ),
      AttendanceRecord(
        date: DateTime(2026, 10, 4),
        status: DayAttendanceStatus.absent,
        timeRange: '—',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: records.map((record) {
          final isSelected = _selectedDate.day == record.date.day &&
              _selectedDate.month == record.date.month &&
              _selectedDate.year == record.date.year;

          return Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF045C2C).withValues(alpha: 0.05)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    // Date
                    Expanded(
                      flex: 4,
                      child: Text(
                        DateFormat('d MMM yyyy').format(record.date),
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          color: const Color(0xFF334155),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),

                    // Status Pill
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: _buildStatusPill(record.status),
                      ),
                    ),

                    // Time or Dash
                    Expanded(
                      flex: 4,
                      child: Text(
                        record.timeRange,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                color: Color(0xFFF1F5F9),
                height: 1,
                thickness: 1,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusPill(DayAttendanceStatus status) {
    final (bgColor, textColor, label) = switch (status) {
      DayAttendanceStatus.present => (
          const Color(0xFFE6F7ED),
          const Color(0xFF047857),
          'Present'
        ),
      DayAttendanceStatus.leave => (
          const Color(0xFFFEF3E2),
          const Color(0xFFB45309),
          'Leave'
        ),
      DayAttendanceStatus.absent => (
          const Color(0xFFFDE8E8),
          const Color(0xFFDC2626),
          'Absent'
        ),
      DayAttendanceStatus.offDay => (
          const Color(0xFFF1F5F9),
          const Color(0xFF64748B),
          'Off Day'
        ),
      DayAttendanceStatus.normal => (
          const Color(0xFFF1F5F9),
          const Color(0xFF64748B),
          'Regular'
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
