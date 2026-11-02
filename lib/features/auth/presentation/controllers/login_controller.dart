import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/driver.dart';
import '../../domain/usecases/login_driver.dart';

class LoginController extends ChangeNotifier {
  LoginController(this._loginDriver);

  final LoginDriver _loginDriver;

  bool isLoading = false;
  String? errorMessage;
  Driver? driver;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      driver = await _loginDriver(email.trim(), password);
      return true;
    } on AppException catch (exception) {
      errorMessage = exception.message;
    } catch (_) {
      errorMessage = 'Connexion impossible. Vérifiez votre réseau.';
    } finally {
      isLoading = false;
      notifyListeners();
    }

    return false;
  }
}
