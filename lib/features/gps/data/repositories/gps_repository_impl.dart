import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/driver_location.dart';
import '../../domain/repositories/gps_repository.dart';
import '../datasources/gps_remote_data_source.dart';
import '../datasources/location_device_data_source.dart';

class GpsRepositoryImpl implements GpsRepository {
  GpsRepositoryImpl({
    required this.deviceDataSource,
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  final LocationDeviceDataSource deviceDataSource;
  final GpsRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  @override
  Future<bool> ensurePermission() {
    return deviceDataSource.ensurePermission();
  }

  @override
  Stream<DriverLocation> watchLocation() {
    return deviceDataSource.watchLocation();
  }

  @override
  Future<void> sendLocation({
    required int tripId,
    required DriverLocation location,
  }) async {
    final token = await tokenStorage.read();

    if (token == null || token.isEmpty) {
      throw const AppException('Votre session a expiré. Reconnectez-vous.');
    }

    await remoteDataSource.sendLocation(
      tripId: tripId,
      location: location,
      token: token,
    );
  }
}
