# MaliTrans App Chauffeur

Application mobile Flutter destinée exclusivement aux chauffeurs de MaliTrans.
Elle fonctionne sur iOS et Android et communique avec l'API Laravel de
MaliTrans au moyen de tokens Sanctum.

## Fonctionnalités implémentées

### Authentification chauffeur

- Connexion avec une adresse email et un mot de passe.
- Appel de `POST /api/v1/auth/login`.
- Vérification obligatoire du rôle `chauffeur`.
- Refus des comptes administrateur ou guichetier.
- Stockage sécurisé du token avec `flutter_secure_storage`.
- Suppression du token lors de la déconnexion.
- Message explicite lorsque la session est absente, expirée ou invalide.

### Trajet actif

- Appel de `GET /api/v1/driver/trajet-actif`.
- Chargement du premier trajet `PLANIFIE` ou `EN_COURS` affecté au chauffeur
  connecté.
- Affichage de la ligne, de la date, de l'heure, du statut, du bus, de la
  capacité et de la distance.
- Actualisation par glissement vers le bas.
- Gestion des états de chargement, d'erreur et d'absence de trajet.
- Conversion robuste des valeurs Laravel sérialisées en chaîne, notamment
  `distance_km`.

### Scan et validation des billets QR

- Écran de scan basé sur `mobile_scanner`.
- Demande de permission caméra au moment d'ouvrir le scanner.
- Le démarrage automatique de la caméra est désactivé afin de pouvoir gérer
  proprement un refus de permission.
- État récupérable lorsque la caméra est refusée ou indisponible.
- Bouton de nouvelle tentative pour demander à nouveau l'accès caméra.
- Lecture du champ QR contenant le `code_qr_hash` MaliTrans.
- Appel de
  `POST /api/v1/driver/trajets/{trajet}/valider-billet`.
- Protection contre les doubles soumissions pendant une validation.
- Affichage des résultats :
  - billet validé ;
  - billet déjà utilisé ;
  - billet annulé ;
  - QR invalide ;
  - billet appartenant à un autre trajet.
- Affichage complet du billet après le scan :
  - identifiant et QR ;
  - passager et téléphone ;
  - siège, montant et type de vente ;
  - statut ;
  - date de paiement et date de validation ;
  - trajet, ligne et bus ;
  - vendeur lorsque cette information est disponible.
- Lorsqu'un billet est déjà validé ou refusé pour une autre raison, l'API
  conserve le statut HTTP `422` mais renvoie aussi les informations du billet
  trouvé. L'application affiche alors le motif du refus et les détails utiles
  du billet au chauffeur.

### Suivi GPS

- Activation manuelle depuis l'écran du trajet actif.
- Demande de permission de localisation avec `geolocator`.
- Vérification de l'activation du service de localisation.
- Écoute des changements de position avec une précision élevée.
- Envoi d'une position lorsque le déplacement atteint 50 mètres.
- Appel de `POST /api/v1/driver/trajets/{trajet}/gps`.
- Affichage de la dernière position envoyée.
- Arrêt manuel du suivi.
- Arrêt automatique lors de la déconnexion.
- Gestion des refus de permission, de l'absence de service GPS et des erreurs
  réseau sans fermeture de l'application.

## Architecture choisie : Clean Architecture

Chaque fonctionnalité est séparée en trois couches :

```text
presentation -> domain <- data
```

### Domain

La couche `domain` contient les règles métier indépendantes de Flutter, HTTP,
Laravel et des plugins natifs :

- `entities/` : objets métier immuables ;
- `repositories/` : contrats abstraits des accès aux données ;
- `usecases/` : actions métier appelées par l'interface.

Cette couche ne dépend pas des implémentations concrètes. Elle permet de tester
les règles sans caméra, GPS ou serveur.

### Data

La couche `data` implémente les contrats du domaine :

- `datasources/` : appels API et accès aux services natifs ;
- `models/` : conversion JSON vers les entités métier ;
- `repositories/` : orchestration des datasources et du stockage du token.

Les détails Laravel, Sanctum, HTTP, `mobile_scanner` et `geolocator` restent
ainsi isolés de la présentation.

### Presentation

La couche `presentation` contient :

