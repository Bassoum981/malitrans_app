import '../../domain/entities/active_trip.dart';

class ActiveTripModel extends ActiveTrip {
  const ActiveTripModel({
    required super.id,
    required super.departureCity,
    required super.arrivalCity,
    required super.departureAt,
    required super.status,
    required super.busRegistration,
    required super.busCapacity,
    required super.busStatus,
    super.distanceKm,
  });

  factory ActiveTripModel.fromJson(Map<String, dynamic> json) {
    final ligne = json['ligne'] as Map<String, dynamic>? ?? {};
    final bus = json['bus'] as Map<String, dynamic>? ?? {};

    return ActiveTripModel(
      id: _asInt(json['id']),
      departureCity: ligne['ville_depart'] as String? ?? 'Départ inconnu',
      arrivalCity: ligne['ville_arrivee'] as String? ?? 'Arrivée inconnue',
      departureAt: DateTime.parse(json['heure_depart_prevue'].toString()),
      status: json['statut'] as String? ?? 'PLANIFIE',
      busRegistration: bus['immatriculation'] as String? ?? '—',
      busCapacity: _asInt(bus['capacite']),
      busStatus: bus['statut'] as String? ?? '—',
      distanceKm: ligne['distance_km'] as num?,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
