import '../../domain/entities/validated_ticket.dart';

class ValidatedTicketModel extends ValidatedTicket {
  const ValidatedTicketModel({
    required super.id,
    required super.qrCode,
    required super.passengerName,
    required super.seatNumber,
    required super.status,
    required super.price,
    required super.tripId,
    required super.passengerPhone,
    required super.saleType,
    required super.paymentDate,
    super.validatedAt,
    super.departureCity,
    super.arrivalCity,
    super.departureAt,
    super.busRegistration,
    super.sellerName,
  });

  factory ValidatedTicketModel.fromJson(Map<String, dynamic> json) {
    return ValidatedTicketModel(
      id: _asInt(json['id']),
      qrCode: json['code_qr_hash'] as String? ?? '',
      passengerName: json['nom_passager'] as String? ?? 'Passager inconnu',
      seatNumber: _asInt(json['numero_siege']),
      status: json['statut'] as String? ?? 'VALIDE',
      price: _asNum(json['prix']),
      tripId: _asInt(json['trajet_id']),
      passengerPhone: json['telephone_passager'] as String?,
      saleType: json['type_vente'] as String?,
      paymentDate: _asDateTime(json['date_paiement']),
      validatedAt: _asDateTime(json['date_validation']),
      departureCity: _nestedString(json, 'trajet', 'ligne', 'ville_depart'),
      arrivalCity: _nestedString(json, 'trajet', 'ligne', 'ville_arrivee'),
      departureAt: _nestedDateTime(json, 'trajet', 'heure_depart_prevue'),
      busRegistration: _nestedString(json, 'trajet', 'bus', 'immatriculation'),
      sellerName: _relationString(json, 'vendeur', 'name'),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }

  static num _asNum(dynamic value) {
    if (value is num) {
      return value;
    }

    return num.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _nestedString(
    Map<String, dynamic> json,
    String parent,
    String? child,
    String key,
  ) {
    dynamic value = json[parent];

    if (child != null) {
      value = value is Map<String, dynamic> ? value[child] : null;
    }

    return value is Map<String, dynamic> ? value[key] as String? : null;
  }

  static DateTime? _nestedDateTime(
    Map<String, dynamic> json,
    String parent,
    String key,
  ) {
    final value = json[parent];

    return value is Map<String, dynamic> ? _asDateTime(value[key]) : null;
  }

  static String? _relationString(
    Map<String, dynamic> json,
    String relation,
    String key,
  ) {
    final value = json[relation];

    return value is Map<String, dynamic> ? value[key] as String? : null;
  }
}
