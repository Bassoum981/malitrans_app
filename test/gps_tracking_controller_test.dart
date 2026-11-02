import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:mali_trans_app/features/gps/domain/entities/driver_location.dart';
import 'package:mali_trans_app/features/gps/domain/repositories/gps_repository.dart';
import 'package:mali_trans_app/features/gps/presentation/controllers/gps_tracking_controller.dart';

void main() {
  test('démarre le suivi et envoie les nouvelles positions', () async {
    final repository = FakeGpsRepository();
    final controller = GpsTrackingController(repository);
    final location = DriverLocation(
      latitude: 12.6392,
      longitude: -8.0029,
      recordedAt: DateTime(2026, 11, 2),
    );

    await controller.start(tripId: 7);
    repository.locations.add(location);
    await Future<void>.delayed(Duration.zero);

    expect(controller.isTracking, isTrue);
    expect(repository.sentTripIds, [7]);
    expect(repository.sentLocations, [location]);

    await controller.stop();
    expect(controller.isTracking, isFalse);
    controller.dispose();
  });
}

class FakeGpsRepository implements GpsRepository {
  final locations = StreamController<DriverLocation>();
  final sentTripIds = <int>[];
  final sentLocations = <DriverLocation>[];

  @override
  Future<bool> ensurePermission() async => true;

  @override
  Stream<DriverLocation> watchLocation() => locations.stream;

  @override
  Future<void> sendLocation({
    required int tripId,
    required DriverLocation location,
  }) async {
    sentTripIds.add(tripId);
    sentLocations.add(location);
  }
}
