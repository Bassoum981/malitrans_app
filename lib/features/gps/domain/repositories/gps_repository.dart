import '../entities/driver_location.dart';

abstract interface class GpsRepository {
  Future<bool> ensurePermission();

  Stream<DriverLocation> watchLocation();

  Future<void> sendLocation({
    required int tripId,
    required DriverLocation location,
  });
}
