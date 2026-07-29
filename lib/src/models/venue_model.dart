class VenueModel {
  final String id;
  final String name;
  final String address;
  final String sportType;
  final double pricePerHour;
  final double rating;
  final String imageUrl;
  final String vendorId;
  final String description;
  final String status;

  VenueModel({
    required this.id, // firebase document id
    required this.name, // venue name
    required this.address, // location
    required this.sportType,
    required this.pricePerHour,
    required this.rating,
    required this.imageUrl,
    required this.vendorId,
    required this.description,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'sportType': sportType,
      'pricePerHour': pricePerHour,
      'rating': rating,
      'imageUrl': imageUrl,
      'vendorId': vendorId,
      'description': description,
      'status': status,
    };
  }

  factory VenueModel.fromMap(Map<String, dynamic> map) {
    return VenueModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      sportType: map['sportType'] ?? '',
      pricePerHour: (map['pricePerHour'] ?? 0).toDouble(),
      rating: (map['rating'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      vendorId: map['vendorId'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'pending',
    );
  }
}
