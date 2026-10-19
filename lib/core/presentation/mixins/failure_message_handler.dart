import 'package:flutter/material.dart';
import 'package:erp_hr/core/domain/failures/failure.dart';
import 'package:erp_hr/core/extensions/context_extensions.dart';
// import 'package:erp_hr/l10n/l10n.dart';

mixin FailureMessageHandler {
  void handleFailure(BuildContext context, Failure failure) {
    switch (failure) {
      case LocalFailure():
        context.displayFlash(failure.message);
      case ServerFailure():
        context.displayFlash(failure.message);
    }
  }
}
