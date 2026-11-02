import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/driver_location.dart';

class GpsRemoteDataSource {
  GpsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<void> sendLocation({
    required int tripId,
    required DriverLocation location,
    required String token,
  }) async {
    await _apiClient.post(
      Uri.parse('${ApiConfig.apiUrl}/driver/trajets/$tripId/gps'),
      bearerToken: token,
      body: {'latitude': location.latitude, 'longitude': location.longitude},
    );
  }
}
