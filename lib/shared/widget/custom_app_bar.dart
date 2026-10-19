import 'package:erp_hr/core/utils/constants.dart';
import 'package:erp_hr/core/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    required this.title,
    this.actions,
    this.isNeedBackButton = false,
    this.onBackPressed,
    super.key,
  });

  final String title;
  final List<Widget>? actions;
  final bool isNeedBackButton;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: cs.surface,
      title: Text(
        title,
        style: AppTextStyle.h3.withColor(cs.onSurface),
      ),
      centerTitle: true,
      leading: isNeedBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: cs.primary),
              onPressed: () {
                if (onBackPressed != null) {
                  onBackPressed!();
                } else {
                  Navigator.maybePop(context);
                }
              },
            )
          : Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu, color: cs.onSurface),
                onPressed: () {
                  if (mainScaffoldKey.currentState?.hasDrawer ?? false) {
                    mainScaffoldKey.currentState?.openDrawer();
                  } else {
                    Scaffold.of(context).openDrawer();
                  }
                },
              ),
            ),
      actions: actions ??
          [
            Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: Image.asset(
                'assets/images/logo-Ayulanka.png',
                height: 40.r,
                width: 80.w,
              ),
            ),
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
