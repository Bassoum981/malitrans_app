import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/active_trip.dart';
import '../../domain/usecases/get_active_trip.dart';

class ActiveTripController extends ChangeNotifier {
  ActiveTripController(this._getActiveTrip);

  final GetActiveTrip _getActiveTrip;

  bool isLoading = false;
  String? errorMessage;
  ActiveTrip? trip;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      trip = await _getActiveTrip();
    } on AppException catch (exception) {
      errorMessage = exception.message;
    } catch (_) {
      errorMessage = 'Impossible de charger votre trajet.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
