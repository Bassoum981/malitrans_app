import '../../domain/entities/validated_ticket.dart';

class ValidatedTicketModel extends ValidatedTicket {
  const ValidatedTicketModel({
    required super.id,
    required super.qrCode,
    required super.passengerName,
    required super.seatNumber,
    required super.status,
    required super.price,
    super.validatedAt,
  });

  factory ValidatedTicketModel.fromJson(Map<String, dynamic> json) {
    return ValidatedTicketModel(
      id: _asInt(json['id']),
      qrCode: json['code_qr_hash'] as String? ?? '',
      passengerName: json['nom_passager'] as String? ?? 'Passager inconnu',
      seatNumber: _asInt(json['numero_siege']),
      status: json['statut'] as String? ?? 'VALIDE',
      price: json['prix'] as num? ?? 0,
      validatedAt: _asDateTime(json['date_validation']),
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
}
