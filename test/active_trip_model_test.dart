import 'package:flutter_test/flutter_test.dart';

import 'package:mali_trans_app/features/trip/data/models/active_trip_model.dart';

void main() {
  test('parse la distance sérialisée en chaîne par Laravel', () {
    final trip = ActiveTripModel.fromJson({
      'id': 1,
      'heure_depart_prevue': '2026-11-02T06:00:00.000000Z',
      'statut': 'PLANIFIE',
      'ligne': {
        'ville_depart': 'Sikasso',
        'ville_arrivee': 'Mopti',
        'distance_km': '646.83',
      },
      'bus': {
        'immatriculation': 'fk-729-MD',
        'capacite': 30,
        'statut': 'EN_SERVICE',
      },
    });

    expect(trip.distanceKm, 646.83);
    expect(trip.routeLabel, 'Sikasso → Mopti');
  });
}
