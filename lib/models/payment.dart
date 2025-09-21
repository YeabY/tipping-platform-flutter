import 'package:hive/hive.dart';

part 'payment.g.dart';

@HiveType(typeId: 4)
enum PaymentMethod {
  @HiveField(0)
  creditCard,
  @HiveField(1)
  debitCard,
  @HiveField(2)
  bankTransfer,
  @HiveField(3)
  mobileMoney,
  @HiveField(4)
  paypal,
}

@HiveType(typeId: 5)
enum PaymentStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  processing,
  @HiveField(2)
  completed,
  @HiveField(3)
  failed,
  @HiveField(4)
  cancelled,
  @HiveField(5)
  refunded,
}

@HiveType(typeId: 6)
class Payment {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final PaymentMethod method;

  @HiveField(3)
  final PaymentStatus status;

  @HiveField(4)
  final double amount;

  @HiveField(5)
  final String currency;

  @HiveField(6)
  final String? stripePaymentIntentId;

  @HiveField(7)
  final String? paypalOrderId;

  @HiveField(8)
  final String? transactionId;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  @HiveField(11)
  final String? failureReason;

  @HiveField(12)
  final Map<String, dynamic>? metadata;

  Payment({
    required this.id,
    required this.userId,
    required this.method,
    required this.status,
    required this.amount,
    required this.currency,
    this.stripePaymentIntentId,
    this.paypalOrderId,
    this.transactionId,
    required this.createdAt,
    required this.updatedAt,
    this.failureReason,
    this.metadata,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => PaymentMethod.creditCard,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      stripePaymentIntentId: json['stripePaymentIntentId'] as String?,
      paypalOrderId: json['paypalOrderId'] as String?,
      transactionId: json['transactionId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      failureReason: json['failureReason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'method': method.name,
      'status': status.name,
      'amount': amount,
      'currency': currency,
      'stripePaymentIntentId': stripePaymentIntentId,
      'paypalOrderId': paypalOrderId,
      'transactionId': transactionId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'failureReason': failureReason,
      'metadata': metadata,
    };
  }

  Payment copyWith({
    String? id,
    String? userId,
    PaymentMethod? method,
    PaymentStatus? status,
    double? amount,
    String? currency,
    String? stripePaymentIntentId,
    String? paypalOrderId,
    String? transactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? failureReason,
    Map<String, dynamic>? metadata,
  }) {
    return Payment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      method: method ?? this.method,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      stripePaymentIntentId: stripePaymentIntentId ?? this.stripePaymentIntentId,
      paypalOrderId: paypalOrderId ?? this.paypalOrderId,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      failureReason: failureReason ?? this.failureReason,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isCompleted => status == PaymentStatus.completed;
  bool get isPending => status == PaymentStatus.pending;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isProcessing => status == PaymentStatus.processing;

  String get statusDisplayName {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  String get methodDisplayName {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.mobileMoney:
        return 'Mobile Money';
      case PaymentMethod.paypal:
        return 'PayPal';
    }
  }
}
