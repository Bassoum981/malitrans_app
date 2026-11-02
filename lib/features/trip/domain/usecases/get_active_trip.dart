import '../entities/active_trip.dart';
import '../repositories/trip_repository.dart';

class GetActiveTrip {
  GetActiveTrip(this._repository);

  final TripRepository _repository;

  Future<ActiveTrip> call() => _repository.fetchActiveTrip();
}
