import '../entities/driver.dart';
import '../repositories/auth_repository.dart';

class LoginDriver {
  LoginDriver(this._repository);

  final AuthRepository _repository;

  Future<Driver> call(String email, String password) {
    return _repository.login(email, password);
  }
}
