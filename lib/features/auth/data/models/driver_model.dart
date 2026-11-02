import '../../domain/entities/driver.dart';

class DriverModel extends Driver {
  const DriverModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.telephone,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: _asInt(json['id']),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      telephone: json['telephone'] as String?,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.parse(value.toString());
  }
}
