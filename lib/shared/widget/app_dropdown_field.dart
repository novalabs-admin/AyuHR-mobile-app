import 'package:erp_hr/core/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


/// Reusable dropdown field with label, hint, and error handling.
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    required this.items,
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.isRequired = false,
    this.value,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.borderRadius,
    this.filled,
    this.fillColor,
    this.contentPadding,
    this.enabled = true,
    this.menuMaxHeight,
  });

  final String? label;
  final String? hint;
  final String? errorText;
  final bool isRequired;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;
  final double? borderRadius;
  final bool? filled;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final bool enabled;
  final double? menuMaxHeight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = borderRadius ?? 12.r;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text.rich(
            TextSpan(
              text: label,
              style: AppTextStyle.label.withColor(
                enabled ? cs.onSurface : cs.onSurface.withValues(alpha: 0.5),
              ),
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: AppTextStyle.label.withColor(
                      enabled ? cs.error : cs.error.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
        ],
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          menuMaxHeight: menuMaxHeight ?? 300.h,
          decoration: InputDecoration(
            errorText: errorText,
            errorMaxLines: 3,
            filled: filled ?? true,
            fillColor: fillColor ??
                Theme.of(context).inputDecorationTheme.fillColor ??
                cs.surfaceContainerHighest,
            contentPadding: contentPadding ??
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            prefixIcon:
                prefixIcon != null ? Icon(prefixIcon, size: 22.r) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(
                color: cs.outlineVariant,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(color: cs.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(color: cs.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(color: cs.error, width: 1.5),
            ),
          ),
          dropdownColor: cs.surface,
          hint: hint != null
              ? Text(
                  hint!,
                  style: AppTextStyle.bodyMedium.withColor(
                    enabled
                        ? cs.onSurfaceVariant
                        : cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                )
              : null,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: enabled
                ? cs.onSurfaceVariant
                : cs.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          items: items,
          // DropdownButtonFormField disables itself if onChanged is null
          onChanged: enabled ? onChanged : null,
          validator: validator,
        ),
      ],
    );
  }
}
