import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/entities/driver.dart';
import '../features/auth/domain/usecases/login_driver.dart';
import '../features/auth/presentation/controllers/login_controller.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/gps/data/datasources/gps_remote_data_source.dart';
import '../features/gps/data/datasources/location_device_data_source.dart';
import '../features/gps/data/repositories/gps_repository_impl.dart';
import '../features/gps/presentation/controllers/gps_tracking_controller.dart';
import '../features/trip/data/datasources/trip_remote_data_source.dart';
import '../features/trip/data/repositories/trip_repository_impl.dart';
import '../features/trip/domain/usecases/get_active_trip.dart';
import '../features/trip/presentation/controllers/active_trip_controller.dart';
import '../features/trip/presentation/pages/driver_home_page.dart';
import 'theme/app_theme.dart';

class MaliTransApp extends StatefulWidget {
  MaliTransApp({super.key})
    : apiClient = ApiClient(),
      tokenStorage = TokenStorage();

  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  @override
  State<MaliTransApp> createState() => _MaliTransAppState();
}

class _MaliTransAppState extends State<MaliTransApp> {
  late final LoginController _loginController;
  late final ActiveTripController _activeTripController;
  late final GpsTrackingController _gpsTrackingController;
  Driver? _driver;

  @override
  void initState() {
    super.initState();
    _loginController = LoginController(
      LoginDriver(
        AuthRepositoryImpl(
          remoteDataSource: AuthRemoteDataSource(widget.apiClient),
          tokenStorage: widget.tokenStorage,
        ),
      ),
    );
    _activeTripController = ActiveTripController(
      GetActiveTrip(
        TripRepositoryImpl(
          remoteDataSource: TripRemoteDataSource(widget.apiClient),
          tokenStorage: widget.tokenStorage,
        ),
      ),
    );
    _gpsTrackingController = GpsTrackingController(
      GpsRepositoryImpl(
        deviceDataSource: LocationDeviceDataSource(),
        remoteDataSource: GpsRemoteDataSource(widget.apiClient),
        tokenStorage: widget.tokenStorage,
      ),
    );
  }

  @override
  void dispose() {
    _activeTripController.dispose();
    _gpsTrackingController.dispose();
    _loginController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MaliTrans Chauffeur',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: _driver == null
          ? LoginPage(
              controller: _loginController,
              onLoginSuccess: (driver) {
                setState(() {
                  _driver = driver;
                });
              },
            )
          : DriverHomePage(
              driver: _driver!,
              apiClient: widget.apiClient,
              tokenStorage: widget.tokenStorage,
              controller: _activeTripController,
              gpsController: _gpsTrackingController,
              onLogout: () async {
                await _gpsTrackingController.stop();
                await widget.tokenStorage.clear();
                if (mounted) {
                  setState(() {
                    _driver = null;
                  });
                }
              },
            ),
    );
  }
}
