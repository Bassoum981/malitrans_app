import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/driver.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this._remoteDataSource,
    required this._tokenStorage,
  });

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  @override
  Future<Driver> login(String email, String password) async {
    final result = await _remoteDataSource.login(email, password);

    if (!result.driver.isDriver) {
      throw const AppException(
        'Cette application est réservée aux chauffeurs.',
      );
    }

    if (result.token.isEmpty) {
      throw const AppException(
        'Le serveur n’a pas retourné de session valide.',
      );
    }

    await _tokenStorage.save(result.token);

    return result.driver;
  }
}
