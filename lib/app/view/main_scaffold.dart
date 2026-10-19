import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:erp_hr/core/utils/colors.dart';
import 'package:erp_hr/core/utils/constants.dart';
import 'package:erp_hr/features/login/presentation/blocs/auth_cubit.dart';
import 'package:erp_hr/features/login/presentation/blocs/auth_state.dart';
import 'package:erp_hr/shared/widget/app_confirm_dialog.dart';
import 'package:erp_hr/shared/widget/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


class MainScaffold extends StatelessWidget {
  const MainScaffold({
    required this.navigationShell,
    super.key,
  });

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    Color getItemColor(int index) {
      if (navigationShell.currentIndex == index) {
        return AppColor.primary ;
      }
      return Theme.of(context).brightness == Brightness.light
          ? Colors.grey.shade800
          : Colors.grey.shade400;
    }

    return Scaffold(
      key: mainScaffoldKey,
      extendBody: true,
      drawer: const AppDrawer(),
      body: navigationShell,
      bottomNavigationBar: CurvedNavigationBar(
        index: navigationShell.currentIndex,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        color: Theme.of(context).colorScheme.surface,
        height: 60,
        animationDuration: const Duration(milliseconds: 300),
        items: [
          CurvedNavigationBarItem(
            child: Icon(Icons.home_outlined, color: getItemColor(0)),
            label: 'Dashboard',
            labelStyle: TextStyle(
              color: getItemColor(0),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.people_outline, color: getItemColor(1)),
            label: 'Leads',
            labelStyle: TextStyle(
              color: getItemColor(1),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.request_quote_outlined, color: getItemColor(2)),
            label: 'Quotations',
            labelStyle: TextStyle(
              color: getItemColor(2),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.description_outlined,
              color: getItemColor(3),
            ),
            label: 'Proposals',
            labelStyle: TextStyle(
              color: getItemColor(3),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.list_alt_outlined, color: getItemColor(4)),
            label: 'My List',
            labelStyle: TextStyle(
              color: getItemColor(4),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        onTap: (index) async {
          if (index == navigationShell.currentIndex) {
            navigationShell.goBranch(
              index,
              initialLocation: true,
            );
            return;
          }

          final currentPath = GoRouterState.of(context).uri.path;
          if (currentPath == '/quotations/create' ||
              currentPath == '/leads/create') {
            final confirm = await AppConfirmDialog.show(
              context,
              title: 'Discard changes?',
              message:
                  'If you leave now, you will lose all the details you have entered.',
              confirmLabel: 'Discard',
              cancelLabel: 'Continue',
              isDestructive: true,
            );

            if (!confirm) {
              navigationShell.goBranch(navigationShell.currentIndex);
              return;
            }
          }

          // Trigger refresh for the target branch
          _triggerRefresh(context, index);

          // Always return to the initial root page when visiting a tab
          navigationShell.goBranch(
            index,
            initialLocation: true,
          );
        },
      ),
    );
  }

  void _triggerRefresh(BuildContext context, int index) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated || authState.userProfile == null) return;

    final userId = authState.userProfile!.userId;

    // if (index == 0) {
    //   // Dashboard
    //   getIt<LeadsCubit>().fetchLeads(userId);
    //   getIt<PlansCubit>().fetchPlans();
    // } else if (index == 1) {
    //   // Leads
    //   getIt<LeadsCubit>().fetchLeads(userId);
    // }
  }
}
