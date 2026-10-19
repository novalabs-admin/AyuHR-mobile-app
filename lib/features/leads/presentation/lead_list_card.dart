import 'package:erp_hr/core/utils/colors.dart';
import 'package:erp_hr/core/utils/spacing.dart';
import 'package:erp_hr/core/utils/text_styles.dart';
import 'package:erp_hr/shared/widget/app_button.dart';
import 'package:erp_hr/shared/widget/app_confirmation_dialog.dart';
import 'package:erp_hr/shared/widget/app_date_time_picker.dart';
import 'package:erp_hr/shared/widget/app_dropdown_field.dart';
import 'package:erp_hr/shared/widget/app_snack_bar.dart';
import 'package:erp_hr/shared/widget/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';


/// ─────────────────────────────────────────────────────────────────────────
/// UI-ONLY VERSION of LeadListCard.
///
/// All data-layer wiring has been removed / replaced with local mock state:
///   • No LeadsCubit / AppointmentCubit / PlansCubit / AuthCubit
///   • No BlocListener / BlocBuilder / context.read<...>()
///   • No context.push() navigation to other real routes
///   • No url_launcher phone calls or GoogleMaps location picker
///   • No backend calls for appointments / visits / lead status
///
/// Everything the card actually DOES (mark contacted, create appointment,
/// update visit, close lead, edit, convert to quotation) now just mutates
/// local State and shows a snackbar, so the whole card can be dropped into
/// a screen and previewed/styled without any dependency on your data layer.
/// ─────────────────────────────────────────────────────────────────────────

// ── Mock domain models (stand-ins for your real Lead / Appointment / Visit) ──

class MockVisit {
  MockVisit({
    required this.status, // 1 = Visited, 2 = Not Visited
    required this.reason,
    required this.createdAt,
  });
  final int status;
  final String reason;
  final String createdAt; // ISO-ish date string
}

class MockAppointment {
  MockAppointment({
    required this.dateTime,
    required this.status, // 1 = Pending, 2 = Rescheduled, 3 = Visited
    this.locationName,
    this.otherContactName,
    this.otherContactNo,
  });
  final String dateTime;
  final int status;
  final String? locationName;
  final String? otherContactName;
  final String? otherContactNo;
}

class MockLead {
  MockLead({
    required this.customerName,
    required this.address,
    required this.mobileNo,
    required this.currentStatus,
    this.currentStatusName,
    this.sumAssured = 0,
    this.planIds = const [],
    List<MockVisit>? visits,
    List<MockAppointment>? appointments,
  })  : visits = visits ?? [],
        appointments = appointments ?? [];

  final String customerName;
  final String address;
  final String mobileNo;
  int currentStatus; // 1 New, 2 Contacted, 3 Appointment Set, 4 Visited, 5 Won, 6 Lost
  String? currentStatusName;
  final double sumAssured;
  final List<int> planIds;
  final List<MockVisit> visits;
  final List<MockAppointment> appointments;
}

class LeadListCard extends StatefulWidget {
  const LeadListCard({required this.lead, super.key});
  final MockLead lead;

  @override
  State<LeadListCard> createState() => _LeadListCardState();
}

class _LeadListCardState extends State<LeadListCard> {
  // 0: None, 1: Appointment, 2: Visit Update, 3: Close, 4: Visit History, 5: Appointment History
  int _expandedSection = 0;

  final _appointmentDateController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _otherContactNoController = TextEditingController();
  final _visitNoteController = TextEditingController();
  final _closeNoteController = TextEditingController();
  DateTime? _selectedDateTime;

  String? _selectedCloseReason;

  bool _isVisited = true;
  String? _selectedNotVisitedReason;
  String? _selectedVisitedReason;

  bool _isSubmitting = false; // purely visual loading state, no real call

