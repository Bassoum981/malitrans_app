import '../entities/driver.dart';

abstract interface class AuthRepository {
  Future<Driver> login(String email, String password);
}
