import 'package:geolocator/geolocator.dart';

import '../../domain/entities/driver_location.dart';

class LocationDeviceDataSource {
  Future<bool> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return false;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Stream<DriverLocation> watchLocation() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50,
    );

    return Geolocator.getPositionStream(locationSettings: settings).map(
      (position) => DriverLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        recordedAt: position.timestamp,
      ),
    );
  }
}
