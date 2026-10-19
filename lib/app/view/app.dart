// Copyright (c) 2022, Adryan Eka Vandra
// https://github.com/adryanev/flutter-template-architecture-template
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:erp_hr/app/router/app_router.dart';
import 'package:erp_hr/core/extensions/context_extensions.dart';
import 'package:erp_hr/core/utils/app_theme.dart';
import 'package:erp_hr/core/utils/constants.dart';
import 'package:erp_hr/features/login/presentation/blocs/auth_cubit.dart';
import 'package:erp_hr/injector.dart';
import 'package:erp_hr/l10n/arb/app_localizations.dart';
import 'package:erp_hr/shared/flash/presentation/blocs/cubit/flash_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';


class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Initialize the router once.
    // We get the AuthCubit from getIt since it's a singleton.
    _router = router(null, getIt<AuthCubit>());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<FlashCubit>(),
        ),
        BlocProvider.value(
          value: getIt<AuthCubit>(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<FlashCubit, FlashState>(
            listener: (context, state) {
              switch (state) {
                case FlashDisappeared():
                  break;
                case FlashAppeared():
                  context.showSnackbar(
                    message: state.message,
                  );
              }
            },
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(ScreenUtilSize.width, ScreenUtilSize.height),
          builder: (context, child) {
            return MaterialApp.router(
              title: 'Continental Insurance Agent',
              debugShowCheckedModeBanner: false,
              scaffoldMessengerKey: rootScaffoldMessengerKey,
              themeMode: ThemeMode.light,
              theme: AppTheme.light,
              locale: const Locale('en', 'GB'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: _router,
              builder: (context, widget) {
                return MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.noScaling),
                  child: widget!,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
