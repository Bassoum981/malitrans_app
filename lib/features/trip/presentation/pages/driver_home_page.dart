import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../auth/domain/entities/driver.dart';
import '../../../gps/presentation/controllers/gps_tracking_controller.dart';
import '../../../ticket/data/datasources/ticket_remote_data_source.dart';
import '../../../ticket/data/repositories/ticket_repository_impl.dart';
import '../../../ticket/domain/usecases/validate_ticket.dart';
import '../../../ticket/presentation/controllers/ticket_validation_controller.dart';
import '../../../ticket/presentation/pages/ticket_scanner_page.dart';
import '../../domain/entities/active_trip.dart';
import '../controllers/active_trip_controller.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({
    required this.driver,
    required this.controller,
    required this.apiClient,
    required this.tokenStorage,
    required this.gpsController,
    required this.onLogout,
    super.key,
  });

  final Driver driver;
  final ActiveTripController controller;
  final ApiClient apiClient;
  final TokenStorage tokenStorage;
  final GpsTrackingController gpsController;
  final VoidCallback onLogout;

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MaliTrans',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Se déconnecter',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: widget.controller.load,
        child: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, child) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Text(
                  'Bonjour, ${widget.driver.name}.',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Votre journée de conduite',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 24),
                if (widget.controller.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(48),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (widget.controller.errorMessage != null)
                  _StatusCard(
                    icon: Icons.route_outlined,
                    title: 'Aucun trajet actif',
                    message: widget.controller.errorMessage!,
                    actionLabel: 'Réessayer',
                    onAction: widget.controller.load,
                  )
                else if (widget.controller.trip != null)
                  _TripCard(
                    trip: widget.controller.trip!,
                    apiClient: widget.apiClient,
                    tokenStorage: widget.tokenStorage,
                    gpsController: widget.gpsController,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.trip,
    required this.apiClient,
    required this.tokenStorage,
    required this.gpsController,
  });

  final ActiveTrip trip;
  final ApiClient apiClient;
  final TokenStorage tokenStorage;
  final GpsTrackingController gpsController;

  @override
  Widget build(BuildContext context) {
    final date = trip.departureAt;
    final dateLabel = MaterialLocalizations.of(context).formatFullDate(date);
    final timeLabel = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_bus, color: AppColors.mint),
                  const SizedBox(width: 10),
                  Text(
                    'TRAJET ACTIF',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.mint,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                trip.routeLabel,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$dateLabel à $timeLabel',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel(trip.status),
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InfoTile(
          icon: Icons.confirmation_number_outlined,
          label: 'Bus affecté',
          value: trip.busRegistration,
        ),
        const SizedBox(height: 12),
        _InfoTile(
          icon: Icons.event_seat_outlined,
          label: 'Capacité',
          value: '${trip.busCapacity} places',
        ),
        const SizedBox(height: 12),
        _InfoTile(
          icon: Icons.straighten_outlined,
          label: 'Distance',
          value: trip.distanceKm == null
              ? 'Non renseignée'
              : '${trip.distanceKm} km',
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TicketScannerPage(
                  trip: trip,
                  controller: TicketValidationController(
                    ValidateTicket(
                      TicketRepositoryImpl(
                        remoteDataSource: TicketRemoteDataSource(apiClient),
                        tokenStorage: tokenStorage,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Scanner un billet'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 17),
            backgroundColor: AppColors.coral,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ListenableBuilder(
          listenable: gpsController,
          builder: (context, child) {
            final isTracking = gpsController.isTracking;

            return OutlinedButton.icon(
              onPressed: gpsController.isStarting
                  ? null
                  : () async {
                      if (isTracking) {
                        await gpsController.stop();
                      } else {
                        await gpsController.start(tripId: trip.id);
                      }
                    },
              icon: Icon(
                isTracking
                    ? Icons.location_disabled_outlined
                    : Icons.my_location_outlined,
              ),
              label: Text(
                gpsController.isStarting
                    ? 'Activation du GPS...'
                    : isTracking
                    ? 'Arrêter le suivi GPS'
                    : 'Démarrer le suivi GPS',
              ),
            );
          },
        ),
        ListenableBuilder(
          listenable: gpsController,
          builder: (context, child) {
            if (gpsController.errorMessage == null &&
                gpsController.lastSentAt == null) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                gpsController.errorMessage ??
                    'Position GPS envoyée à ${_timeLabel(context, gpsController.lastSentAt!)}.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: gpsController.errorMessage == null
                      ? AppColors.muted
                      : AppColors.coral,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _timeLabel(BuildContext context, DateTime dateTime) {
    return MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(dateTime));
  }

  String _statusLabel(String status) {
    return switch (status) {
      'EN_COURS' => 'TRAJET EN COURS',
      'PLANIFIE' => 'TRAJET PLANIFIÉ',
      _ => status,
    };
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.coral),
        title: Text(label, style: const TextStyle(color: AppColors.muted)),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 44, color: AppColors.coral),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
