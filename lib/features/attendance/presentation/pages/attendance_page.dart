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
    required this.checkIn,
    required this.checkOut,
    required this.workingHours,
    this.note,
  });

  final DateTime date;
  final DayAttendanceStatus status;
  final String checkIn;
  final String checkOut;
  final String workingHours;
  final String? note;
}

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;
  String _selectedFilter = 'This Month';

  // Mock attendance data mapping (day number in month -> record)
  final Map<int, AttendanceRecord> _mockOctoberRecords = {
    4: AttendanceRecord(
      date: DateTime(2026, 10, 4),
      status: DayAttendanceStatus.absent,
      checkIn: '—',
      checkOut: '—',
      workingHours: '0h 00m',
      note: 'Unplanned Absence • Shift Missed',
    ),
    9: AttendanceRecord(
      date: DateTime(2026, 10, 9),
      status: DayAttendanceStatus.present,
      checkIn: '08:15 AM',
      checkOut: '05:02 PM',
      workingHours: '8h 47m',
      note: 'Regular Shift',
    ),
    10: AttendanceRecord(
      date: DateTime(2026, 10, 10),
      status: DayAttendanceStatus.leave,
      checkIn: '—',
      checkOut: '—',
      workingHours: '0h 00m',
      note: 'Approved Casual Leave • Full Day',
    ),
    11: AttendanceRecord(
      date: DateTime(2026, 10, 11),
      status: DayAttendanceStatus.leave,
      checkIn: '—',
      checkOut: '—',
      workingHours: '0h 00m',
      note: 'Approved Casual Leave • Full Day',
    ),
    13: AttendanceRecord(
      date: DateTime(2026, 10, 13),
      status: DayAttendanceStatus.present,
      checkIn: '08:02 AM',
      checkOut: '05:15 PM',
      workingHours: '8h 13m',
      note: 'Regular Shift • On Time',
    ),
    16: AttendanceRecord(
      date: DateTime(2026, 10, 16),
      status: DayAttendanceStatus.present,
      checkIn: '08:10 AM',
      checkOut: '05:00 PM',
      workingHours: '8h 50m',
      note: 'Regular Shift',
    ),
    18: AttendanceRecord(
      date: DateTime(2026, 10, 18),
      status: DayAttendanceStatus.leave,
      checkIn: '—',
      checkOut: '—',
      workingHours: '0h 00m',
      note: 'Approved Medical Leave',
    ),
    25: AttendanceRecord(
      date: DateTime(2026, 10, 25),
      status: DayAttendanceStatus.absent,
      checkIn: '—',
      checkOut: '—',
      workingHours: '0h 00m',
      note: 'Unplanned Absence',
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
      _selectedFilter = '';
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + 1,
      );
      _selectedFilter = '';
    });
  }

  DayAttendanceStatus _getStatusForDay(int day, int weekday) {
    if (_currentMonth.year == 2026 && _currentMonth.month == 10) {
      if (_mockOctoberRecords.containsKey(day)) {
        return _mockOctoberRecords[day]!.status;
      }
    }

    // Weekends (Saturday = 6, Sunday = 7) are Off Days
    if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
      return DayAttendanceStatus.offDay;
    }

    return DayAttendanceStatus.normal;
  }

  Future<void> _selectCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2027),
      initialDateRange: DateTimeRange(
        start: DateTime(_currentMonth.year, _currentMonth.month),
        end: DateTime(_currentMonth.year, _currentMonth.month + 1, 0),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF045C2C),
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedFilter = 'Custom Range';
        _currentMonth = DateTime(picked.start.year, picked.start.month);
      });
    }
  }

  void _showMonthYearPicker() {
    var tempYear = _currentMonth.year;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            const months = [
              'Jan',
              'Feb',
              'Mar',
              'Apr',
              'May',
              'Jun',
              'Jul',
              'Aug',
              'Sep',
              'Oct',
              'Nov',
              'Dec',
            ];
            return Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  Gap.v16,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setModalState(() => tempYear--);
                        },
                      ),
                      Text(
                        '$tempYear',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setModalState(() => tempYear++);
                        },
                      ),
                    ],
                  ),
                  Gap.v16,
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final isCurrent = _currentMonth.year == tempYear &&
                          _currentMonth.month == index + 1;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _currentMonth = DateTime(tempYear, index + 1);
                            _selectedFilter = '';
                          });
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? const Color(0xFF045C2C)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            months[index],
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isCurrent
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF045C2C),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top App Bar (Dark Forest Green) ──
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

            // ── Main Container: Clean White Card Overlay ──
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
                      // ── Calendar Header: Rounded Chip / Dropdown + Flanking Navigation Arrows ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Subtle navigation arrow (<)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _previousMonth,
                              borderRadius: BorderRadius.circular(12.r),
                              child: Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Icon(
                                  Icons.chevron_left,
                                  color: const Color(0xFF045C2C),
                                  size: 22.r,
                                ),
                              ),
                            ),
                          ),

                          // Clickable Month & Year selector chip
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _showMonthYearPicker,
                              borderRadius: BorderRadius.circular(24.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 18.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(24.r),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat('MMMM yyyy')
                                          .format(_currentMonth),
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    Gap.h6,
                                    Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: const Color(0xFF045C2C),
                                      size: 22.r,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Subtle navigation arrow (>)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _nextMonth,
                              borderRadius: BorderRadius.circular(12.r),
                              child: Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Icon(
                                  Icons.chevron_right,
                                  color: const Color(0xFF045C2C),
                                  size: 22.r,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Gap.v12,

                      // ── Quick Filter Chips ──
                      Row(
                        children: [
                          _buildFilterChip(
                            label: 'This Month',
                            isSelected: _selectedFilter == 'This Month',
                            onTap: () {
                              setState(() {
                                _selectedFilter = 'This Month';
                                _currentMonth = DateTime(2026, 10);
                              });
                            },
                          ),
                          Gap.h8,
                          _buildFilterChip(
                            label: 'Last Month',
                            isSelected: _selectedFilter == 'Last Month',
                            onTap: () {
                              setState(() {
                                _selectedFilter = 'Last Month';
                                _currentMonth = DateTime(2026, 9);
                              });
                            },
                          ),
                          Gap.h8,
                          _buildFilterChip(
                            label: 'Custom Range',
                            isSelected: _selectedFilter == 'Custom Range',
                            onTap: _selectCustomRange,
                          ),
                        ],
                      ),
                      Gap.v20,

                      // ── Summary Metrics: Row of 4 Stat Cards ──
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

                      // ── Monthly Calendar Grid ──
                      _buildCalendarView(),
                      Gap.v16,

                      // ── Divider ──
                      const Divider(
                        color: Color(0xFFF1F5F9),
                        thickness: 1,
                        height: 1,
                      ),
                      Gap.v16,

                      // ── Status Legend: Horizontal indicator dots ──
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

                      // ── List Section: Modern Attendance Details Cards ──
                      _buildAttendanceCardsList(),
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

  // ── Filter Chip Component ──
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 7.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF045C2C)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF045C2C)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ),
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

                      // Weekday for this day
                      final weekday = DateTime(year, month, dayNumber).weekday;
                      return _buildDayCell(dayNumber, weekday);
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
  Widget _buildDayCell(int day, int weekday) {
    final status = _getStatusForDay(day, weekday);
    final isSelected = _selectedDate.year == _currentMonth.year &&
        _selectedDate.month == _currentMonth.month &&
        _selectedDate.day == day;

    // October 13 highlighted with a distinct forest green rounded border
    final isToday = _currentMonth.year == 2026 &&
        _currentMonth.month == 10 &&
        day == 13;

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
            DayAttendanceStatus.offDay => (
                const Color(0xFFF1F5F9),
                const Color(0xFF94A3B8)
              ),
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
          border: isToday
              ? Border.all(
                  color: isSelected ? Colors.white : const Color(0xFF045C2C),
                  width: 2.r,
                )
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: isSelected ||
                      isToday ||
                      status != DayAttendanceStatus.normal
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
        _buildLegendItem('Absent', const Color(0xFFEF4444)),
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

  // ── Attendance Details List Section with High-Fidelity Cards ──
  Widget _buildAttendanceCardsList() {
    final records = [
      AttendanceRecord(
        date: DateTime(2026, 10, 13),
        status: DayAttendanceStatus.present,
        checkIn: '08:02 AM',
        checkOut: '05:15 PM',
        workingHours: '8h 13m',
        note: 'Regular Shift • On Time',
      ),
      AttendanceRecord(
        date: DateTime(2026, 10, 11),
        status: DayAttendanceStatus.leave,
        checkIn: '—',
        checkOut: '—',
        workingHours: '0h 00m',
        note: 'Approved Casual Leave • Full Day',
      ),
      AttendanceRecord(
        date: DateTime(2026, 10, 10),
        status: DayAttendanceStatus.leave,
        checkIn: '—',
        checkOut: '—',
        workingHours: '0h 00m',
        note: 'Approved Casual Leave • Full Day',
      ),
      AttendanceRecord(
        date: DateTime(2026, 10, 9),
        status: DayAttendanceStatus.present,
        checkIn: '08:15 AM',
        checkOut: '05:02 PM',
        workingHours: '8h 47m',
        note: 'Regular Shift',
      ),
      AttendanceRecord(
        date: DateTime(2026, 10, 4),
        status: DayAttendanceStatus.absent,
        checkIn: '—',
        checkOut: '—',
        workingHours: '0h 00m',
        note: 'Unplanned Absence • Shift Missed',
      ),
    ];

    return Column(
      children: records.map((record) {
        final isSelected = _selectedDate.day == record.date.day &&
            _selectedDate.month == record.date.month &&
            _selectedDate.year == record.date.year;

        final isToday = record.date.year == 2026 &&
            record.date.month == 10 &&
            record.date.day == 13;

        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF045C2C)
                    : const Color(0xFFE2E8F0),
                width: isSelected ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? const Color(0xFF045C2C).withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Date & Status Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          DateFormat('d MMM yyyy').format(record.date),
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        if (isToday) ...[
                          Gap.h8,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'Today',
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF045C2C),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    _buildStatusPill(record.status),
                  ],
                ),
                Gap.v12,

                // Check-in / Check-out metrics or Note
                if (record.status == DayAttendanceStatus.present) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          label: 'Check-In',
                          value: record.checkIn,
                          icon: Icons.login_rounded,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                      Container(
                        height: 28.h,
                        width: 1,
                        color: const Color(0xFFE2E8F0),
                      ),
                      Expanded(
                        child: _buildMetricItem(
                          label: 'Check-Out',
                          value: record.checkOut,
                          icon: Icons.logout_rounded,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                      Container(
                        height: 28.h,
                        width: 1,
                        color: const Color(0xFFE2E8F0),
                      ),
                      Expanded(
                        child: _buildMetricItem(
                          label: 'Hours',
                          value: record.workingHours,
                          icon: Icons.timer_outlined,
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Icon(
                        record.status == DayAttendanceStatus.leave
                            ? Icons.description_outlined
                            : Icons.cancel_outlined,
                        size: 16.r,
                        color: record.status == DayAttendanceStatus.leave
                            ? const Color(0xFFB45309)
                            : const Color(0xFFDC2626),
                      ),
                      Gap.h8,
                      Expanded(
                        child: Text(
                          record.note ?? '—',
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13.r, color: color),
            Gap.h4,
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Gap.v4,
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
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
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
