enum PaymentType {
  creditCard,
  debitCard,
  paypal,
  applePay,
  googlePay,
}

class PaymentMethod {
  final String id;
  final PaymentType type;
  final String displayName;
  final String lastFourDigits;
  final String? cardBrand;
  final bool isDefault;

  const PaymentMethod({
    required this.id,
    required this.type,
    required this.displayName,
    required this.lastFourDigits,
    this.cardBrand,
    this.isDefault = false,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      type: PaymentType.values.byName(json['type'] as String),
      displayName: json['displayName'] as String,
      lastFourDigits: json['lastFourDigits'] as String,
      cardBrand: json['cardBrand'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'displayName': displayName,
      'lastFourDigits': lastFourDigits,
      'cardBrand': cardBrand,
      'isDefault': isDefault,
    };
  }

  String get displayText {
    switch (type) {
      case PaymentType.creditCard:
      case PaymentType.debitCard:
        return '${cardBrand ?? 'Card'} •••• $lastFourDigits';
      case PaymentType.paypal:
        return 'PayPal ($displayName)';
      case PaymentType.applePay:
        return 'Apple Pay';
      case PaymentType.googlePay:
        return 'Google Pay';
    }
  }
}