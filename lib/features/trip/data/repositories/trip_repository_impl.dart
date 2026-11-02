import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/active_trip.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_data_source.dart';

class TripRepositoryImpl implements TripRepository {
  TripRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  final TripRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  @override
  Future<ActiveTrip> fetchActiveTrip() async {
    final token = await tokenStorage.read();

    if (token == null || token.isEmpty) {
      throw const AppException('Votre session a expiré. Reconnectez-vous.');
    }

    return remoteDataSource.fetchActiveTrip(token);
  }
}
