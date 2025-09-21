import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class LocalAuthService {
  static const String _usersKey = 'stored_users';
  static const String _currentUserKey = 'current_user';

  // Hash password for security
  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Store a new user account
  static Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing users
      final existingUsersJson = prefs.getString(_usersKey) ?? '{}';
      final Map<String, dynamic> existingUsers = jsonDecode(existingUsersJson);
      
      // Check if user already exists
      if (existingUsers.containsKey(email.toLowerCase())) {
        return {
          'success': false,
          'message': 'An account with this email already exists',
        };
      }
      
      // Create new user
      final hashedPassword = _hashPassword(password);
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email.toLowerCase(),
        displayName: displayName,
        isCreator: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isEmailVerified: false,
      );
      
      // Store user data with hashed password
      existingUsers[email.toLowerCase()] = {
        'user': newUser.toJson(),
        'hashedPassword': hashedPassword,
      };
      
      // Save to SharedPreferences
      await prefs.setString(_usersKey, jsonEncode(existingUsers));
      
      return {
        'success': true,
        'user': newUser,
        'token': 'local_token_${newUser.id}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }

  // Validate user login
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get stored users
      final existingUsersJson = prefs.getString(_usersKey) ?? '{}';
      final Map<String, dynamic> existingUsers = jsonDecode(existingUsersJson);
      
      final emailLower = email.toLowerCase();
      
      // Check if user exists
      if (!existingUsers.containsKey(emailLower)) {
        return {
          'success': false,
          'message': 'No account found with this email address',
        };
      }
      
      // Get stored user data
      final userData = existingUsers[emailLower];
      final storedPassword = userData['hashedPassword'] as String;
      final userJson = userData['user'] as Map<String, dynamic>;
      
      // Verify password
      final hashedPassword = _hashPassword(password);
      if (storedPassword != hashedPassword) {
        return {
          'success': false,
          'message': 'Invalid password',
        };
      }
      
      // Create user object
      final user = User.fromJson(userJson);
      
      return {
        'success': true,
        'user': user,
        'token': 'local_token_${user.id}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed: ${e.toString()}',
      };
    }
  }

  // Store current user session
  static Future<void> storeCurrentUser(User user, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode({
        'user': user.toJson(),
        'token': token,
      }));
    } catch (e) {
      print('Error storing current user: $e');
    }
  }

  // Get current user session
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserJson = prefs.getString(_currentUserKey);
      
      if (currentUserJson != null) {
        return jsonDecode(currentUserJson);
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Clear current user session
  static Future<void> clearCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
    } catch (e) {
      print('Error clearing current user: $e');
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    String? displayName,
    String? bio,
    String? profileImageUrl,
    String? uniqueUrl,
    bool? isCreator,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get stored users
      final existingUsersJson = prefs.getString(_usersKey) ?? '{}';
      final Map<String, dynamic> existingUsers = jsonDecode(existingUsersJson);
      
      // Find user by ID
      String? userEmail;
      for (String email in existingUsers.keys) {
        final userData = existingUsers[email];
        final userJson = userData['user'] as Map<String, dynamic>;
        if (userJson['id'] == userId) {
          userEmail = email;
          break;
        }
      }
      
      if (userEmail == null) {
        return {
          'success': false,
          'message': 'User not found',
        };
      }
      
      // Update user data
      final userData = existingUsers[userEmail];
      final userJson = userData['user'] as Map<String, dynamic>;
      
      // Apply updates
      if (displayName != null) userJson['displayName'] = displayName;
      if (bio != null) userJson['bio'] = bio;
      if (profileImageUrl != null) userJson['profileImageUrl'] = profileImageUrl;
      if (uniqueUrl != null) userJson['uniqueUrl'] = uniqueUrl;
      if (isCreator != null) userJson['isCreator'] = isCreator;
      userJson['updatedAt'] = DateTime.now().toIso8601String();
      
      // Save updated user
      existingUsers[userEmail] = {
        'user': userJson,
        'hashedPassword': userData['hashedPassword'],
      };
      
      await prefs.setString(_usersKey, jsonEncode(existingUsers));
      
      // Update current session if this is the current user
      final currentUserData = await getCurrentUser();
      if (currentUserData != null && currentUserData['user']['id'] == userId) {
        await storeCurrentUser(User.fromJson(userJson), currentUserData['token']);
      }
      
      return {
        'success': true,
        'user': User.fromJson(userJson),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Profile update failed: ${e.toString()}',
      };
    }
  }

  // Get user by unique URL (for creator profiles)
  static Future<User?> getUserByUniqueUrl(String uniqueUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get stored users
      final existingUsersJson = prefs.getString(_usersKey) ?? '{}';
      final Map<String, dynamic> existingUsers = jsonDecode(existingUsersJson);
      
      // Find user by unique URL
      for (String email in existingUsers.keys) {
        final userData = existingUsers[email];
        final userJson = userData['user'] as Map<String, dynamic>;
        
        if (userJson['uniqueUrl'] == uniqueUrl && userJson['isCreator'] == true) {
          return User.fromJson(userJson);
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting user by unique URL: $e');
      return null;
    }
  }

  // Get all creators for discovery
  static Future<List<User>> getAllCreators() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get stored users
      final existingUsersJson = prefs.getString(_usersKey) ?? '{}';
      final Map<String, dynamic> existingUsers = jsonDecode(existingUsersJson);
      
      List<User> creators = [];
      
      for (String email in existingUsers.keys) {
        final userData = existingUsers[email];
        final userJson = userData['user'] as Map<String, dynamic>;
        
        if (userJson['isCreator'] == true) {
          creators.add(User.fromJson(userJson));
        }
      }
      
      return creators;
    } catch (e) {
      print('Error getting creators: $e');
      return [];
    }
  }

  // Reset password (for demo purposes, just validates email exists)
  static Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get stored users
      final existingUsersJson = prefs.getString(_usersKey) ?? '{}';
      final Map<String, dynamic> existingUsers = jsonDecode(existingUsersJson);
      
      if (!existingUsers.containsKey(email.toLowerCase())) {
        return {
          'success': false,
          'message': 'No account found with this email address',
        };
      }
      
      return {
        'success': true,
        'message': 'Password reset instructions sent to $email',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Password reset failed: ${e.toString()}',
      };
    }
  }
}
