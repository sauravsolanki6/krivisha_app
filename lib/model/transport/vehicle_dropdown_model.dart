class Vehicle {
  final String id;
  final String name;

  Vehicle({required this.id, required this.name});

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      name: json['vehical'] as String, // Map 'vehical' to name
    );
  }
}