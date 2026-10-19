import 'package:erp_hr/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppFloatingActionButton extends StatelessWidget {
  const AppFloatingActionButton({
    required this.onPressed,
    super.key,
    this.icon = Icons.add,
    this.tooltip,
    this.heroTag,
  });
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColor.primary,
      tooltip: tooltip,
      heroTag: heroTag,
      shape: const CircleBorder(),
      elevation: 4,
      child: Container(
        width: 26.r,
        height: 26.r,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(
          icon,
          color: AppColor.primaryDark,
          size: 18.r,
        ),
      ),
    );
  }
}
