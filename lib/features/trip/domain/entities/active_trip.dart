class ActiveTrip {
  const ActiveTrip({
    required this.id,
    required this.departureCity,
    required this.arrivalCity,
    required this.departureAt,
    required this.status,
    required this.busRegistration,
    required this.busCapacity,
    required this.busStatus,
    this.distanceKm,
  });

  final int id;
  final String departureCity;
  final String arrivalCity;
  final DateTime departureAt;
  final String status;
  final String busRegistration;
  final int busCapacity;
  final String busStatus;
  final num? distanceKm;

  String get routeLabel => '$departureCity → $arrivalCity';
}
