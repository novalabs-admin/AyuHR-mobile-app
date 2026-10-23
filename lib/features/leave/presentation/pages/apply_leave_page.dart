import 'package:erp_hr/core/utils/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ApplyLeavePage extends StatefulWidget {
  const ApplyLeavePage({super.key});

  @override
  State<ApplyLeavePage> createState() => _ApplyLeavePageState();
}

class _ApplyLeavePageState extends State<ApplyLeavePage> {
  String? _selectedLeaveType;
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController _reasonController = TextEditingController();
  String? _attachmentFileName;

  final List<String> _leaveTypes = [
    'Full Day Leave',
    'Half Day Leave',
    'Short Leave',
    'Casual Leave',
    'Medical Leave',
    'Annual Leave',
  ];

  int get _calculatedDays {
    if (_fromDate == null || _toDate == null) return 0;
    if (_toDate!.isBefore(_fromDate!)) return 0;
    return _toDate!.difference(_fromDate!).inDays + 1;
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2027),
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
        _fromDate = picked;
        if (_toDate != null && _toDate!.isBefore(_fromDate!)) {
          _toDate = _fromDate;
        }
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? _fromDate ?? DateTime.now(),
      firstDate: _fromDate ?? DateTime(2025),
      lastDate: DateTime(2027),
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
        _toDate = picked;
      });
    }
  }

  void _showLeaveTypePicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
            child: SingleChildScrollView(
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
                  Text(
                    'Select Leave Type',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Gap.v8,
                  ..._leaveTypes.map((type) {
                    final isSelected = _selectedLeaveType == type;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedLeaveType = type;
                        });
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(10.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 4.w,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              type,
                              style: TextStyle(
                                fontSize: 14.5.sp,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? const Color(0xFF045C2C)
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF045C2C),
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitLeaveRequest() {
    if (_selectedLeaveType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a leave type.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    if (_fromDate == null || _toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select from and to dates.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    // Success response
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Leave request submitted successfully!'),
        backgroundColor: Color(0xFF045C2C),
      ),
    );

    Navigator.pop(context, {
      'type': _selectedLeaveType,
      'fromDate': _fromDate,
      'toDate': _toDate,
      'days': _calculatedDays,
      'reason': _reasonController.text,
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy');

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
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 32.r,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    'Apply Leave',
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
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 40.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Leave Type
                      Text(
                        'Leave Type',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Gap.v8,
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _showLeaveTypePicker,
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 14.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedLeaveType ?? 'Select Leave Type',
                                  style: TextStyle(
                                    fontSize: 13.5.sp,
                                    color: _selectedLeaveType != null
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: const Color(0xFF64748B),
                                  size: 22.r,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Gap.v16,

                      // 2. From Date & To Date
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'From Date',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Gap.v8,
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _pickFromDate,
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14.w,
                                        vertical: 14.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            size: 16.r,
                                            color: const Color(0xFF64748B),
                                          ),
                                          Gap.h8,
                                          Expanded(
                                            child: Text(
                                              _fromDate != null
                                                  ? dateFormat
                                                      .format(_fromDate!)
                                                  : 'Select Date',
                                              style: TextStyle(
                                                fontSize: 12.5.sp,
                                                color: _fromDate != null
                                                    ? const Color(0xFF0F172A)
                                                    : const Color(0xFF94A3B8),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Gap.h12,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'To Date',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Gap.v8,
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _pickToDate,
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14.w,
                                        vertical: 14.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            size: 16.r,
                                            color: const Color(0xFF64748B),
                                          ),
                                          Gap.h8,
                                          Expanded(
                                            child: Text(
                                              _toDate != null
                                                  ? dateFormat.format(_toDate!)
                                                  : 'Select Date',
                                              style: TextStyle(
                                                fontSize: 12.5.sp,
                                                color: _toDate != null
                                                    ? const Color(0xFF0F172A)
                                                    : const Color(0xFF94A3B8),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Gap.v16,

                      // 3. Total Days (Read-only)
                      Text(
                        'Total Days',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Gap.v8,
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '$_calculatedDays '
                          '${_calculatedDays == 1 ? 'day' : 'days'}',
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Gap.v16,

                      // 4. Reason for Leave
                      Text(
                        'Reason for Leave',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Gap.v8,
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: TextField(
                          controller: _reasonController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Enter reason for leave...',
                            hintStyle: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF94A3B8),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(14.r),
                          ),
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Gap.v16,

                      // 5. Attachment (Optional)
                      Row(
                        children: [
                          Text(
                            'Attachment',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Gap.h4,
                          Text(
                            '(Optional)',
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      Gap.v8,
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _attachmentFileName =
                                  'medical_certificate_2026.pdf';
                            });
                          },
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF8F2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  color: const Color(0xFF045C2C),
                                  size: 24.r,
                                ),
                                Gap.h12,
                                Expanded(
                                  child: Text(
                                    _attachmentFileName ??
                                        'Upload File (PDF, JPG, PNG)',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: _attachmentFileName != null
                                          ? const Color(0xFF045C2C)
                                          : const Color(0xFF64748B),
                                      fontWeight: _attachmentFileName != null
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Gap.v24,

                      // 6. Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: _submitLeaveRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF045C2C),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            'Submit Leave Request',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
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
}