- `pages/` : écrans Flutter ;
- `controllers/` : état de l'écran, chargement, erreurs et actions utilisateur.

Les controllers utilisent les use cases et notifient les widgets avec
`ChangeNotifier`.

## Arborescence et rôle des fichiers

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── theme/app_theme.dart
├── core/
│   ├── config/api_config.dart
│   ├── errors/app_exception.dart
│   ├── network/api_client.dart
│   └── storage/token_storage.dart
└── features/
    ├── auth/
    ├── gps/
    ├── ticket/
    └── trip/
```

### Composition de l'application

- `lib/main.dart` : point d'entrée Flutter.
- `lib/app/app.dart` : composition racine et injection manuelle des
  dépendances. Il construit les repositories, use cases et controllers, puis
  affiche l'écran de connexion ou l'accueil chauffeur.
- `lib/app/theme/app_theme.dart` : thèmes clair et sombre, couleurs et styles
  MaliTrans.

### Noyau partagé

- `lib/core/config/api_config.dart` : URLs locales selon la plateforme.
  - iOS Simulator : `http://127.0.0.1:8000`
  - Android Emulator : `http://10.0.2.2:8000`
- `lib/core/errors/app_exception.dart` : exception applicative destinée aux
  messages compréhensibles par l'utilisateur.
- `lib/core/network/api_client.dart` : client HTTP JSON commun, timeout,
  décodage des réponses, erreurs serveur et header
  `Authorization: Bearer <token>`.
- `lib/core/storage/token_storage.dart` : lecture, écriture et suppression du
  token Sanctum dans le stockage sécurisé natif.

### Fonctionnalité auth

- `auth/domain/entities/driver.dart` : entité du chauffeur connecté.
- `auth/domain/repositories/auth_repository.dart` : contrat de connexion.
- `auth/domain/usecases/login_driver.dart` : use case de connexion.
- `auth/data/models/driver_model.dart` : conversion de l'utilisateur Laravel.
- `auth/data/datasources/auth_remote_data_source.dart` : appel de
  `/auth/login` et extraction de `data.user` et `data.token`.
- `auth/data/repositories/auth_repository_impl.dart` : vérification du rôle,
  validation du token et sauvegarde sécurisée.
- `auth/presentation/controllers/login_controller.dart` : état de chargement,
  erreur et chauffeur connecté.
- `auth/presentation/pages/login_page.dart` : formulaire de connexion et
  validation locale des champs.

### Fonctionnalité trajet

- `trip/domain/entities/active_trip.dart` : trajet actif côté métier.
- `trip/domain/repositories/trip_repository.dart` : contrat de récupération.
- `trip/domain/usecases/get_active_trip.dart` : use case du trajet.
- `trip/data/models/active_trip_model.dart` : parsing des relations Laravel
  `ligne` et `bus`, avec conversion des nombres sérialisés en chaînes.
- `trip/data/datasources/trip_remote_data_source.dart` : appel de
  `/driver/trajet-actif`.
- `trip/data/repositories/trip_repository_impl.dart` : récupération du token
  puis appel de la datasource.
- `trip/presentation/controllers/active_trip_controller.dart` : chargement,
  rafraîchissement et erreurs.
- `trip/presentation/pages/driver_home_page.dart` : accueil chauffeur,
  affichage du trajet, accès au scanner et contrôle du suivi GPS.

### Fonctionnalité billets

- `ticket/domain/entities/validated_ticket.dart` : billet validé.
- `ticket/domain/repositories/ticket_repository.dart` : contrat de validation.
- `ticket/domain/usecases/validate_ticket.dart` : validation métier.
- `ticket/data/models/validated_ticket_model.dart` : parsing du billet Laravel.
- `ticket/data/datasources/ticket_remote_data_source.dart` : appel de
  `/driver/trajets/{trajet}/valider-billet`.
- `ticket/data/repositories/ticket_repository_impl.dart` : récupération du
  token et validation distante.
- `ticket/presentation/controllers/ticket_validation_controller.dart` :
  verrouillage pendant l'envoi, résultat et erreurs.
- `ticket/presentation/pages/ticket_scanner_page.dart` : caméra, permission,
  détection QR, résultat de validation et nouvelle tentative.

