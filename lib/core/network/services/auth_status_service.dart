import 'dart:async';
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthStatusService {
  final StreamController<String?> _logoutController = StreamController<String?>.broadcast();

  Stream<String?> get logoutStream => _logoutController.stream;

  void notifyLogout([String? reason]) {
    _logoutController.add(reason);
  }

  @disposeMethod
  void dispose() {
    _logoutController.close();
  }
}
