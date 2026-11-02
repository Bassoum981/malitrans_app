import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../models/active_trip_model.dart';

class TripRemoteDataSource {
  TripRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<ActiveTripModel> fetchActiveTrip(String token) async {
    final response = await _apiClient.get(
      Uri.parse('${ApiConfig.apiUrl}/driver/trajet-actif'),
      bearerToken: token,
    );
    final data = response['data'] as Map<String, dynamic>? ?? {};

    return ActiveTripModel.fromJson(data);
  }
}
