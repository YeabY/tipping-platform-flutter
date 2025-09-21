import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tip.dart';
import '../models/user.dart';

class LocalTipService {
  static const String _tipsKey = 'stored_tips';
  static const String _creatorProfilesKey = 'creator_profiles';

  // Send a tip
  static Future<Map<String, dynamic>> sendTip({
    required String creatorId,
    required String creatorEmail,
    required double amount,
    required String currency,
    String? message,
    String? tipperEmail,
    String? tipperName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing tips
      final existingTipsJson = prefs.getString(_tipsKey) ?? '[]';
      final List<dynamic> existingTips = jsonDecode(existingTipsJson);
      
      // Create new tip
      final now = DateTime.now();
      final platformFeePercentage = 0.05; // 5% platform fee
      final platformFee = amount * platformFeePercentage;
      final creatorAmount = amount - platformFee;
      
      final newTip = Tip(
        id: now.millisecondsSinceEpoch.toString(),
        tipperId: tipperEmail ?? 'anonymous_${now.millisecondsSinceEpoch}',
        tipperName: tipperName ?? 'Anonymous',
        tipperEmail: tipperEmail,
        creatorId: creatorId,
        amount: amount,
        currency: Currency.values.firstWhere(
          (c) => c.name.toLowerCase() == currency.toLowerCase(),
          orElse: () => Currency.usd,
        ),
        message: message,
        status: TipStatus.completed,
        createdAt: now,
        updatedAt: now,
        platformFee: platformFee,
        creatorAmount: creatorAmount,
      );
      
      // Add tip to list
      existingTips.add(newTip.toJson());
      
      // Save tips
      await prefs.setString(_tipsKey, jsonEncode(existingTips));
      
      return {
        'success': true,
        'tip': newTip,
        'message': 'Tip sent successfully!',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send tip: ${e.toString()}',
      };
    }
  }

