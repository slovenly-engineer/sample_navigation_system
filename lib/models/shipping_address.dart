class ShippingAddress {
  final String id;
  final String fullName;
  final String streetAddress;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String phoneNumber;
  final bool isDefault;

  const ShippingAddress({
    required this.id,
    required this.fullName,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.phoneNumber,
    this.isDefault = false,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      streetAddress: json['streetAddress'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zipCode'] as String,
      country: json['country'] as String,
      phoneNumber: json['phoneNumber'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'phoneNumber': phoneNumber,
      'isDefault': isDefault,
    };
  }

  String get formattedAddress {
    return '$streetAddress\n$city, $state $zipCode\n$country';
  }
}