  // Local mock reasons (previously came from LeadsCubit)
  final List<String> _visitedReasons = const [
    'Interested',
    'Needs Follow-up',
    'Ready to Purchase',
    'Other',
  ];
  final List<String> _notVisitedReasons = const [
    'Not Available',
    'Wrong Address',
    'Rescheduled',
    'Other',
  ];
  final List<String> _closeReasons = const [
    'Not Interested',
    'Budget Constraints',
    'Chose Competitor',
    'Other',
  ];

  bool get _isClosed {
    final status = widget.lead.currentStatusName?.toLowerCase();
    return status == 'won' || status == 'lost';
  }

  @override
  void dispose() {
    _appointmentDateController.dispose();
    _locationController.dispose();
    _contactPersonController.dispose();
    _otherContactNoController.dispose();
    _visitNoteController.dispose();
    _closeNoteController.dispose();
    super.dispose();
  }

  void _toggleSection(int section) {
    setState(() {
      _expandedSection = _expandedSection == section ? 0 : section;
    });
  }

  void _showSnack(String message, {bool warning = false}) {
    if (warning) {
      AppSnackBar.warning(context, message: message);
    } else {
      AppSnackBar.success(context, message: message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final initials = widget.lead.customerName.isNotEmpty
        ? widget.lead.customerName.trim()[0].toUpperCase()
        : '?';

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
            // ── Header row: avatar + name/address/phone + status chip ──
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
                        widget.lead.customerName,
                        style: AppTextStyle.label.bold,
                      ),
                      Gap.v4,
                      Row(
                        children: [
                          const Icon(Icons.home_outlined,
                              size: 12, color: Colors.grey),
                          Gap.h4,
                          Expanded(
                            child: Text(
                              widget.lead.address,
                              style: AppTextStyle.labelSmall
                                  .withColor(Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Gap.v2,
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined,
                              size: 12, color: Colors.grey),
                          Gap.h4,
                          Text(
                            widget.lead.mobileNo,
                            style: AppTextStyle.labelSmall
                                .withColor(cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                      Gap.v2,
                      Row(
                        children: [
                          const Icon(Icons.trending_up,
                              size: 12, color: Colors.grey),
                          Gap.h4,
                          Text(
                            'Forecasted Value: LKR ${widget.lead.sumAssured.toStringAsFixed(0)}',
                            style: AppTextStyle.labelSmall.medium
                                .withColor(AppColor.primaryDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(),
              ],
            ),

            Gap.v12,

            // ── Action icons row ──
            Row(
              children: [
                _buildActionIcon(
                  Icons.call_outlined,
                  isActive: false,
                  onTap: () {
                    if (_isClosed) {
                      _showSnack('Lead is already closed', warning: true);
                      return;
                    }
                    _showSnack('Calling ${widget.lead.mobileNo}... (UI only)');
                  },
                ),
                Gap.h8,
                if (widget.lead.currentStatus == 1) ...[
                  _buildActionIcon(
                    Icons.check_circle_outline,
                    isActive: false,
                    accentColor: Colors.green,
                    label: 'Mark as Contacted',
                    onTap: () async {
                      final confirmed = await AppConfirmationDialog.show(
                        context,
                        title: 'Confirm Contact',
                        message:
                        'Are you sure you want to mark this lead as Contacted? This will update the lead progress.',
                        confirmLabel: 'Confirmed',
                        icon: Icons.check_circle_outline,
                        iconColor: Colors.green,
                      );

                      if (confirmed == true && mounted) {
                        setState(() {
                          widget.lead.currentStatus = 2;
                          widget.lead.currentStatusName = 'Contacted';
                        });
                        _showSnack('Lead marked as Contacted');
                      }
                    },
                  ),
                  Gap.h8,
                ] else ...[
                  _buildActionIcon(
                    Icons.calendar_today_outlined,
                    isActive: _expandedSection == 1,
                    onTap: () {
                      if (_isClosed) {
                        _showSnack('Lead is already closed', warning: true);
                        return;
                      }
                      if (widget.lead.currentStatus == 3) {
                        _showSnack(
                          'Appointment already set. Reschedule it from see all appointments.',
                          warning: true,
                        );
                        return;
                      }
                      if (widget.lead.currentStatus == 4) {
                        _showSnack(
                          'Lead is already visited. Reschedule previous appointment to set a new appointment from see all appointments.',
                          warning: true,
                        );
                        return;
                      }
                      if (widget.lead.currentStatus < 2) {
                        _showSnack('Lead must be Contacted first',
                            warning: true);
                        return;
                      }
                      _toggleSection(1);
                    },
                  ),
                  Gap.h8,
                  _buildActionIcon(
                    Icons.description_outlined,
                    isActive: _expandedSection == 2,
                    onTap: () {
                      if (_isClosed) {
                        _showSnack('Lead is already closed', warning: true);
                        return;
                      }
                      if (widget.lead.currentStatus < 3) {
                        _showSnack('Appointment must be set first',
                            warning: true);
                        return;
                      }
                      _toggleSection(2);
                    },
                  ),
                  Gap.h8,
                ],
                _buildActionIcon(
                  Icons.close_rounded,
                  isActive: _expandedSection == 3,
                  onTap: () {
                    if (_isClosed) {
                      _showSnack('Lead is already closed', warning: true);
                      return;
                    }
                    _toggleSection(3);
                  },
                ),
                const Spacer(),
                _buildActionIcon(
                  Icons.edit_outlined,
                  isActive: false,
                  accentColor: _isClosed ? Colors.grey : AppColor.primaryDark,
                  onTap: () {
                    if (_isClosed) {
                      _showSnack('Cannot edit a closed lead', warning: true);
                      return;
                    }
                    _showSnack('Edit lead tapped (UI only)');
                  },
                ),
              ],
            ),

            Gap.v12,

            // ── Convert to Quotation button ──
            SizedBox(
              width: double.infinity,
              child: AppButton.outlined(
                label: 'Convert to Quotation',
                onPressed: () {
                  if (_isClosed) {
                    _showSnack('Cannot convert a closed lead', warning: true);
                    return;
                  }
                  context.push('/quotations/create', extra: {
                    //'leadId': widget.lead.leadId,
                    'customerName': widget.lead.customerName,
                    'mobileNo': widget.lead.mobileNo,
                  });
                },
                height: 36.h,
                fontSize: 14.sp,
                borderRadius: 8.r,
                foregroundColor: _isClosed ? Colors.grey : AppColor.primaryDark,
              ),
            ),

            if (widget.lead.appointments.isNotEmpty) ...[
              Gap.v12,
              InkWell(
                onTap: () => _toggleSection(5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _expandedSection == 5
                            ? Icons.event_note_rounded
                            : Icons.event_note_outlined,
                        size: 16,
                        color: AppColor.primaryDark,
                      ),
                      Gap.h8,
                      Text(
                        _expandedSection == 5
                            ? 'Hide Appointment History'
                            : 'View Appointment History (${widget.lead.appointments.length})',
                        style: AppTextStyle.caption.bold
                            .withColor(AppColor.primaryDark),
                      ),
                      Icon(
                        _expandedSection == 5
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppColor.primaryDark,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (widget.lead.visits.isNotEmpty) ...[
              Gap.v12,
              InkWell(
                onTap: () => _toggleSection(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _expandedSection == 4
                            ? Icons.history_toggle_off_rounded
                            : Icons.history_rounded,
                        size: 16,
                        color: AppColor.primaryDark,
                      ),
                      Gap.h8,
                      Text(
                        _expandedSection == 4
                            ? 'Hide Visit History'
                            : 'View Visit History (${widget.lead.visits.length})',
                        style: AppTextStyle.caption.bold
                            .withColor(AppColor.primaryDark),
                      ),
                      Icon(
                        _expandedSection == 4
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppColor.primaryDark,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // ── Expandable Sections ──
            if (_expandedSection != 0) ...[
              Gap.v12,
              Divider(height: 1, color: cs.outlineVariant),
              Gap.v12,
              if (_expandedSection == 1) _buildAppointmentSection(),
              if (_expandedSection == 2) _buildVisitUpdateSection(),
              if (_expandedSection == 3) _buildCloseLeadSection(),
              if (_expandedSection == 4)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.lead.visits
                      .map((visit) => _buildVisitItem(visit))
                      .toList(),
                ),
              if (_expandedSection == 5) _buildAppointmentHistorySection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(
      IconData icon, {
        required bool isActive,
        required VoidCallback onTap,
        Color? accentColor,
        String? label,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final effectiveColor =
        accentColor ?? (isDark ? Colors.grey.shade300 : Colors.grey.shade700);

    final bgColor = accentColor != null
        ? accentColor.withValues(alpha: 0.12)
        : (isDark ? const Color(0xFF4A4A4A) : const Color(0xFFE0E0E0));

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: AppPadding.all8,
            decoration: BoxDecoration(
              color: isActive ? AppColor.primaryDark : bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: isActive ? Colors.white : effectiveColor,
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? AppColor.primaryDark : effectiveColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────── Appointment section ───────────────────────

  Widget _buildAppointmentSection() {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create an Appointment',
          style: AppTextStyle.h5.bold.withColor(cs.onSurface),
        ),
        Text(
          'Select Date and Time for the Appointment',
          style: AppTextStyle.caption.withColor(Colors.grey),
        ),
        Gap.v12,
        _buildTextFieldWithLabel(
          'Pick a Date & Time',
          controller: _appointmentDateController,
          readOnly: true,
          onTap: () async {
            final dateTime = await AppDateTimePicker.showDateTime(context);
            if (dateTime != null) {
              _selectedDateTime = dateTime;
              setState(() {
                _appointmentDateController.text =
                '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
              });
            }
          },
        ),
        Gap.v8,
        _buildTextFieldWithLabel('Location', controller: _locationController),
        Gap.v8,
        _buildTextFieldWithLabel('Contact Person',
            controller: _contactPersonController),
        Gap.v8,
        _buildTextFieldWithLabel('Contact Person No',
            controller: _otherContactNoController),
        Gap.v16,
        _buildActionButtons(
          primaryLabel: _isSubmitting ? 'Creating...' : 'Create',
          onPrimaryTap: _isSubmitting ? () {} : _createAppointment,
        ),
      ],
    );
  }

  void _createAppointment() {
    if (_selectedDateTime == null) {
      _showSnack('Please select a date and time', warning: true);
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      _showSnack('Please enter a location', warning: true);
      return;
    }

    // Purely visual "loading" state — no real submission.
    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        widget.lead.appointments.add(
          MockAppointment(
            dateTime: _selectedDateTime!.toIso8601String(),
            status: 1,
            locationName: _locationController.text.trim(),
            otherContactName: _contactPersonController.text.trim(),
            otherContactNo: _otherContactNoController.text.trim(),
          ),
        );
        widget.lead.currentStatus = 3;
        widget.lead.currentStatusName = 'Appointment Set';
      });
      _toggleSection(0);
      _showSnack('Appointment created!');
    });
  }

  // ─────────────────────── Visit update section ───────────────────────

  Widget _buildVisitUpdateSection() {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visit Result',
          style: AppTextStyle.label.bold.withColor(cs.onSurface),
        ),
        Gap.v12,
        Row(
          children: [
            Expanded(
              child: _buildChoiceChip(
                'Visited',
                isSelected: _isVisited,
                onSelected: (v) => setState(() => _isVisited = true),
              ),
            ),
            Gap.h8,
            Expanded(
              child: _buildChoiceChip(
                'Not Visited',
                isSelected: !_isVisited,
                onSelected: (v) => setState(() => _isVisited = false),
              ),
            ),
          ],
        ),
        if (_isVisited) ...[
          Gap.v12,
          _buildDropdownWithLabel(
            'Select Reason',
            value: _selectedVisitedReason,
            items: _visitedReasons,
            onChanged: (value) => setState(() => _selectedVisitedReason = value),
          ),
        ],
        if (!_isVisited) ...[
          Gap.v12,
          _buildDropdownWithLabel(
            'Select Reason',
            value: _selectedNotVisitedReason,
            items: _notVisitedReasons,
            onChanged: (value) =>
                setState(() => _selectedNotVisitedReason = value),
          ),
        ],
        if (_isVisited ||
            _selectedNotVisitedReason == 'Other' ||
            _selectedVisitedReason == 'Other') ...[
          Gap.v12,
          _buildTextAreaWithLabel(
            _isVisited ? 'Visit Notes (Optional)' : 'Specify Reason',
            controller: _visitNoteController,
          ),
        ],
        if (_isVisited) ...[
          Gap.v12,
          _buildFileUploadPlaceholder(),
        ],
        Gap.v16,
        _buildActionButtons(
          primaryLabel: 'Update Visit',
          onPrimaryTap: () {
            if (!_isVisited && _selectedNotVisitedReason == null) {
              _showSnack('Please select a reason', warning: true);
              return;
            }
            if (_isVisited && _selectedVisitedReason == null) {
              _showSnack('Please select a reason', warning: true);
              return;
            }

            final baseReason =
            _isVisited ? _selectedVisitedReason! : _selectedNotVisitedReason!;
            final note = _visitNoteController.text.trim();

            String reason = baseReason;
            if (baseReason == 'Other') {
              reason = note;
            } else if (note.isNotEmpty) {
              reason = '$baseReason - $note';
            }

            if (reason.isEmpty) {
              _showSnack('Please provide a reason', warning: true);
              return;
            }

            setState(() {
              widget.lead.visits.add(
                MockVisit(
                  status: _isVisited ? 1 : 2,
                  reason: reason,
                  createdAt: DateTime.now().toIso8601String(),
                ),
              );
              widget.lead.currentStatus = 4;
              widget.lead.currentStatusName = 'Visited';
            });
            _toggleSection(0);
            _showSnack('Visit updated!');
          },
        ),
      ],
    );
  }

  // ─────────────────────── Close lead section ───────────────────────

  Widget _buildCloseLeadSection() {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Close Lead',
          style: AppTextStyle.h5.bold.withColor(cs.onSurface),
        ),
        Gap.v12,
        _buildDropdownWithLabel(
          'Select Reason',
          value: _selectedCloseReason,
          items: _closeReasons,
          onChanged: (value) => setState(() => _selectedCloseReason = value),
        ),
        if (_selectedCloseReason == 'Other') ...[
          Gap.v12,
          _buildTextAreaWithLabel('Specify Reason',
              controller: _closeNoteController),
        ],
        Gap.v16,
        _buildActionButtons(
          primaryLabel: 'Close Lead',
          onPrimaryTap: () {
            if (_selectedCloseReason == null) {
              _showSnack('Please select a reason', warning: true);
              return;
            }

            final note = _selectedCloseReason == 'Other'
                ? _closeNoteController.text.trim()
                : _selectedCloseReason!;

            if (note.isEmpty) {
              _showSnack('Please provide a reason', warning: true);
              return;
            }

            setState(() {
              widget.lead.currentStatus = 6; // Lost
              widget.lead.currentStatusName = 'Lost';
            });
            _toggleSection(0);
            _showSnack('Lead closed');
          },
        ),
      ],
    );
  }

  // ─────────────────────── Status chip / helpers ───────────────────────

  Color _getStatusColor(int status) {
    switch (status) {
      case 1: // New
        return Colors.blue;
      case 2: // Contacted
        return Colors.orange;
      case 3: // Appointment Set
        return Colors.purple;
      case 4: // Visited
        return Colors.teal;
      case 5: // Won
        return Colors.green;
      case 6: // Lost
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusChip() {
    final statusId = widget.lead.currentStatus;
    final statusName =
        widget.lead.currentStatusName ?? _getStatusName(statusId);

    return Container(
      padding: AppPadding.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor(statusId).withValues(alpha: 0.1),
        borderRadius: AppRadius.r12,
        border: Border.all(
          color: _getStatusColor(statusId),
          width: 0.5,
        ),
      ),
      child: Text(
        statusName,
        style: AppTextStyle.caption.bold.withColor(
          _getStatusColor(statusId),
        ),
      ),
    );
  }

  String _getStatusName(int status) {
    switch (status) {
      case 1:
        return 'New';
      case 2:
        return 'Contacted';
      case 3:
        return 'Appointment Set';
      case 4:
        return 'Visited';
      case 5:
        return 'Won';
      case 6:
        return 'Lost';
      default:
        return 'Unknown';
    }
  }

  Widget _buildTextFieldWithLabel(
      String label, {
        TextEditingController? controller,
        bool readOnly = false,
        VoidCallback? onTap,
        Widget? suffixIcon,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        AppTextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          suffixIcon: suffixIcon,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          borderRadius: 8.r,
        ),
      ],
    );
  }

  Widget _buildTextAreaWithLabel(String label,
      {TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        AppTextField(
          controller: controller,
          maxLines: 3,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          borderRadius: 8.r,
        ),
      ],
    );
  }

  Widget _buildChoiceChip(
      String label, {
        required bool isSelected,
        required ValueChanged<bool> onSelected,
      }) {
    final cs = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Text(label),
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColor.primaryDark,
      backgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
      checkmarkColor: Colors.white,
      showCheckmark: false,
      labelStyle: AppTextStyle.labelSmall.copyWith(
        color: isSelected ? Colors.white : cs.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      padding: EdgeInsets.symmetric(vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(
          color: isSelected ? AppColor.primaryDark : cs.outlineVariant,
        ),
      ),
    );
  }

  Widget _buildDropdownWithLabel(
      String label, {
        required String? value,
        required List<String> items,
        required ValueChanged<String?> onChanged,
      }) {
    return AppDropdownField<String?>(
      label: label,
      value: value,
      hint: 'Select Reason',
      items: [
        DropdownMenuItem<String?>(
          value: '__CLOSE__',
          child: Container(
            alignment: Alignment.centerRight,
            child: const Icon(Icons.close, size: 20, color: Colors.grey),
          ),
        ),
        if (value != null)
          DropdownMenuItem<String?>(
            value: '__CLEAR__',
            child: Row(
              children: [
                const Icon(Icons.clear, size: 16, color: Colors.red),
                const SizedBox(width: 8),
                Text('Clear Selection',
                    style: AppTextStyle.labelSmall.copyWith(color: Colors.red)),
              ],
            ),
          ),
        ...items.map((String item) {
          return DropdownMenuItem<String?>(
            value: item,
            child: Text(item, style: AppTextStyle.labelSmall),
          );
        }),
      ],
      onChanged: (val) {
        if (val == '__CLOSE__') return; // Just closes the menu
        if (val == '__CLEAR__') {
          onChanged(null);
          return;
        }
        onChanged(val);
      },
    );
  }

  Widget _buildActionButtons({
    required String primaryLabel,
    required VoidCallback onPrimaryTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: AppButton.outlined(
            label: 'Close',
            onPressed: () => _toggleSection(0),
            height: 40.h,
            fontSize: 14.sp,
            borderRadius: 8.r,
            foregroundColor: AppColor.primaryDark,
          ),
        ),
        Gap.h12,
        Expanded(
          child: AppButton(
            label: primaryLabel,
            onPressed: onPrimaryTap,
            height: 40.h,
            fontSize: 14.sp,
            borderRadius: 8.r,
            backgroundColor: AppColor.primaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildVisitItem(MockVisit visit) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        borderRadius: AppRadius.r8,
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (visit.status == 1 ? Colors.green : Colors.red)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  visit.status == 1 ? 'Visited' : 'Not Visited',
                  style: AppTextStyle.caption.bold.withColor(
                    visit.status == 1 ? Colors.green : Colors.red,
                  ),
                ),
              ),
              Text(
                visit.createdAt.contains('T')
                    ? visit.createdAt.split('T').first
                    : visit.createdAt,
                style: AppTextStyle.caption.withColor(Colors.grey),
              ),
            ],
          ),
          if (visit.reason.isNotEmpty) ...[
            Gap.v8,
            Text(
              visit.reason,
              style: AppTextStyle.labelSmall.withColor(cs.onSurface),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppointmentHistorySection() {
    final appointments = List<MockAppointment>.from(widget.lead.appointments);
    appointments.sort((a, b) {
      final aDate = DateTime.tryParse(a.dateTime) ?? DateTime.now();
      final bDate = DateTime.tryParse(b.dateTime) ?? DateTime.now();
      return bDate.compareTo(aDate);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
      appointments.map((appt) => _buildAppointmentHistoryItem(appt)).toList(),
    );
  }

  Widget _buildAppointmentHistoryItem(MockAppointment appt) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String dtStr = appt.dateTime;
    if (!dtStr.endsWith('Z') && !dtStr.contains('+')) {
      dtStr += 'Z';
    }
    final dt = (DateTime.tryParse(dtStr) ?? DateTime.now()).toLocal();
    final dateStr = DateFormat('yyyy-MM-dd hh:mm a').format(dt);

    String statusLabel = 'Pending';
    Color statusColor = Colors.orange;

    if (appt.status == 3) {
      statusLabel = 'Visited';
      statusColor = Colors.teal;
    } else if (appt.status == 2) {
      statusLabel = 'Rescheduled';
      statusColor = Colors.orange;
    } else if (appt.status == 1) {
      final now = DateTime.now();
      if (dt.isBefore(now)) {
        statusLabel = 'Overdue';
        statusColor = Colors.red;
      } else {
        statusLabel = 'Pending';
        statusColor = Colors.amber;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        borderRadius: AppRadius.r8,
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusLabel,
                  style: AppTextStyle.caption.bold.withColor(statusColor),
                ),
              ),
              Text(
                dateStr,
                style: AppTextStyle.caption.withColor(Colors.grey),
              ),
            ],
          ),
          Gap.v8,
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: Colors.grey),
              Gap.h4,
              Expanded(
                child: Text(
                  appt.locationName ?? 'No location',
                  style: AppTextStyle.labelSmall.withColor(cs.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (appt.otherContactName != null || appt.otherContactNo != null) ...[
            Gap.v4,
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                Gap.h4,
                Text(
                  '${appt.otherContactName ?? ''} ${appt.otherContactNo ?? ''}',
                  style: AppTextStyle.caption.withColor(cs.onSurface),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFileUploadPlaceholder() {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Documents (Images/Files)',
          style: AppTextStyle.labelSmall.bold.withColor(cs.onSurface),
        ),
        Gap.v8,
        InkWell(
          onTap: () {
            _showSnack('File upload coming soon!');
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: AppRadius.r8,
              border: Border.all(
                color: cs.outlineVariant,
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.cloud_upload_outlined,
                    size: 32, color: AppColor.primaryDark),
                Gap.v8,
                Text(
                  'Tap to upload files',
                  style: AppTextStyle.caption.bold.withColor(AppColor.primaryDark),
                ),
                Gap.v4,
                const Text(
                  'Supports: JPG, PNG, PDF (Max 5MB)',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}