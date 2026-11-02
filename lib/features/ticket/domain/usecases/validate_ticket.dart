import '../entities/validated_ticket.dart';
import '../repositories/ticket_repository.dart';

class ValidateTicket {
  ValidateTicket(this._repository);

  final TicketRepository _repository;

  Future<ValidatedTicket> call({required int tripId, required String qrCode}) {
    return _repository.validateTicket(tripId: tripId, qrCode: qrCode);
  }
}
