import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/driver_location.dart';
import '../../domain/repositories/gps_repository.dart';

class GpsTrackingController extends ChangeNotifier {
  GpsTrackingController(this._repository);

  final GpsRepository _repository;
  StreamSubscription<DriverLocation>? _subscription;

  bool isStarting = false;
  bool isTracking = false;
  String? errorMessage;
  DriverLocation? latestLocation;
  DateTime? lastSentAt;

  Future<void> start({required int tripId}) async {
    if (isTracking || isStarting) {
      return;
    }

    isStarting = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (!await _repository.ensurePermission()) {
        throw const AppException(
          'Activez la localisation pour démarrer le suivi GPS.',
        );
      }

      _subscription = _repository.watchLocation().listen(
        (location) => _sendLocation(tripId, location),
        onError: (Object _) {
          errorMessage = 'La position GPS est indisponible.';
          notifyListeners();
        },
      );
      isTracking = true;
    } on AppException catch (exception) {
      errorMessage = exception.message;
    } catch (_) {
      errorMessage = 'Impossible de démarrer le suivi GPS.';
    } finally {
      isStarting = false;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    isTracking = false;
    notifyListeners();
  }

  Future<void> _sendLocation(int tripId, DriverLocation location) async {
    latestLocation = location;
    notifyListeners();

    try {
      await _repository.sendLocation(tripId: tripId, location: location);
      lastSentAt = DateTime.now();
      errorMessage = null;
    } on AppException catch (exception) {
      errorMessage = exception.message;
    } catch (_) {
      errorMessage = 'La position n’a pas pu être envoyée.';
    }

    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
