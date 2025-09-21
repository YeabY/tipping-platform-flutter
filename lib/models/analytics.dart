import 'package:hive/hive.dart';

part 'analytics.g.dart';

@HiveType(typeId: 7)
class CreatorAnalytics {
  @HiveField(0)
  final String creatorId;

  @HiveField(1)
  final double totalEarnings;

  @HiveField(2)
  final int totalTips;

  @HiveField(3)
  final double averageTipAmount;

  @HiveField(4)
  final DateTime lastTipDate;

  @HiveField(5)
  final Map<String, int> tipsByCurrency;

  @HiveField(6)
  final Map<String, double> earningsByCurrency;

  @HiveField(7)
  final List<TipFrequency> tipFrequency;

  @HiveField(8)
  final List<TopTipper> topTippers;

  @HiveField(9)
  final DateTime generatedAt;

  CreatorAnalytics({
    required this.creatorId,
    required this.totalEarnings,
    required this.totalTips,
    required this.averageTipAmount,
    required this.lastTipDate,
    required this.tipsByCurrency,
    required this.earningsByCurrency,
    required this.tipFrequency,
    required this.topTippers,
    required this.generatedAt,
  });

  factory CreatorAnalytics.fromJson(Map<String, dynamic> json) {
    return CreatorAnalytics(
      creatorId: json['creatorId'] as String,
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      totalTips: json['totalTips'] as int,
      averageTipAmount: (json['averageTipAmount'] as num).toDouble(),
      lastTipDate: DateTime.parse(json['lastTipDate'] as String),
      tipsByCurrency: Map<String, int>.from(json['tipsByCurrency'] as Map),
      earningsByCurrency: Map<String, double>.from(json['earningsByCurrency'] as Map),
      tipFrequency: (json['tipFrequency'] as List)
          .map((item) => TipFrequency.fromJson(item as Map<String, dynamic>))
          .toList(),
      topTippers: (json['topTippers'] as List)
          .map((item) => TopTipper.fromJson(item as Map<String, dynamic>))
          .toList(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'creatorId': creatorId,
      'totalEarnings': totalEarnings,
      'totalTips': totalTips,
      'averageTipAmount': averageTipAmount,
      'lastTipDate': lastTipDate.toIso8601String(),
      'tipsByCurrency': tipsByCurrency,
      'earningsByCurrency': earningsByCurrency,
      'tipFrequency': tipFrequency.map((item) => item.toJson()).toList(),
      'topTippers': topTippers.map((item) => item.toJson()).toList(),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}

@HiveType(typeId: 8)
class TipFrequency {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int tipCount;

  @HiveField(2)
  final double totalAmount;

  TipFrequency({
    required this.date,
    required this.tipCount,
    required this.totalAmount,
  });

  factory TipFrequency.fromJson(Map<String, dynamic> json) {
    return TipFrequency(
      date: DateTime.parse(json['date'] as String),
      tipCount: json['tipCount'] as int,
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'tipCount': tipCount,
      'totalAmount': totalAmount,
    };
  }
}

@HiveType(typeId: 9)
class TopTipper {
  @HiveField(0)
  final String tipperName;

  @HiveField(1)
  final int tipCount;

  @HiveField(2)
  final double totalAmount;

  @HiveField(3)
  final DateTime lastTipDate;

  TopTipper({
    required this.tipperName,
    required this.tipCount,
    required this.totalAmount,
    required this.lastTipDate,
  });

  factory TopTipper.fromJson(Map<String, dynamic> json) {
    return TopTipper(
      tipperName: json['tipperName'] as String,
      tipCount: json['tipCount'] as int,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      lastTipDate: DateTime.parse(json['lastTipDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipperName': tipperName,
      'tipCount': tipCount,
      'totalAmount': totalAmount,
      'lastTipDate': lastTipDate.toIso8601String(),
    };
  }
}
