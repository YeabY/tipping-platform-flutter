import 'package:hive/hive.dart';

part 'tip.g.dart';

@HiveType(typeId: 1)
enum TipStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  completed,
  @HiveField(2)
  failed,
  @HiveField(3)
  refunded,
}

@HiveType(typeId: 2)
enum Currency {
  @HiveField(0)
  usd,
  @HiveField(1)
  etb,
}

@HiveType(typeId: 3)
class Tip {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String tipperId;

  @HiveField(2)
  final String tipperName;

  @HiveField(3)
  final String? tipperEmail;

  @HiveField(4)
  final String creatorId;

  @HiveField(5)
  final double amount;

  @HiveField(6)
  final Currency currency;

  @HiveField(7)
  final String? message;

  @HiveField(8)
  final TipStatus status;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  @HiveField(11)
  final String? paymentIntentId;

  @HiveField(12)
  final double platformFee;

  @HiveField(13)
  final double creatorAmount;

  Tip({
    required this.id,
    required this.tipperId,
    required this.tipperName,
    this.tipperEmail,
    required this.creatorId,
    required this.amount,
    required this.currency,
    this.message,
    this.status = TipStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    this.paymentIntentId,
    this.platformFee = 0.0,
    this.creatorAmount = 0.0,
  });

  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      id: json['id'] as String,
      tipperId: json['tipperId'] as String,
      tipperName: json['tipperName'] as String,
      tipperEmail: json['tipperEmail'] as String?,
      creatorId: json['creatorId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: Currency.values.firstWhere(
        (e) => e.name == json['currency'],
        orElse: () => Currency.usd,
      ),
      message: json['message'] as String?,
      status: TipStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TipStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      paymentIntentId: json['paymentIntentId'] as String?,
      platformFee: (json['platformFee'] as num?)?.toDouble() ?? 0.0,
      creatorAmount: (json['creatorAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipperId': tipperId,
      'tipperName': tipperName,
      'tipperEmail': tipperEmail,
      'creatorId': creatorId,
      'amount': amount,
      'currency': currency.name,
      'message': message,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'paymentIntentId': paymentIntentId,
      'platformFee': platformFee,
      'creatorAmount': creatorAmount,
    };
  }

  Tip copyWith({
    String? id,
    String? tipperId,
    String? tipperName,
    String? tipperEmail,
    String? creatorId,
    double? amount,
    Currency? currency,
    String? message,
    TipStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? paymentIntentId,
    double? platformFee,
    double? creatorAmount,
  }) {
    return Tip(
      id: id ?? this.id,
      tipperId: tipperId ?? this.tipperId,
      tipperName: tipperName ?? this.tipperName,
      tipperEmail: tipperEmail ?? this.tipperEmail,
      creatorId: creatorId ?? this.creatorId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      platformFee: platformFee ?? this.platformFee,
      creatorAmount: creatorAmount ?? this.creatorAmount,
    );
  }

  String get currencySymbol {
    switch (currency) {
      case Currency.usd:
        return '\$';
      case Currency.etb:
        return 'ብር';
    }
  }

  String get formattedAmount {
    return '${currencySymbol}${amount.toStringAsFixed(2)}';
  }

  bool get isCompleted => status == TipStatus.completed;
  bool get isPending => status == TipStatus.pending;
  bool get isFailed => status == TipStatus.failed;
}
