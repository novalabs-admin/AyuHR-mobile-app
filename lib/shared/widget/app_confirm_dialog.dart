import 'package:erp_hr/core/utils/colors.dart';
import 'package:erp_hr/core/utils/spacing.dart';
import 'package:erp_hr/core/utils/text_styles.dart';
import 'package:erp_hr/shared/widget/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable confirmation dialog for the entire app.
///
/// Usage:
/// ```dart
/// final confirmed = await AppConfirmDialog.show(
///   context,
///   title: 'Delete Version',
///   message: 'Are you sure you want to delete this version?',
///   confirmLabel: 'Delete',
///   isDestructive: true,
/// );
/// if (confirmed) { /* perform action */ }
/// ```
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    required this.title,
    required this.message,
    super.key,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
    this.icon,
  });
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final IconData? icon;

  /// Shows the dialog and returns `true` if confirmed, `false` otherwise.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AppConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final actionColor = isDestructive ? Colors.red : AppColor.primary;
    final effectiveIcon = icon ??
        (isDestructive ? Icons.warning_amber_rounded : Icons.info_outline);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.r16),
      backgroundColor: cs.surface,
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: actionColor.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(effectiveIcon, color: actionColor, size: 32.r),
            ),
            Gap.v16,
            // Title
            Text(
              title,
              style: AppTextStyle.h5.bold.withColor(cs.onSurface),
              textAlign: TextAlign.center,
            ),
            Gap.v8,
            // Message
            Text(
              message,
              style: AppTextStyle.bodyMedium.withColor(cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            Gap.v24,
            // Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton.outlined(
                    label: cancelLabel,
                    onPressed: () => Navigator.of(context).pop(false),
                    height: 44.h,
                    fontSize: 14.sp,
                    borderRadius: 12.r,
                    foregroundColor: cs.onSurface,
                  ),
                ),
                Gap.h12,
                Expanded(
                  child: AppButton(
                    label: confirmLabel,
                    onPressed: () => Navigator.of(context).pop(true),
                    height: 44.h,
                    fontSize: 14.sp,
                    borderRadius: 12.r,
                    backgroundColor: actionColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
