import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../models/validated_ticket_model.dart';

class TicketRemoteDataSource {
  TicketRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<ValidatedTicketModel> validateTicket({
    required int tripId,
    required String qrCode,
    required String token,
  }) async {
    final response = await _apiClient.post(
      Uri.parse('${ApiConfig.apiUrl}/driver/trajets/$tripId/valider-billet'),
      bearerToken: token,
      body: {'code_qr_hash': qrCode},
    );
    final data = response['data'] as Map<String, dynamic>? ?? {};

    return ValidatedTicketModel.fromJson(data);
  }
}
