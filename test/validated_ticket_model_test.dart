import 'package:flutter_test/flutter_test.dart';

import 'package:mali_trans_app/features/ticket/data/models/validated_ticket_model.dart';

void main() {
  test('parse toutes les informations du billet depuis Laravel', () {
    final ticket = ValidatedTicketModel.fromJson({
      'id': 11,
      'code_qr_hash': 'MALITRANS-TEST',
      'trajet_id': 1,
      'nom_passager': 'Ibrahim Sylla',
      'telephone_passager': '+22370000000',
      'numero_siege': 3,
      'type_vente': 'GUICHET',
      'prix': '12000.00',
      'statut': 'VALIDE',
      'date_paiement': '2026-11-02T02:53:49+00:00',
      'date_validation': '2026-11-02T17:44:51+00:00',
      'trajet': {
        'heure_depart_prevue': '2026-11-02T06:00:00.000000Z',
        'ligne': {'ville_depart': 'Sikasso', 'ville_arrivee': 'Mopti'},
        'bus': {'immatriculation': 'fk-729-MD'},
      },
      'vendeur': {'name': 'Guichet MaliTrans'},
    });

    expect(ticket.passengerName, 'Ibrahim Sylla');
    expect(ticket.passengerPhone, '+22370000000');
    expect(ticket.seatNumber, 3);
    expect(ticket.price, 12000);
    expect(ticket.status, 'VALIDE');
    expect(ticket.paymentDate, isNotNull);
    expect(ticket.validatedAt, isNotNull);
    expect(ticket.departureCity, 'Sikasso');
    expect(ticket.arrivalCity, 'Mopti');
    expect(ticket.busRegistration, 'fk-729-MD');
    expect(ticket.sellerName, 'Guichet MaliTrans');
  });
}
