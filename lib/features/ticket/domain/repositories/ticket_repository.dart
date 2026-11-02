import '../entities/validated_ticket.dart';

abstract interface class TicketRepository {
  Future<ValidatedTicket> validateTicket({
    required int tripId,
    required String qrCode,
  });
}
