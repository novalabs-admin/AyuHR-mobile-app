import 'package:erp_hr/core/utils/colors.dart';
import 'package:erp_hr/core/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


class AppDateTimePicker {
  static Future<DateTime?> showDate(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    return showDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return SmartDatePickerDialog(
          initialDate: initialDate ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(DateTime.now().year - 100),
          lastDate: lastDate ?? DateTime(2100),
        );
      },
    );
  }

  static Future<TimeOfDay?> showTime(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) async {
    return showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColor.primary,
              onSurface: AppColor.black,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: AppColor.white),
          ),
          child: child!,
        );
      },
    );
  }

  static Future<DateTime?> showDateTime(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final date = await showDate(
      context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (date == null) return null;

    if (!context.mounted) return date;

    final time = await showTime(
      context,
      initialTime: TimeOfDay.fromDateTime(date),
    );

    if (time == null) return date;

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
}

class SmartDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const SmartDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    super.key,
  });

  @override
  State<SmartDatePickerDialog> createState() => _SmartDatePickerDialogState();
}

class _SmartDatePickerDialogState extends State<SmartDatePickerDialog> {
  late DateTime _selectedDate;
  bool _isCalendarMode = true;
  late TextEditingController _textController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _textController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(_selectedDate),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
      _textController.text = DateFormat('dd/MM/yyyy').format(date);
      _errorText = null;
    });
  }

  void _validateAndSubmitText(String text) {
    if (text.length < 10) {
      setState(() {
        _errorText = 'Please enter a complete date (DD/MM/YYYY)';
      });
      return;
    }

    try {
      final parts = text.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        if (month < 1 || month > 12) {
          setState(() {
            _errorText = 'Invalid month (01-12)';
          });
          return;
        }

        if (day < 1 || day > 31) {
          setState(() {
            _errorText = 'Invalid day (01-31)';
          });
          return;
        }

        // Handle month lengths and leap years
        final daysInMonth = DateUtils.getDaysInMonth(year, month);
        if (day > daysInMonth) {
          setState(() {
            _errorText = 'Invalid day for selected month';
          });
          return;
        }

        final parsedDate = DateTime(year, month, day);
        if (parsedDate.isBefore(widget.firstDate) || parsedDate.isAfter(widget.lastDate)) {
          setState(() {
            _errorText = 'Date out of valid range';
          });
          return;
        }

        setState(() {
          _selectedDate = parsedDate;
          _errorText = null;
        });

        Navigator.of(context).pop(_selectedDate);
      }
    } catch (_) {
      setState(() {
        _errorText = 'Invalid date format';
      });
    }
  }

  void _confirmSelection() {
    if (_isCalendarMode) {
      Navigator.of(context).pop(_selectedDate);
    } else {
      _validateAndSubmitText(_textController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColor.white,
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Header Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              color: AppColor.primary,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SELECT DATE',
                    style: AppTextStyle.label.withColor(AppColor.white.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                    style: AppTextStyle.h4.semiBold.withColor(AppColor.white),
                  ),
                ],
              ),
            ),

            // Mode Selector Switch
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isCalendarMode = true;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isCalendarMode ? AppColor.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _isCalendarMode
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: _isCalendarMode ? AppColor.primary : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Calendar',
                                style: AppTextStyle.bodyMedium.semiBold.withColor(
                                  _isCalendarMode ? AppColor.primary : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isCalendarMode = false;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: !_isCalendarMode ? AppColor.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: !_isCalendarMode
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.keyboard_alt_outlined,
                                size: 16,
                                color: !_isCalendarMode ? AppColor.primary : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Type Date',
                                style: AppTextStyle.bodyMedium.semiBold.withColor(
                                  !_isCalendarMode ? AppColor.primary : Colors.grey.shade600,
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
            ),

            // Content Section
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isCalendarMode
                  ? Theme(
                      key: const ValueKey('calendar'),
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColor.primary,
                          onPrimary: AppColor.white,
                          onSurface: AppColor.black,
                        ),
                      ),
                      child: SizedBox(
                        height: 300,
                        child: CalendarDatePicker(
                          initialDate: _selectedDate,
                          firstDate: widget.firstDate,
                          lastDate: widget.lastDate,
                          onDateChanged: _onDateChanged,
                        ),
                      ),
                    )
                  : Padding(
                      key: const ValueKey('keypad'),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          TextField(
                            controller: _textController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [DateTextInputFormatter()],
                            style: AppTextStyle.h4.semiBold.withColor(AppColor.black),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'DD/MM/YYYY',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              errorText: _errorText,
                              errorStyle: AppTextStyle.bodySmall.withColor(Colors.red),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColor.primary, width: 2),
                              ),
                              prefixIcon: const Icon(Icons.date_range, color: AppColor.primary),
                            ),
                            onChanged: (val) {
                              if (_errorText != null) {
                                setState(() {
                                  _errorText = null;
                                });
                              }
                              // Live update selectedDate preview if date is valid
                              if (val.length == 10) {
                                try {
                                  final parts = val.split('/');
                                  final day = int.parse(parts[0]);
                                  final month = int.parse(parts[1]);
                                  final year = int.parse(parts[2]);
                                  final parsedDate = DateTime(year, month, day);
                                  if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
                                    final daysInMonth = DateUtils.getDaysInMonth(year, month);
                                    if (day <= daysInMonth &&
                                        !parsedDate.isBefore(widget.firstDate) &&
                                        !parsedDate.isAfter(widget.lastDate)) {
                                      setState(() {
                                        _selectedDate = parsedDate;
                                      });
                                    }
                                  }
                                } catch (_) {}
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              'Type 8 digits (e.g. 23052008) to format automatically.',
                              style: AppTextStyle.bodySmall.withColor(Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
            ),

            // Actions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'CANCEL',
                      style: AppTextStyle.bodyMedium.semiBold.withColor(Colors.grey.shade700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _confirmSelection,
                    child: Text(
                      'OK',
                      style: AppTextStyle.bodyMedium.semiBold.withColor(AppColor.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class DateTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // 1. If deleting, just return the newValue to make backspace feel smooth
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    // 2. Strip all non-digit characters to format the raw input
    final cleanDigits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // 3. Format the clean digits with slashes at indices 2 and 4
    final buffer = StringBuffer();
    for (int i = 0; i < cleanDigits.length; i++) {
      if (i == 2 || i == 4) {
        buffer.write('/');
      }
      buffer.write(cleanDigits[i]);
      if (buffer.length >= 10) break; // Limit to DD/MM/YYYY
    }

    String formattedText = buffer.toString();
    // Maintain a manual slash typed at index 2 or 4 if the user types it explicitly
    if (newValue.text.endsWith('/') && (cleanDigits.length == 2 || cleanDigits.length == 4)) {
      formattedText += '/';
    }

    // 4. Calculate new cursor position based on digits typed before the cursor
    final oldSelectionEnd = newValue.selection.end;
    final digitsBeforeCursor = newValue.text
        .substring(0, oldSelectionEnd.clamp(0, newValue.text.length))
        .replaceAll(RegExp(r'\D'), '')
        .length;

    int newOffset = 0;
    int digitsSeen = 0;
    while (newOffset < formattedText.length && digitsSeen < digitsBeforeCursor) {
      if (formattedText[newOffset] != '/') {
        digitsSeen++;
      }
      newOffset++;
    }

    // Auto-advance cursor past the slash if it's placed right before it
    if (newOffset < formattedText.length && formattedText[newOffset] == '/') {
      newOffset++;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newOffset.clamp(0, formattedText.length)),
    );
  }
}
