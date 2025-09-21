import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String displayName;

  @HiveField(3)
  final String? profileImageUrl;

  @HiveField(4)
  final String? bio;

  @HiveField(5)
  final String? uniqueUrl;

  @HiveField(6)
  final bool isCreator;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  @HiveField(9)
  final bool isEmailVerified;

  @HiveField(10)
  final String? paymentAccountId;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.profileImageUrl,
    this.bio,
    this.uniqueUrl,
    this.isCreator = false,
    required this.createdAt,
    required this.updatedAt,
    this.isEmailVerified = false,
    this.paymentAccountId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      bio: json['bio'] as String?,
      uniqueUrl: json['uniqueUrl'] as String?,
      isCreator: json['isCreator'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      paymentAccountId: json['paymentAccountId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'uniqueUrl': uniqueUrl,
      'isCreator': isCreator,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'paymentAccountId': paymentAccountId,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? profileImageUrl,
    String? bio,
    String? uniqueUrl,
    bool? isCreator,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    String? paymentAccountId,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      uniqueUrl: uniqueUrl ?? this.uniqueUrl,
      isCreator: isCreator ?? this.isCreator,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      paymentAccountId: paymentAccountId ?? this.paymentAccountId,
    );
  }

  String get tippingUrl => uniqueUrl != null 
      ? 'https://tippingplatform.com/tip/$uniqueUrl' 
      : 'https://tippingplatform.com/tip/$id';
}