### Fonctionnalité GPS

- `gps/domain/entities/driver_location.dart` : latitude, longitude et date de
  mesure.
- `gps/domain/repositories/gps_repository.dart` : contrat de permission,
  flux de positions et envoi distant.
- `gps/data/datasources/location_device_data_source.dart` : service
  `geolocator`, demande de permission et flux de positions.
- `gps/data/datasources/gps_remote_data_source.dart` : appel de
  `/driver/trajets/{trajet}/gps`.
- `gps/data/repositories/gps_repository_impl.dart` : liaison entre le stockage
  du token, le GPS et l'API.
- `gps/presentation/controllers/gps_tracking_controller.dart` : démarrage,
  arrêt, écoute du flux, envoi et gestion des erreurs.

## Permissions natives

### iOS

`ios/Runner/Info.plist` contient :

- `NSCameraUsageDescription` pour le scan des billets ;
- `NSLocationWhenInUseUsageDescription` pour le suivi du trajet.

La caméra est démarrée manuellement après l'ouverture de l'écran scanner.
`mobile_scanner` déclenche alors la demande système. Un refus est affiché dans
l'écran avec une action de nouvelle tentative.

### Android

`android/app/src/main/AndroidManifest.xml` contient :

- `android.permission.CAMERA` ;
- `android.permission.ACCESS_FINE_LOCATION` ;
- `android.permission.ACCESS_COARSE_LOCATION`.

`geolocator` demande la permission de localisation au premier démarrage du
suivi GPS. Si le service est désactivé ou si la permission est refusée, le
controller reste dans l'application et affiche l'erreur au lieu de laisser
remonter une exception non gérée.

## API Laravel utilisée

| Fonction | Méthode | Endpoint |
|---|---:|---|
| Connexion | POST | `/api/v1/auth/login` |
| Profil | GET | `/api/v1/auth/me` |
| Déconnexion | POST | `/api/v1/auth/logout` |
| Trajet actif | GET | `/api/v1/driver/trajet-actif` |
| Validation billet | POST | `/api/v1/driver/trajets/{trajet}/valider-billet` |
| Position GPS | POST | `/api/v1/driver/trajets/{trajet}/gps` |

Toutes les routes chauffeur protégées exigent un token Sanctum et le rôle
`chauffeur`.

## Dépendances principales

- `http` : requêtes HTTP vers Laravel.
- `flutter_secure_storage` : stockage sécurisé du token.
- `mobile_scanner` : lecture des QR codes.
- `geolocator` : permissions et positions GPS.
- `flutter_lints` : règles d'analyse Dart.

## Tests

Depuis le projet Flutter :

```bash
dart format lib test
flutter analyze
flutter test
```

Tests actuels :

- `test/widget_test.dart` : présence de l'écran de connexion et validation des
  champs.
- `test/api_client_test.dart` : envoi du header Bearer.
- `test/active_trip_model_test.dart` : parsing de la réponse Laravel réelle,
  notamment `distance_km`.
- `test/gps_tracking_controller_test.dart` : démarrage du suivi et envoi d'une
  position.

## Lancement local

1. Démarrer l'API Laravel sur le port `8000`.
2. Vérifier l'adresse utilisée par la plateforme dans
   `lib/core/config/api_config.dart`.
3. Démarrer un simulateur iOS ou un émulateur Android.
4. Exécuter :

```bash
flutter pub get
flutter run
```

Le simulateur iOS peut accéder au backend local via `127.0.0.1`. L'émulateur
Android utilise `10.0.2.2`. Un appareil physique doit utiliser l'adresse IP
locale de l'ordinateur et un serveur Laravel accessible sur le réseau.

## Limites actuelles

- Le suivi GPS est actif lorsque l'application est ouverte et que le chauffeur
  l'a démarré ; il ne s'agit pas encore d'un service de localisation en arrière-
  plan.
- Le projet Flutter n'a pas encore de dépôt Git initialisé. Les commits doivent
  donc être créés après initialisation du dépôt dans ce dossier.
- Le build iOS dépend de la configuration locale Flutter/Xcode et des
  simulateurs installés.
- Android nécessite un SDK Android correctement configuré.