  // Get tips for a specific creator
  static Future<List<Tip>> getCreatorTips(String creatorId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final existingTipsJson = prefs.getString(_tipsKey) ?? '[]';
      final List<dynamic> existingTips = jsonDecode(existingTipsJson);
      
      List<Tip> creatorTips = [];
      
      for (var tipJson in existingTips) {
        final tip = Tip.fromJson(tipJson);
        if (tip.creatorId == creatorId) {
          creatorTips.add(tip);
        }
      }
      
      // Sort by creation date (newest first)
      creatorTips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return creatorTips;
    } catch (e) {
      print('Error getting creator tips: $e');
      return [];
    }
  }

  // Get all tips (for admin purposes)
  static Future<List<Tip>> getAllTips() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final existingTipsJson = prefs.getString(_tipsKey) ?? '[]';
      final List<dynamic> existingTips = jsonDecode(existingTipsJson);
      
      List<Tip> tips = [];
      
      for (var tipJson in existingTips) {
        tips.add(Tip.fromJson(tipJson));
      }
      
      // Sort by creation date (newest first)
      tips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return tips;
    } catch (e) {
      print('Error getting all tips: $e');
      return [];
    }
  }

  // Get creator analytics
  static Future<Map<String, dynamic>> getCreatorAnalytics(String creatorId) async {
    try {
      final tips = await getCreatorTips(creatorId);
      
      if (tips.isEmpty) {
        return {
          'success': true,
          'analytics': {
            'totalEarnings': 0.0,
            'totalTips': 0,
            'averageTip': 0.0,
            'currency': 'USD',
            'recentTips': [],
            'topTippers': [],
          },
        };
      }
      
      // Calculate analytics
      double totalEarnings = 0.0;
      String currency = 'USD';
      Map<String, double> tipperTotals = {};
      Map<String, int> tipperCounts = {};
      
      for (var tip in tips) {
        totalEarnings += tip.amount;
        currency = tip.currency.name.toUpperCase();
        
        final tipperKey = tip.tipperEmail ?? tip.tipperName ?? 'Anonymous';
        tipperTotals[tipperKey] = (tipperTotals[tipperKey] ?? 0.0) + tip.amount;
        tipperCounts[tipperKey] = (tipperCounts[tipperKey] ?? 0) + 1;
      }
      
      double averageTip = totalEarnings / tips.length;
      
      // Get top tippers
      List<Map<String, dynamic>> topTippers = [];
      tipperTotals.forEach((tipper, amount) {
        topTippers.add({
          'tipperName': tipper,
          'totalAmount': amount,
          'tipCount': tipperCounts[tipper] ?? 0,
        });
      });
      
      topTippers.sort((a, b) => b['totalAmount'].compareTo(a['totalAmount']));
      topTippers = topTippers.take(5).toList();
      
      // Get recent tips (last 10)
      final recentTips = tips.take(10).map((tip) => {
        'id': tip.id,
        'amount': tip.amount,
        'currency': tip.currency.name,
        'message': tip.message,
        'createdAt': tip.createdAt.toIso8601String(),
        'tipperName': tip.tipperName ?? tip.tipperEmail ?? 'Anonymous',
      }).toList();
      
      return {
        'success': true,
        'analytics': {
          'totalEarnings': totalEarnings,
          'totalTips': tips.length,
          'averageTip': averageTip,
          'currency': currency,
          'recentTips': recentTips,
          'topTippers': topTippers,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get analytics: ${e.toString()}',
      };
    }
  }

  // Store creator profile
  static Future<Map<String, dynamic>> storeCreatorProfile({
    required String userId,
    required String uniqueUrl,
    required String displayName,
    String? bio,
    String? profileImageUrl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing creator profiles
      final existingProfilesJson = prefs.getString(_creatorProfilesKey) ?? '{}';
      final Map<String, dynamic> existingProfiles = jsonDecode(existingProfilesJson);
      
      // Check if unique URL is already taken
      for (String key in existingProfiles.keys) {
        final profile = existingProfiles[key];
        if (profile['uniqueUrl'] == uniqueUrl && profile['userId'] != userId) {
          return {
            'success': false,
            'message': 'This URL is already taken. Please choose a different one.',
          };
        }
      }
      
      // Create creator profile
      final creatorProfile = {
        'userId': userId,
        'uniqueUrl': uniqueUrl,
        'displayName': displayName,
        'bio': bio,
        'profileImageUrl': profileImageUrl,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      // Store profile
      existingProfiles[userId] = creatorProfile;
      await prefs.setString(_creatorProfilesKey, jsonEncode(existingProfiles));
      
      return {
        'success': true,
        'profile': creatorProfile,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create creator profile: ${e.toString()}',
      };
    }
  }

  // Get creator profile by unique URL
  static Future<Map<String, dynamic>?> getCreatorProfileByUrl(String uniqueUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final existingProfilesJson = prefs.getString(_creatorProfilesKey) ?? '{}';
      final Map<String, dynamic> existingProfiles = jsonDecode(existingProfilesJson);
      
      for (String key in existingProfiles.keys) {
        final profile = existingProfiles[key];
        if (profile['uniqueUrl'] == uniqueUrl) {
          return profile;
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting creator profile: $e');
      return null;
    }
  }

  // Get creator profile by user ID
  static Future<Map<String, dynamic>?> getCreatorProfileByUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final existingProfilesJson = prefs.getString(_creatorProfilesKey) ?? '{}';
      final Map<String, dynamic> existingProfiles = jsonDecode(existingProfilesJson);
      
      return existingProfiles[userId];
    } catch (e) {
      print('Error getting creator profile by user ID: $e');
      return null;
    }
  }

  // Update creator profile
  static Future<Map<String, dynamic>> updateCreatorProfile({
    required String userId,
    String? uniqueUrl,
    String? displayName,
    String? bio,
    String? profileImageUrl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final existingProfilesJson = prefs.getString(_creatorProfilesKey) ?? '{}';
      final Map<String, dynamic> existingProfiles = jsonDecode(existingProfilesJson);
      
      if (!existingProfiles.containsKey(userId)) {
        return {
          'success': false,
          'message': 'Creator profile not found',
        };
      }
      
      final currentProfile = existingProfiles[userId];
      
      // Check unique URL if it's being changed
      if (uniqueUrl != null && uniqueUrl != currentProfile['uniqueUrl']) {
        for (String key in existingProfiles.keys) {
          final profile = existingProfiles[key];
          if (profile['uniqueUrl'] == uniqueUrl && key != userId) {
            return {
              'success': false,
              'message': 'This URL is already taken. Please choose a different one.',
            };
          }
        }
      }
      
      // Update profile
      if (uniqueUrl != null) currentProfile['uniqueUrl'] = uniqueUrl;
      if (displayName != null) currentProfile['displayName'] = displayName;
      if (bio != null) currentProfile['bio'] = bio;
      if (profileImageUrl != null) currentProfile['profileImageUrl'] = profileImageUrl;
      currentProfile['updatedAt'] = DateTime.now().toIso8601String();
      
      existingProfiles[userId] = currentProfile;
      await prefs.setString(_creatorProfilesKey, jsonEncode(existingProfiles));
      
      return {
        'success': true,
        'profile': currentProfile,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update creator profile: ${e.toString()}',
      };
    }
  }

  // Get all creator profiles (for discovery)
  static Future<List<Map<String, dynamic>>> getAllCreatorProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final existingProfilesJson = prefs.getString(_creatorProfilesKey) ?? '{}';
      final Map<String, dynamic> existingProfiles = jsonDecode(existingProfilesJson);
      
      List<Map<String, dynamic>> profiles = [];
      
      existingProfiles.forEach((userId, profile) {
        profiles.add(profile);
      });
      
      // Sort by creation date (newest first)
      profiles.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
      
      return profiles;
    } catch (e) {
      print('Error getting all creator profiles: $e');
      return [];
    }
  }
}
