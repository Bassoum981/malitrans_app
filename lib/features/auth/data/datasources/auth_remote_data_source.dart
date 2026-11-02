import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../models/driver_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<({DriverModel driver, String token})> login(
    String email,
    String password,
  ) async {
    final response = await _apiClient.post(
      Uri.parse('${ApiConfig.apiUrl}/auth/login'),
      body: {'email': email, 'password': password},
    );
    final data = response['data'] as Map<String, dynamic>? ?? {};
    final driver = DriverModel.fromJson(
      data['user'] as Map<String, dynamic>? ?? {},
    );
    final token = data['token'] as String? ?? '';

    return (driver: driver, token: token);
  }
}
