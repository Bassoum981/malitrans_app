import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/validated_ticket.dart';
import '../../domain/usecases/validate_ticket.dart';
import '../../data/models/validated_ticket_model.dart';

class TicketValidationController extends ChangeNotifier {
  TicketValidationController(this._validateTicket);

  final ValidateTicket _validateTicket;

  bool isLoading = false;
  String? errorMessage;
  ValidatedTicket? ticket;

  void clear() {
    errorMessage = null;
    ticket = null;
    notifyListeners();
  }

  Future<bool> validate({required int tripId, required String qrCode}) async {
    if (isLoading) {
      return false;
    }

    isLoading = true;
    errorMessage = null;
    ticket = null;
    notifyListeners();

    try {
      ticket = await _validateTicket(tripId: tripId, qrCode: qrCode);
      return true;
    } on AppException catch (exception) {
      errorMessage = exception.message;
      final data = exception.data;

      if (data is Map<String, dynamic>) {
        ticket = ValidatedTicketModel.fromJson(data);
      }
    } catch (_) {
      errorMessage = 'Impossible de valider ce billet.';
    } finally {
      isLoading = false;
      notifyListeners();
    }

    return false;
  }
}
