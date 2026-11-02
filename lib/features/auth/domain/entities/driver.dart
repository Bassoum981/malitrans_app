class Driver {
  const Driver({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.telephone,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String? telephone;

  bool get isDriver => role == 'chauffeur';
}
