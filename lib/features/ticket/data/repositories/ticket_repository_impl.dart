import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/validated_ticket.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../datasources/ticket_remote_data_source.dart';

class TicketRepositoryImpl implements TicketRepository {
  TicketRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  final TicketRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  @override
  Future<ValidatedTicket> validateTicket({
    required int tripId,
    required String qrCode,
  }) async {
    final token = await tokenStorage.read();

    if (token == null || token.isEmpty) {
      throw const AppException('Votre session a expiré. Reconnectez-vous.');
    }

    return remoteDataSource.validateTicket(
      tripId: tripId,
      qrCode: qrCode,
      token: token,
    );
  }
}
