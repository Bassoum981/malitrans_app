import '../entities/active_trip.dart';

abstract interface class TripRepository {
  Future<ActiveTrip> fetchActiveTrip();
}
