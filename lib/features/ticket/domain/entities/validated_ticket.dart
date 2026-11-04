class ValidatedTicket {
  const ValidatedTicket({
    required this.id,
    required this.qrCode,
    required this.passengerName,
    required this.seatNumber,
    required this.status,
    required this.price,
    required this.tripId,
    required this.passengerPhone,
    required this.saleType,
    required this.paymentDate,
    this.validatedAt,
    this.departureCity,
    this.arrivalCity,
    this.departureAt,
    this.busRegistration,
    this.sellerName,
  });

  final int id;
  final String qrCode;
  final String passengerName;
  final int seatNumber;
  final String status;
  final num price;
  final int tripId;
  final String? passengerPhone;
  final String? saleType;
  final DateTime? paymentDate;
  final DateTime? validatedAt;
  final String? departureCity;
  final String? arrivalCity;
  final DateTime? departureAt;
  final String? busRegistration;
  final String? sellerName;
}
