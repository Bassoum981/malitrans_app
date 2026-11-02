class ValidatedTicket {
  const ValidatedTicket({
    required this.id,
    required this.qrCode,
    required this.passengerName,
    required this.seatNumber,
    required this.status,
    required this.price,
    this.validatedAt,
  });

  final int id;
  final String qrCode;
  final String passengerName;
  final int seatNumber;
  final String status;
  final num price;
  final DateTime? validatedAt;
}
